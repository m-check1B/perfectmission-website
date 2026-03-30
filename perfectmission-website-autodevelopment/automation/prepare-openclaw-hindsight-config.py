#!/usr/bin/env python3
"""Materialize an effective OpenClaw config for local Hindsight recovery."""

from __future__ import annotations

import argparse
import json
from pathlib import Path
from urllib.parse import urlparse


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Prepare an effective OpenClaw config path for Hindsight recovery"
    )
    parser.add_argument("--source", required=True)
    parser.add_argument("--output", required=True)
    parser.add_argument("--api-url", required=True)
    return parser.parse_args()


def parse_port(api_url: str) -> int:
    parsed = urlparse(api_url)
    if parsed.hostname not in {"127.0.0.1", "localhost"}:
        raise SystemExit(f"api-url must point to localhost, got: {api_url}")
    return parsed.port or 80


def plugin_config(payload: dict) -> dict:
    return (
        (((payload.get("plugins") or {}).get("entries") or {}).get("hindsight-openclaw") or {}).get("config")
        or {}
    )


def main() -> int:
    args = parse_args()
    source_path = Path(args.source).expanduser()
    output_path = Path(args.output)
    target_port = parse_port(args.api_url)

    if not source_path.is_file():
        print(str(source_path))
        return 0

    try:
        payload = json.loads(source_path.read_text())
    except Exception:
        print(str(source_path))
        return 0

    config = plugin_config(payload)
    if not config.get("hindsightApiUrl"):
        if output_path.exists():
            output_path.unlink()
        print(str(source_path))
        return 0

    patched = json.loads(json.dumps(payload))
    patched_config = plugin_config(patched)
    patched_config.pop("hindsightApiUrl", None)
    patched_config["apiPort"] = target_port

    output_path.parent.mkdir(parents=True, exist_ok=True)
    output_path.write_text(json.dumps(patched, indent=2) + "\n")
    print(str(output_path))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
