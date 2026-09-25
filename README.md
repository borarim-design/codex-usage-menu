# Codex Usage Menu

## 🇰🇷 한국어 안내

Codex Usage Menu는 macOS 상단 메뉴바에서 Codex 사용량을 바로 확인할 수 있는 작은 유틸리티입니다.

- 5시간 사용 한도 잔여량 표시
- 주간 사용 한도 잔여량 표시
- 각 한도의 초기화 시간 확인
- 60초마다 자동 새로고침
- Mac 로그인 시 자동 실행
- 기존 Codex CLI 로그인 사용
- OpenAI API Key 불필요

### 설치

Codex CLI가 설치되어 있고 ChatGPT 계정으로 로그인된 상태에서 아래 명령어를 실행하세요.

    curl -fsSL https://raw.githubusercontent.com/borarim-design/codex-usage-menu/main/install.sh | bash

### 알려진 현상

앱 실행 직후 로컬 Codex app server가 준비되는 데 시간이 걸리면 메뉴바에 사용량 대신 `⚠︎` 아이콘만 잠시 표시될 수 있습니다.

대부분 다음 자동 새로고침에서 정상적으로 사용량이 나타나며, 최대 약 60초 정도 걸릴 수 있습니다. 메뉴에서 `Refresh now`를 눌러 직접 다시 조회할 수도 있습니다.

> 이 프로젝트는 비공식 커뮤니티 프로젝트이며 OpenAI의 공식 제품이 아닙니다.

---


A tiny macOS menu bar utility for checking your Codex usage without opening the Usage dashboard.

`◉ 5h 25% · W 64%`

## Features

- 5-hour usage remaining
- Weekly usage remaining
- Reset times
- Refreshes every 60 seconds
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
