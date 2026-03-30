#!/usr/bin/env python3
"""Generate a secret-safe remediation artifact for OpenClaw Hindsight config."""

from __future__ import annotations

import argparse
import json
from pathlib import Path
from urllib.parse import urlparse


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Write a remediation artifact for OpenClaw Hindsight external-api mode"
    )
    parser.add_argument("--openclaw-config", required=True)
    parser.add_argument("--api-url", required=True)
    parser.add_argument("--output", required=True)
    return parser.parse_args()


def parse_port(api_url: str) -> int:
    parsed = urlparse(api_url)
    if parsed.hostname not in {"127.0.0.1", "localhost"}:
        raise SystemExit(f"api-url must point to localhost, got: {api_url}")
    return parsed.port or 80


def load_plugin_config(path: Path) -> dict:
    payload = json.loads(path.read_text())
    return (
        (((payload.get("plugins") or {}).get("entries") or {}).get("hindsight-openclaw") or {}).get("config")
        or {}
    )


def main() -> int:
    args = parse_args()
    config_path = Path(args.openclaw_config).expanduser()
    output_path = Path(args.output)
    target_port = parse_port(args.api_url)

    plugin_cfg = load_plugin_config(config_path)
    current_url = plugin_cfg.get("hindsightApiUrl")
    current_port = plugin_cfg.get("apiPort")

    payload = {
        "kind": "openclaw-hindsight-remediation",
        "root_cause": "openclaw-hindsight-external-api-mode",
        "config_path": str(config_path),
        "api_url": args.api_url,
        "target_api_port": target_port,
        "current_hindsight_api_url": current_url,
        "current_api_port": current_port,
        "json_patch": [],
        "next_commands": [
            "./perfectmission-website-autodevelopment/automation/memory-sync.sh",
            "./perfectmission-website-autodevelopment/automation/memory-health.sh",
            "./perfectmission-website-autodevelopment/automation/doctor.sh",
        ],
        "notes": [
            "Remove hindsightApiUrl so the plugin stops forcing external-api mode.",
            "Use apiPort so OpenClaw can manage the local Hindsight daemon.",
            "This artifact omits unrelated config and secrets on purpose.",
        ],
    }

    if current_url is not None:
      payload["json_patch"].append(
          {"op": "remove", "path": "/plugins/entries/hindsight-openclaw/config/hindsightApiUrl"}
      )

    if current_port != target_port:
      payload["json_patch"].append(
          {"op": "add" if current_port is None else "replace", "path": "/plugins/entries/hindsight-openclaw/config/apiPort", "value": target_port}
      )

    output_path.write_text(json.dumps(payload, indent=2) + "\n")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
