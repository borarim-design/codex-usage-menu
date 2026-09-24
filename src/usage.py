import subprocess
import json
import select
import time
import shutil
import os


def find_codex():
    path = shutil.which("codex")
    if path:
        return path

    candidates = [
        "/opt/homebrew/bin/codex",
        "/usr/local/bin/codex",
        os.path.expanduser("~/.local/bin/codex"),
        os.path.expanduser("~/.npm-global/bin/codex"),
    ]

    for path in candidates:
        if os.path.isfile(path) and os.access(path, os.X_OK):
            return path

    try:
        path = subprocess.check_output(
            ["/bin/zsh", "-lc", "command -v codex"],
            text=True,
            stderr=subprocess.DEVNULL,
        ).strip()
        if path:
            return path
    except Exception:
        pass

    raise RuntimeError("Codex CLI를 찾을 수 없습니다.")


def main():
    codex = find_codex()

    p = subprocess.Popen(
        [codex, "app-server"],
        stdin=subprocess.PIPE,
        stdout=subprocess.PIPE,
        stderr=subprocess.DEVNULL,
        text=True,
        bufsize=1,
    )

    def send(data):
        p.stdin.write(json.dumps(data) + "\n")
        p.stdin.flush()

    def wait_for_id(target_id, timeout=20):
        end = time.time() + timeout

        while time.time() < end:
            ready, _, _ = select.select([p.stdout], [], [], 1)

            if not ready:
                continue

            line = p.stdout.readline()
            if not line:
                continue

            try:
                data = json.loads(line)
            except Exception:
                continue

            if data.get("id") == target_id:
                return data

        raise TimeoutError("Codex 응답 시간 초과")

    try:
        send({
            "jsonrpc": "2.0",
            "id": 1,
            "method": "initialize",
            "params": {
                "clientInfo": {
                    "name": "codex-usage-menu",
                    "title": "Codex Usage Menu",
                    "version": "1.0.0"
                },
                "capabilities": {
                    "experimentalApi": True
                }
            }
        })

        init = wait_for_id(1)

        if "error" in init:
            raise RuntimeError(str(init["error"]))

        send({
            "jsonrpc": "2.0",
            "method": "initialized",
            "params": {}
        })

        send({
            "jsonrpc": "2.0",
            "id": 2,
            "method": "account/rateLimits/read",
            "params": {}
        })

        response = wait_for_id(2)

        if "error" in response:
            raise RuntimeError(str(response["error"]))

        result = response.get("result", {})
        by_id = result.get("rateLimitsByLimitId") or {}
        limits = by_id.get("codex") or result.get("rateLimits") or {}

        five_hour = None
        weekly = None

        for window in [limits.get("primary"), limits.get("secondary")]:
            if not window:
                continue

            duration = window.get("windowDurationMins")

            if duration == 300:
                five_hour = window
            elif duration == 10080:
                weekly = window

        def remaining(window):
            if not window:
                return None

            used = window.get("usedPercent")

            if used is None:
                return None

            return max(0, min(100, 100 - float(used)))

        print(json.dumps({
            "fiveRemaining": remaining(five_hour),
            "fiveReset": five_hour.get("resetsAt") if five_hour else None,
            "weeklyRemaining": remaining(weekly),
            "weeklyReset": weekly.get("resetsAt") if weekly else None,
            "error": None
        }))

    except Exception as e:
        print(json.dumps({
            "fiveRemaining": None,
            "fiveReset": None,
            "weeklyRemaining": None,
            "weeklyReset": None,
            "error": str(e)
        }))

    finally:
        try:
            p.terminate()
        except Exception:
            pass


main()
