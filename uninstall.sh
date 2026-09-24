#!/bin/bash

INSTALL_DIR="$HOME/.codex-usage-menu"
PLIST="$HOME/Library/LaunchAgents/com.codex.usage.menu.plist"
LABEL="com.codex.usage.menu"

launchctl bootout "gui/$(id -u)/$LABEL" \
    >/dev/null 2>&1 || true

rm -f "$PLIST"
rm -rf "$INSTALL_DIR"

echo "✅ Codex Usage Menu uninstalled."
