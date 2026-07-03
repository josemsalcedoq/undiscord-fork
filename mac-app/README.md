# Undiscord — native macOS app (no Tampermonkey)

A tiny macOS app that embeds a web view, loads the Discord web client, and auto-injects
the Undiscord Multiselect script. It's a self-contained "mini browser with the tool built in" —
no browser extension, no re-pasting, and your login persists between launches.

Everything still runs inside a real logged-in Discord web session, so the safe token-grab
behavior and rate-limit engine are identical to the userscript version.

## Requirements
- macOS 12+
- Swift toolchain (Xcode or Command Line Tools) — you already have Swift 6.2.

## Run it
```sh
cd mac-app
swift run
```
First launch opens a Discord window. **Log in normally.** Once the app loads, the 🗑️ panel
appears bottom-right — same UI as the userscript. Login is remembered next time.

## Build a double-clickable .app (optional)
`swift run` is fine for personal use. To get a real app bundle:
```sh
swift build -c release
```
The binary lands in `.build/release/UndiscordApp`. Wrapping it into a proper `Undiscord.app`
bundle (Info.plist + icon + code signing) is a follow-up if you want to launch it from Finder /
distribute it — ask and I'll add a bundling script.

## How it works
- `WKWebViewConfiguration.websiteDataStore = .default()` → cookies/localStorage persist (stay logged in).
- The script is injected as a `WKUserScript` at `.atDocumentEnd`. App-level injection is **not**
  blocked by Discord's CSP (which is why a bookmarklet doesn't work but this does).
- `Sources/UndiscordApp/undiscord.js` is a **copy** of the root `undiscord-multiselect.user.js`.
  If you edit one, copy it to the other (or ask me to add a build step that syncs them).

## Same warnings apply
Deletes **your own** messages using **your account token**. Automating a user account is against
Discord's ToS regardless of speed. Keep the delays conservative. See the root `README.md`.
