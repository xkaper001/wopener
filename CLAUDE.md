# Wopener

macOS default-browser interceptor with a Liquid Glass picker. When Wopener is the
system default browser, clicking any `http`/`https` link shows a centered glass
picker so you choose which real browser opens it.

- Bundle: `dev.xkaper.Wopener` · Target: macOS 26.5 · Swift 5, `MainActor` default isolation
- Unsandboxed (`ENABLE_APP_SANDBOX = NO`), Developer ID / direct distribution
- Background agent (`LSUIElement` in `Info.plist`): no Dock icon; the menu-bar status
  item is the entry point. The main window opens on demand (temporarily flips activation
  policy to `.regular`, back to `.accessory` on close).
- Opens at login by default via `SMAppService` (`LoginItem.swift`); user can toggle in
  General pane or disable in System Settings ▸ Login Items.

## Architecture (files in `Wopener/`)

- `WopenerApp.swift` — `@main`. `@NSApplicationDelegateAdaptor(AppDelegate.self)`; one
  `Window("Wopener", id: "main")` scene hosting `MainWindowView`.
- `AppDelegate.swift` — installs the `kAEGetURL` Apple Event handler (`'GURL'` =
  `0x4755524C`) in `applicationWillFinishLaunching`. On URL → `PickerWindowController`.
  Creates the `MenuBarController`, enables open-at-login on first run, and always hides
  the main window on launch (the agent has no auto-shown window). `showMainWindow()` is
  invoked from the menu bar.
- `MenuBarController.swift` — owns the `NSStatusItem` and its menu (Open Wopener…, Set as
  Default Browser when not default, Quit). Calls back to `AppDelegate` to show settings.
- `LoginItem.swift` — `SMAppService.mainApp` wrapper (`isEnabled`, `setEnabled(_:)`).
- `BrowserManager.swift` — `@MainActor @Observable` singleton. Discovers http handlers
  via `NSWorkspace.urlsForApplications(toOpen:)`, drops self, sorts A→Z, applies custom
  order. `open(_:in:)`, `move(from:to:)`, `isDefaultBrowser()`, `makeDefaultBrowser()`.
- `BrowserOrderStore.swift` — persists custom browser order (bundle-ID array) and
  per-browser enabled toggles in `UserDefaults`; new browsers append A→Z, uninstalled drop.
- `ProfileStore.swift` — discovers per-profile entries for Chromium-family browsers by
  reading each browser's `Local State` JSON (`profile.info_cache`); launches a profile
  via `--profile-directory=<dir>`. Resolves the signed-in account photo when present.
  Safari profiles are intentionally unsupported (no public per-profile open API).
- `ProfileBadgeView.swift` — `ProfileBadge`: circular badge showing the account photo or
  a monogram, overlaid on a browser's icon.
- `PickerPosition.swift` — the 9 on-screen anchor positions (center/edges/corners) for
  the picker cluster within the full-screen overlay.
- `SavedLink.swift` — `SavedLink` model + `SavedLinksStore` (`@Observable` singleton),
  persisted as JSON in `UserDefaults`. "Save for later": stash a link instead of opening.
- `PickerWindowController.swift` — `PickerPanel` (borderless `NSPanel`, `canBecomeKey`),
  full-screen on the display under the cursor, `.popUpMenu` level, clear background.
  `present(for:)` shows the picker for a URL. **All window/panel mechanics live here.**
- `BrowserPickerView.swift` — `PickerOverlay`: dimmed backdrop (tap = cancel), detached
  glass URL chip (tap = copy), glass card of icon tiles with number badges, spring
  entry, hover/keyboard selection. Keys: `1`–`9` open that browser, `←`/`→` move
  selection, `↩` opens selected, `Esc` cancels, save key (default `` ` ``) stashes the
  link (`.onKeyPress`). **All picker UI here.**
- `MainWindowView.swift` — `NavigationSplitView` sidebar with four panes
  (`SettingsCategory`): Saved, Browsers, General, About.
- `SavedLinksPane.swift` — grid of glass cards for saved links; click reopens the picker.
- `BrowsersPane.swift` — default-browser status + Set-as-Default; drag-reorder and
  per-browser enable toggles for the discovered browser list.
- `GeneralPane.swift` — picker preferences: number hints, URL chip position, picker
  location, and rebindable save key.
- `AboutPane.swift` — app info, version, and the GitHub repo link.
- `Info.plist` (in `Wopener/`) — `CFBundleURLTypes` http+https, rank Owner. Kept out
  of Copy Bundle Resources via a `PBXFileSystemSynchronizedBuildFileExceptionSet`
  (`membershipExceptions = Info.plist`).

## Build & run

```sh
xcodebuild -project Wopener.xcodeproj -scheme Wopener -configuration Debug build
```

Run from Xcode. To test interception: System Settings ▸ Desktop & Dock ▸ Default web
browser → Wopener (or click **Set as Default Browser** in the app). Then click any
link — the picker appears.

## Conventions & gotchas

- `PBXFileSystemSynchronizedRootGroup` is active: **drop new `.swift` files into
  `Wopener/`** and they auto-compile — no `.pbxproj` edits. (Non-source files added to
  `Wopener/`, like `Info.plist`, need a `membershipExceptions` entry on the synced
  group or they land in Copy Bundle Resources.)
- Picker design is **glass-first** (`.glassEffect`, `GlassEffectContainer`). For any
  SwiftUI / Liquid Glass API question, use **context7** (`/avdlee/swiftui-agent-skill`),
  not the local liquid-glass skill.
- **Always show the picker** — no routing memory, no per-domain rules. Don't add rule
  storage; the only persisted state is browser order/toggles, saved links, and picker prefs.
- Launch context: a link-triggered cold launch must NOT show the main window
  (`AppDelegate.launchedViaURL`). Don't regress this.
- Must filter Wopener itself out of the discovered browser list.
- Setting the default browser has **no silent API**; `setDefaultApplication(at:
  toOpenURLsWithScheme:)` surfaces a system confirmation dialog.
- No test target exists — verification is build + manual (set default, click a link).
- Licensed under **Apache 2.0** (`LICENSE` + `NOTICE` at repo root). User-facing docs
  live in `README.md`.
