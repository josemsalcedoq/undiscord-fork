# Undiscord — native macOS app

Self-contained macOS app that bulk-deletes **your own** Discord messages. It embeds
Discord's web client in a `WKWebView` and injects a panel that discovers your
**DMs, friends, servers**, and (via data-package import) **every conversation you've ever had** —
with checkbox multiselect. Everything runs inside your real logged-in session.

## Requirements
- macOS 12+
- Swift toolchain (Xcode or Command Line Tools). Node 18+ only to run the JS tests.

## Run (dev)
```sh
swift run
```

## Build artifacts
```sh
./bundle.sh     # -> Undiscord.app (icon + ad-hoc signature)
./make-dmg.sh   # -> Undiscord.dmg (drag-to-Applications installer)
```

## Tests
```sh
swift test                        # Swift: data-package parser (CSV/JSON, fixtures)
node --test js-tests/*.test.js    # JS: engine rate-limit / search / delete / id-list, mocked fetch
```
CI runs both on every push/PR (`.github/workflows/ci.yml`). Tagging `v*` builds a DMG and
publishes a GitHub Release (`.github/workflows/release.yml`).

## Data-package import (full history)
Discord's API only lists **currently open** DMs. To reach closed DMs and left groups, request
your data in **Discord → Settings → Data & Privacy → Request all of my Data** (arrives in a few
days). In the app: **Imported** tab → *Import Data Package…* (or File → Import Data Package…),
pick the `.zip`. The parser reads `messages/` and lists every DM/group with its message count;
deletion goes straight by message id (no search needed).

## How it works
- `WKWebViewConfiguration.websiteDataStore = .default()` → login persists.
- The panel (`Sources/UndiscordApp/undiscord.js`) is injected as a `WKUserScript` (not blocked by
  Discord's CSP). It also exports its engine for Node tests.
- A native bridge (`WKScriptMessageHandler`) handles data-package import; parsing lives in the pure
  `UndiscordCore` library so it's unit-testable.

## Layout
- `Sources/UndiscordApp/main.swift` — window, web view, dialogs, import bridge.
- `Sources/UndiscordApp/undiscord.js` — panel UI + rate-limited delete engine (single source of truth).
- `Sources/UndiscordCore/PackageParser.swift` — pure data-package parser.
- `Tests/…` (Swift), `js-tests/…` (JS) — tests. `icon/make-icon.swift` — icon generator.

## Rate limiting
Defaults 30000 ms search / 1000 ms delete, with adaptive 429 backoff. **Hard minimums are
enforced** — search ≥ 2000 ms, delete ≥ 700 ms — because faster traffic gets rate-limited and looks
automated. The panel warns if you try to go lower.

## Warnings
Deletes **your own** messages using **your account token**. Automating a user account is against
Discord's ToS and carries a ban risk regardless of speed.
