#!/usr/bin/env python3
"""Best-effort local recovery for the repo autodev Hindsight daemon."""

from __future__ import annotations

import argparse
import json
import os
from pathlib import Path
import socket
import subprocess
import sys
import time
from urllib.parse import urlparse
from urllib.request import urlopen


DEFAULT_PROVIDER_PRIORITY = (
    ("gemini", "GEMINI_API_KEY"),
    ("groq", "GROQ_API_KEY"),
    ("openai", "OPENAI_API_KEY"),
    ("anthropic", "ANTHROPIC_API_KEY"),
)

DEFAULT_MODELS = {
    "gemini": "gemini-2.5-flash",
    "groq": "openai/gpt-oss-20b",
}


def check_health(api_url: str, timeout: float = 2.0) -> bool:
    try:
        with urlopen(f"{api_url.rstrip('/')}/health", timeout=timeout) as response:
            return 200 <= response.status < 300
    except Exception:
        return False


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Recover the local Hindsight API if it is down")
    parser.add_argument("--api-url", required=True)
    parser.add_argument("--openclaw-config", required=True)
    parser.add_argument("--profile", default="autodev-local")
    parser.add_argument("--workspace-home", required=True)
    parser.add_argument("--uv-cache-dir", required=True)
    parser.add_argument("--embed-version", default="latest")
    parser.add_argument("--wait-seconds", type=float, default=90.0)
    parser.add_argument("--json", action="store_true")
    return parser.parse_args()


def load_openclaw_config(path: Path) -> dict:
    if not path.is_file():
        return {}
    try:
        return json.loads(path.read_text())
    except Exception:
        return {}


def select_provider(config: dict) -> tuple[str | None, str | None, str | None, str | None, list[str]]:
    notes: list[str] = []
    plugin_cfg = (((config.get("plugins") or {}).get("entries") or {}).get("hindsight-openclaw") or {}).get("config") or {}
    plugin_provider = plugin_cfg.get("llmProvider")
    plugin_key_env = plugin_cfg.get("llmApiKeyEnv")
    plugin_model = plugin_cfg.get("llmModel")

    if plugin_cfg.get("hindsightApiUrl"):
        notes.append("openclaw plugin config uses hindsightApiUrl, which forces external-api mode and skips local daemon startup")

    if plugin_provider and plugin_key_env:
        value = os.environ.get(plugin_key_env)
        if value:
            return plugin_provider, plugin_key_env, value, plugin_model or DEFAULT_MODELS.get(plugin_provider), notes
        notes.append(f"configured OpenClaw provider {plugin_provider} expects env {plugin_key_env}, but it is not set here")

    env_cfg = config.get("env") or {}
    for provider, env_name in DEFAULT_PROVIDER_PRIORITY:
        value = os.environ.get(env_name)
        if value:
            return provider, env_name, value, DEFAULT_MODELS.get(provider), notes
        value = env_cfg.get(env_name)
        if value:
            notes.append(f"using {env_name} from ~/.openclaw/openclaw.json env block")
            return provider, env_name, value, DEFAULT_MODELS.get(provider), notes

    return None, None, None, None, notes


def run(cmd: list[str], env: dict[str, str]) -> tuple[int, str]:
    completed = subprocess.run(
        cmd,
        env=env,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        text=True,
        check=False,
    )
    return completed.returncode, completed.stdout.strip()


def wait_until_ready(api_url: str, timeout_seconds: float) -> bool:
    deadline = time.time() + timeout_seconds
    while time.time() < deadline:
        if check_health(api_url, timeout=2.0):
            return True
        time.sleep(1.0)
    return False


def launch_daemon(cmd: list[str], env: dict[str, str]) -> subprocess.Popen[str]:
    return subprocess.Popen(
        cmd,
        env=env,
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
        stdin=subprocess.DEVNULL,
        text=True,
        start_new_session=True,
    )


def local_port(url: str) -> int | None:
    parsed = urlparse(url)
    if parsed.hostname not in {"127.0.0.1", "localhost"}:
        return None
    return parsed.port or 80


def main() -> int:
    args = parse_args()
    notes: list[str] = []

    if check_health(args.api_url):
        payload = {"status": "healthy", "api_url": args.api_url, "notes": ["api already reachable"]}
        print(json.dumps(payload) if args.json else "healthy")
        return 0

    port = local_port(args.api_url)
    if port is None:
        payload = {"status": "skipped", "api_url": args.api_url, "notes": ["api url is not local; refusing local recovery"]}
        print(json.dumps(payload) if args.json else "skipped")
        return 0

    config = load_openclaw_config(Path(args.openclaw_config).expanduser())
    provider, env_name, env_value, model, provider_notes = select_provider(config)
    notes.extend(provider_notes)
    if not provider or not env_name or not env_value:
        payload = {
            "status": "failed",
            "api_url": args.api_url,
            "notes": notes + ["no usable LLM provider credentials found for hindsight-embed startup"],
        }
        print(json.dumps(payload) if args.json else "failed")
        return 1

    workspace_home = Path(args.workspace_home)
    uv_cache_dir = Path(args.uv_cache_dir)
    workspace_home.mkdir(parents=True, exist_ok=True)
    uv_cache_dir.mkdir(parents=True, exist_ok=True)

    env = os.environ.copy()
    env["HOME"] = str(workspace_home)
    env["UV_CACHE_DIR"] = str(uv_cache_dir)
    env["HINDSIGHT_API_LLM_PROVIDER"] = provider
    env[env_name] = env_value
    env["HINDSIGHT_API_LLM_API_KEY"] = env_value
    if model:
        env["HINDSIGHT_API_LLM_MODEL"] = model

    embed_cmd = ["uvx", f"hindsight-embed@{args.embed_version}"]
    create_cmd = embed_cmd + [
        "profile",
        "create",
        args.profile,
        "--merge",
        "--port",
        str(port),
        "--env",
        f"HINDSIGHT_API_LLM_PROVIDER={provider}",
        "--env",
        f"HINDSIGHT_API_LLM_API_KEY={env_value}",
    ]
    if model:
        create_cmd.extend(["--env", f"HINDSIGHT_API_LLM_MODEL={model}"])
    start_cmd = embed_cmd + ["daemon", "--profile", args.profile, "start"]

    create_code, create_output = run(create_cmd, env)
    if create_code != 0:
        payload = {
            "status": "failed",
            "api_url": args.api_url,
            "notes": notes + ["profile creation failed"],
            "output": create_output,
        }
        print(json.dumps(payload) if args.json else "failed")
        return 1

    launcher = launch_daemon(start_cmd, env)
    deadline = time.time() + args.wait_seconds
    ready = False
    while time.time() < deadline:
      if check_health(args.api_url, timeout=2.0):
        ready = True
        break
      exit_code = launcher.poll()
      if exit_code is not None and exit_code != 0:
        break
      time.sleep(1.0)

    payload = {
        "status": "recovered" if ready else "failed",
        "api_url": args.api_url,
        "provider": provider,
        "model": model,
        "profile": args.profile,
        "notes": notes,
        "port_open": ready,
    }
    launcher_exit_code = launcher.poll()
    if launcher_exit_code is not None:
        payload["launcher_exit_code"] = launcher_exit_code

    print(json.dumps(payload) if args.json else payload["status"])
    return 0 if ready else 1


if __name__ == "__main__":
    raise SystemExit(main())
