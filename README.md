# Codex Usage Menu

A tiny macOS menu bar utility for checking your Codex usage without opening the Usage dashboard.

`◉ 5h 25% · W 64%`

## Features

- 5-hour usage remaining
- Weekly usage remaining
- Reset times
- Refreshes every 60 seconds
- Warning at 20% remaining
- Strong warning at 10% remaining
- Starts automatically when you log in
- Uses your existing Codex CLI login
- No API key required
- Opens the official Usage dashboard from the menu

If ChatGPT for macOS is installed, the utility uses the local ChatGPT menu-bar template icon at runtime. No OpenAI image assets are bundled in this repository.

## Requirements

- macOS
- Python 3
- Swift compiler
- Codex CLI
- Codex logged in with ChatGPT

Check your Codex login:

    codex login status

## Install from a clone

    git clone https://github.com/borarim-design/codex-usage-menu.git
    cd codex-usage-menu
    ./install.sh

## One-line install

After replacing `borarim-design` in `install.sh`:

    curl -fsSL https://raw.githubusercontent.com/borarim-design/codex-usage-menu/main/install.sh | bash

## Uninstall

From the cloned repository:

    ./uninstall.sh

## How it works

Codex Usage Menu talks to the locally installed Codex CLI app server and reads the account rate-limit windows exposed by Codex.

The utility does not require an OpenAI API key and does not send your usage data to a separate server.

Because this relies on the local Codex app-server interface, future Codex CLI updates may require changes to this project.

## Privacy

All usage checks happen locally through your existing Codex CLI login.

## Known issue

On some launches, the initial Codex usage request may time out while the local Codex app server is starting.

When this happens, the menu bar may temporarily show only a `⚠︎` icon instead of the usage percentages.

In most cases, the usage values appear automatically on the next refresh (within about 60 seconds).

You can also click **Refresh now** from the menu bar.

## Disclaimer

This is an unofficial community project. It is not affiliated with, endorsed by, or sponsored by OpenAI.

ChatGPT, Codex, OpenAI, and related marks belong to their respective owners.

## License

MIT
