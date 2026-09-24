#!/bin/bash
set -e

INSTALL_DIR="$HOME/.codex-usage-menu"
PLIST="$HOME/Library/LaunchAgents/com.codex.usage.menu.plist"
LABEL="com.codex.usage.menu"

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

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [[ -f "$SCRIPT_DIR/src/main.swift" ]]; then
    cp "$SCRIPT_DIR/src/main.swift" "$INSTALL_DIR/main.swift"
    cp "$SCRIPT_DIR/src/usage.py" "$INSTALL_DIR/usage.py"
else
    REPO_BASE="https://raw.githubusercontent.com/borarim-design/codex-usage-menu/main"

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

launchctl bootout "gui/$(id -u)/$LABEL" \
    >/dev/null 2>&1 || true

launchctl bootstrap "gui/$(id -u)" "$PLIST"

launchctl kickstart -k \
    "gui/$(id -u)/$LABEL"

echo ""
echo "✅ Codex Usage Menu installed."
echo "Check your macOS menu bar."
echo ""
