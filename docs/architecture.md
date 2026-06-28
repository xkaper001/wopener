# Architecture

Swift 5, SwiftUI, `MainActor` default isolation. Unsandboxed, Developer ID / direct
distribution. Runs as a background agent (`LSUIElement`) — no Dock icon; the window flips
activation policy to `.regular` while open and back to `.accessory` on close. All source
lives in `Wopener/`.

| File | Role |
|------|------|
| `WopenerApp.swift` | `@main`; single `Window` scene hosting `MainWindowView`. |
| `AppDelegate.swift` | Installs the `kAEGetURL` Apple Event handler; routes URLs to the picker; suppresses the main window on link-triggered cold launch; owns the menu-bar controller. |
| `MenuBarController.swift` | The `NSStatusItem` and its menu (Open Wopener…, Set as Default Browser, Quit). |
| `LoginItem.swift` | `SMAppService.mainApp` wrapper for the open-at-login toggle. |
| `BrowserManager.swift` | `@Observable` singleton. Discovers http handlers, drops self, applies custom order & enabled toggles, opens URLs (optionally in a profile). |
| `BrowserOrderStore.swift` | Persists the custom browser order and per-browser enabled toggles in `UserDefaults`. |
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

## Build & run

```sh
xcodebuild -project Wopener.xcodeproj -scheme Wopener -configuration Debug build
```

Or open `Wopener.xcodeproj` in Xcode and run (⌘R).

To test interception: System Settings ▸ Desktop & Dock ▸ Default web browser → Wopener
(or click **Set as Default Browser** in the app). Then click any link — the picker appears.

There is no automated test target; verify changes by building, setting Wopener as the
default browser, and clicking a link to confirm the picker behaves.
