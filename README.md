<div align="center">

# Wopener

**Your link, your choice.** 🪄

A macOS default-browser interceptor with a Liquid Glass picker. Set Wopener as your
system default browser, and every link click pops a centered glass picker so *you*
decide which real browser opens it — no rules to babysit, no routing memory to
second-guess.

[![License](https://img.shields.io/badge/license-Apache%202.0-blue.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/platform-macOS%2026%2B-lightgrey.svg)](#requirements)
[![Swift](https://img.shields.io/badge/Swift-5-orange.svg)](https://swift.org)

</div>

---

## Why

macOS only lets you pick *one* default browser. If you use Chrome for work, Safari for
personal, and a private browser for the rest, every link is a wrong guess. Wopener
becomes the default, intercepts the click, and shows a picker instead of committing for
you.

## Features

- **Glass picker on every link** — a borderless full-screen overlay with a card of
  browser tiles, built on Apple's Liquid Glass (`.glassEffect`).
- **Keyboard-first** — `1`–`9` open that browser instantly, `←`/`→` move the selection,
  `↩` opens the highlighted one, `Esc` cancels.
- **Per-profile entries** — Chromium-family browsers (Chrome, Brave, Edge, Vivaldi,
  Opera…) expand into one tile per profile, with the signed-in account photo as a badge.
- **Save for later** — press the save key (default `` ` ``) in the picker to stash a
  link in the **Saved** tab instead of opening it. Reopen the picker for it anytime.
- **Reorderable & toggleable browsers** — drag to set the number-key order; switch any
  browser off to hide it from the picker.
- **Configurable picker** — choose where it anchors on screen (9 positions), where the
  URL chip sits, whether number hints show, and which key saves.
- **Copy the link** — tap the detached URL chip to copy without opening anything.
- **No routing memory by design** — Wopener never silently picks for you. The only
  persisted state is your browser order, toggles, saved links, and preferences.

## Requirements

- macOS 26.5 or later
- Xcode 26+ (to build from source)

## Install

### Build from source

```sh
git clone https://github.com/xkaper001/wopener.git
cd wopener
xcodebuild -project Wopener.xcodeproj -scheme Wopener -configuration Debug build
```

Or open `Wopener.xcodeproj` in Xcode and run (⌘R).

### Set as default browser

1. Launch Wopener.
2. Go to the **Browsers** tab → **Set as Default Browser** (this surfaces the standard
   macOS confirmation dialog), *or* set it manually in **System Settings ▸ Desktop &
   Dock ▸ Default web browser → Wopener**.
3. Click any link — the picker appears.

## Usage

| Action | How |
|--------|-----|
| Open a link in a browser | Click its tile, or press its number key (`1`–`9`) |
| Move selection | `←` / `→` |
| Open highlighted browser | `↩` |
| Cancel | `Esc`, or click the dimmed backdrop |
| Copy the link | Click the URL chip |
| Save for later | Press the save key (default `` ` ``), or click the Save tile |

Manage everything from the main window's four tabs: **Saved**, **Browsers**,
**General**, **About**.

## Architecture

Swift 5, SwiftUI, `MainActor` default isolation. Unsandboxed, Developer ID / direct
distribution. All source lives in `Wopener/`.

| File | Role |
|------|------|
| `WopenerApp.swift` | `@main`; single `Window` scene hosting `MainWindowView`. |
| `AppDelegate.swift` | Installs the `kAEGetURL` Apple Event handler; routes URLs to the picker; suppresses the main window on link-triggered cold launch. |
| `BrowserManager.swift` | `@Observable` singleton. Discovers http handlers, drops self, applies custom order & enabled toggles, opens URLs (optionally in a profile). |
| `BrowserOrderStore.swift` | Persists the custom browser order in `UserDefaults`. |
| `ProfileStore.swift` | Reads Chromium `Local State` to discover per-profile launch dirs and account photos. |
| `ProfileBadgeView.swift` | Circular profile badge (account photo or monogram). |
| `PickerPosition.swift` | The 9 on-screen anchor positions for the picker. |
| `SavedLink.swift` | `SavedLink` model + `SavedLinksStore` (JSON in `UserDefaults`). |
| `PickerWindowController.swift` | The borderless `NSPanel` mechanics — full-screen, pop-up-menu level, clear background. |
| `BrowserPickerView.swift` | The picker UI — backdrop, URL chip, glass tile card, hover/keyboard selection. |
| `MainWindowView.swift` | Sidebar-navigated main window. |
| `SavedLinksPane.swift` · `BrowsersPane.swift` · `GeneralPane.swift` · `AboutPane.swift` | The four main-window tabs. |

The picker UI is **glass-first** — `GlassEffectContainer` + `.glassEffect`. Only
`http`/`https` are intercepted (`CFBundleURLTypes` in `Info.plist`).

> A `PBXFileSystemSynchronizedRootGroup` is active: new `.swift` files dropped into
> `Wopener/` auto-compile — no `.pbxproj` edits needed.

## Contributing

Issues and pull requests are welcome — come tinker. ✨ By contributing you agree your
contributions are licensed under the project's Apache 2.0 license.

There is no automated test target; verify changes by building, setting Wopener as the
default browser, and clicking a link to confirm the picker behaves.

## License

Licensed under the [Apache License 2.0](LICENSE). See [`NOTICE`](NOTICE) for attribution.

```
Copyright 2026 xkaper001
```

Made by [@xkaper](https://github.com/xkaper001).
