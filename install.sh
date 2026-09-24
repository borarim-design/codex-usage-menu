#!/bin/bash
set -euo pipefail

INSTALL_DIR="$HOME/.codex-usage-menu"
PLIST="$HOME/Library/LaunchAgents/com.codex.usage.menu.plist"
LABEL="com.codex.usage.menu"
DOMAIN="gui/$(id -u)"
REPO_BASE="https://raw.githubusercontent.com/borarim-design/codex-usage-menu/main"

echo ""
echo "Codex Usage Menu installer"
echo "--------------------------"

if [[ "$(uname -s)" != "Darwin" ]]; then
    echo "❌ macOS only."
    exit 1
fi

for cmd in python3 swiftc codex; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
        echo "❌ Required command not found: $cmd"
        exit 1
    fi
done

if ! codex login status >/dev/null 2>&1; then
    echo "❌ Codex is not logged in."
    echo "Run: codex login"
    exit 1
fi

mkdir -p "$INSTALL_DIR"
mkdir -p "$HOME/Library/LaunchAgents"

# ./install.sh 로 실행하면 현재 clone의 소스를 사용.
# curl | bash 로 실행하면 GitHub의 최신 소스를 다운로드.
SCRIPT_DIR=""
SOURCE_PATH="${BASH_SOURCE[0]:-}"

if [[ -n "$SOURCE_PATH" && "$SOURCE_PATH" != /dev/fd/* ]]; then
    CANDIDATE_DIR="$(cd "$(dirname "$SOURCE_PATH")" 2>/dev/null && pwd || true)"

    if [[ -f "$CANDIDATE_DIR/src/main.swift" && \
          -f "$CANDIDATE_DIR/src/usage.py" ]]; then
        SCRIPT_DIR="$CANDIDATE_DIR"
    fi
fi

if [[ -n "$SCRIPT_DIR" ]]; then
    echo "→ Installing from local source..."
    cp "$SCRIPT_DIR/src/main.swift" "$INSTALL_DIR/main.swift"
    cp "$SCRIPT_DIR/src/usage.py" "$INSTALL_DIR/usage.py"
else
    echo "→ Downloading latest source..."

    curl -fsSL "$REPO_BASE/src/main.swift" \
        -o "$INSTALL_DIR/main.swift"

    curl -fsSL "$REPO_BASE/src/usage.py" \
        -o "$INSTALL_DIR/usage.py"
fi

echo "→ Compiling menu bar app..."

swiftc "$INSTALL_DIR/main.swift" \
    -framework AppKit \
    -o "$INSTALL_DIR/CodexUsageMenu"

cat > "$PLIST" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN"
"http://www.apple.com/DTDs/PropertyList-1.0.dtd">

<plist version="1.0">
<dict>
    <key>Label</key>
    <string>$LABEL</string>

    <key>ProgramArguments</key>
    <array>
        <string>$INSTALL_DIR/CodexUsageMenu</string>
    </array>

    <key>RunAtLoad</key>
    <true/>

    <key>KeepAlive</key>
    <true/>

    <key>StandardOutPath</key>
    <string>/tmp/codex-usage-menu.out</string>

    <key>StandardErrorPath</key>
    <string>/tmp/codex-usage-menu.err</string>
</dict>
</plist>
PLIST

echo "→ Registering menu bar app..."

# 재설치 시 기존 LaunchAgent를 먼저 완전히 내림
if launchctl print "$DOMAIN/$LABEL" >/dev/null 2>&1; then
    launchctl bootout "$DOMAIN/$LABEL" >/dev/null 2>&1 || true
fi

pkill -f "$INSTALL_DIR/CodexUsageMenu" >/dev/null 2>&1 || true

sleep 1

launchctl bootstrap "$DOMAIN" "$PLIST"
launchctl kickstart -k "$DOMAIN/$LABEL"

echo ""
echo "✅ Codex Usage Menu installed."
echo "Check your macOS menu bar."
echo ""
