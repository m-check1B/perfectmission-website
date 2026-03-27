#!/usr/bin/env python3
"""Local runtime governance for repo-local autodevelopment cycles."""

from __future__ import annotations

import argparse
import hashlib
import json
import os
import time
from pathlib import Path


ROOT_DIR = Path(__file__).resolve().parents[1]
STATE_FILE = ROOT_DIR / "state" / "governance.json"


def _env_int(name: str, default: int) -> int:
    try:
        return int(os.environ.get(name, str(default)))
    except ValueError:
        return default


DEFAULTS = {
    "max_calls_per_hour": _env_int("AUTODEV_MAX_CALLS_PER_HOUR", 48),
    "max_calls_per_day": _env_int("AUTODEV_MAX_CALLS_PER_DAY", 240),
    "loop_detection_threshold": _env_int("AUTODEV_LOOP_DETECTION_THRESHOLD", 8),
}


def hash_prompt(text: str) -> str:
    return hashlib.sha256(text.encode("utf-8")).hexdigest()


def load_state() -> dict:
    if not STATE_FILE.exists():
        return {"hour_calls": [], "day_calls": [], "repeated_prompts": {}}
    try:
        return json.loads(STATE_FILE.read_text())
    except (OSError, json.JSONDecodeError):
        return {"hour_calls": [], "day_calls": [], "repeated_prompts": {}}


def check_governance(scope: str, prompt_hash: str | None = None) -> dict:
    now = time.time()
    state = load_state()
    state["hour_calls"] = [ts for ts in state.get("hour_calls", []) if ts > now - 3600]
    state["day_calls"] = [ts for ts in state.get("day_calls", []) if ts > now - 86400]

    if len(state["hour_calls"]) >= DEFAULTS["max_calls_per_hour"]:
        return {"allowed": False, "reason": "hourly call limit reached"}
    if len(state["day_calls"]) >= DEFAULTS["max_calls_per_day"]:
        return {"allowed": False, "reason": "daily call limit reached"}

    if prompt_hash:
        repeats = int(state.get("repeated_prompts", {}).get(f"{scope}:{prompt_hash}", 0))
        if repeats >= DEFAULTS["loop_detection_threshold"]:
            return {"allowed": False, "reason": f"loop detected for scope={scope}"}
        state.setdefault("repeated_prompts", {})[f"{scope}:{prompt_hash}"] = repeats + 1

    state["hour_calls"].append(now)
    state["day_calls"].append(now)
    STATE_FILE.parent.mkdir(parents=True, exist_ok=True)
    STATE_FILE.write_text(json.dumps(state, indent=2))
    return {"allowed": True, "scope": scope, "hour_calls": len(state["hour_calls"]), "day_calls": len(state["day_calls"])}


def main() -> int:
    parser = argparse.ArgumentParser(description="Check repo-local autodevelopment governance")
    parser.add_argument("--scope", required=True)
    parser.add_argument("--prompt-file", default="")
    args = parser.parse_args()

    prompt_hash = None
    if args.prompt_file:
        prompt_hash = hash_prompt(Path(args.prompt_file).read_text())

    result = check_governance(scope=args.scope, prompt_hash=prompt_hash)
    print(json.dumps(result, indent=2))
    return 0 if result["allowed"] else 1


if __name__ == "__main__":
    raise SystemExit(main())
