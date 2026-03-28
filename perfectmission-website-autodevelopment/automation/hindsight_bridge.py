#!/usr/bin/env python3
"""Shared Hindsight bridge for repo-local autodevelopment memory."""

from __future__ import annotations

from dataclasses import dataclass
import json
import os
from pathlib import Path
from typing import Any, Iterable
from urllib import error, parse, request


DEFAULT_API_URL = "http://127.0.0.1:9077"
DEFAULT_RETAIN_MISSION = (
    "Track project objectives, architecture, invariants, commands, failures, "
    "delivery history, open questions, and next actions. Ignore boilerplate and low-signal chatter."
)
DEFAULT_OBSERVATIONS_MISSION = (
    "Observations are stable facts about the project, operator workflow, recurring failures, "
    "and delivery patterns. Ignore one-off transient task noise."
)


class HindsightError(RuntimeError):
    """Raised when the local Hindsight API cannot satisfy a request."""


@dataclass(frozen=True)
class HindsightConfig:
    backend: str
    enabled: bool
    api_url: str
    api_token: str | None
    bank_id: str
    retain_mission: str
    observations_mission: str
    recall_budget: str
    recall_max_tokens: int
    timeout_seconds: float
    state_file: Path
    static_tags: list[str]
    autodev_id: str
    project_name: str


def parse_bool(value: str | None, default: bool = False) -> bool:
    if value is None:
        return default
    return value.strip().lower() in {"1", "true", "yes", "on"}


def parse_tags(raw: str | None) -> list[str]:
    if not raw:
        return []
    seen: set[str] = set()
    tags: list[str] = []
    for chunk in raw.replace("\n", ",").split(","):
        tag = chunk.strip()
        if not tag or tag in seen:
            continue
        seen.add(tag)
        tags.append(tag)
    return tags


def load_autodev_config() -> HindsightConfig:
    backend = os.environ.get("AUTODEV_MEMORY_BACKEND", "hybrid-sqlite").strip() or "hybrid-sqlite"
    enabled = backend in {"hindsight", "hindsight-hybrid"}
    autodev_id = os.environ.get("AUTODEV_ID", "autodev").strip() or "autodev"
    project_name = os.environ.get("PROJECT_NAME", autodev_id).strip() or autodev_id
    api_url = (
        os.environ.get("AUTODEV_MEMORY_HINDSIGHT_API_URL")
        or os.environ.get("HINDSIGHT_API_URL")
        or DEFAULT_API_URL
    ).rstrip("/")
    api_token = os.environ.get("AUTODEV_MEMORY_HINDSIGHT_API_TOKEN") or os.environ.get("HINDSIGHT_API_TOKEN")
    bank_id = (
        os.environ.get("AUTODEV_MEMORY_HINDSIGHT_BANK_ID")
        or f"kraliki-autodev-{autodev_id}"
    ).strip()
    retain_mission = (
        os.environ.get("AUTODEV_MEMORY_HINDSIGHT_BANK_MISSION") or DEFAULT_RETAIN_MISSION
    ).strip()
    observations_mission = (
        os.environ.get("AUTODEV_MEMORY_HINDSIGHT_OBSERVATIONS_MISSION") or DEFAULT_OBSERVATIONS_MISSION
    ).strip()
    recall_budget = (os.environ.get("AUTODEV_MEMORY_HINDSIGHT_RECALL_BUDGET") or "mid").strip() or "mid"
    recall_max_tokens = int(os.environ.get("AUTODEV_MEMORY_HINDSIGHT_MAX_TOKENS", "1400"))
    timeout_seconds = float(os.environ.get("AUTODEV_MEMORY_HINDSIGHT_TIMEOUT_SECONDS", "300"))
    state_file = Path(
        os.environ.get("AUTODEV_MEMORY_HINDSIGHT_STATE_FILE", ".agent/hindsight-sync.json")
    ).expanduser()
    static_tags = parse_tags(os.environ.get("AUTODEV_MEMORY_HINDSIGHT_TAGS"))
    return HindsightConfig(
        backend=backend,
        enabled=enabled,
        api_url=api_url,
        api_token=api_token,
        bank_id=bank_id,
        retain_mission=retain_mission,
        observations_mission=observations_mission,
        recall_budget=recall_budget,
        recall_max_tokens=recall_max_tokens,
        timeout_seconds=timeout_seconds,
        state_file=state_file,
        static_tags=static_tags,
        autodev_id=autodev_id,
        project_name=project_name,
    )


def bank_path(bank_id: str) -> str:
    return f"/v1/default/banks/{parse.quote(bank_id, safe='')}"


def hindsight_request(
    config: HindsightConfig,
    method: str,
    path: str,
    payload: dict[str, Any] | None = None,
    *,
    allow_not_found: bool = False,
) -> dict[str, Any]:
    data = None
    if payload is not None:
        data = json.dumps(payload).encode("utf-8")
    endpoint = f"{config.api_url}{path}"
    req = request.Request(endpoint, data=data, method=method.upper())
    req.add_header("Accept", "application/json")
    if data is not None:
        req.add_header("Content-Type", "application/json")
    if config.api_token:
        req.add_header("Authorization", f"Bearer {config.api_token}")
    try:
        with request.urlopen(req, timeout=config.timeout_seconds) as response:
            raw = response.read().decode("utf-8").strip()
    except error.HTTPError as exc:
        if allow_not_found and exc.code == 404:
            return {"status": 404}
        try:
            body = exc.read().decode("utf-8").strip()
        except Exception:
            body = ""
        detail = body or exc.reason or str(exc)
        raise HindsightError(f"{method.upper()} {path} failed with HTTP {exc.code}: {detail}") from exc
    except error.URLError as exc:
        raise HindsightError(f"{method.upper()} {path} failed: {exc.reason}") from exc
    except Exception as exc:
        raise HindsightError(f"{method.upper()} {path} failed: {exc}") from exc

    if not raw:
        return {}
    try:
        return json.loads(raw)
    except json.JSONDecodeError:
        raise HindsightError(f"{method.upper()} {path} returned non-JSON response")


def chunked(values: list[Any], size: int) -> Iterable[list[Any]]:
    if size <= 0:
        raise ValueError("chunk size must be positive")
    for index in range(0, len(values), size):
        yield values[index : index + size]
