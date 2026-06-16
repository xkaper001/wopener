//
//  MenuBarController.swift
//  Wopener
//
//  Owns the menu-bar status item and its menu. Wopener runs as a background agent
//  (LSUIElement) with no Dock icon, so the menu bar is the way in: open the settings
//  window, set Wopener as the default browser, or quit. All status-item mechanics live
//  here (mirroring how PickerWindowController owns the picker panel).
//

import AppKit

extension Notification.Name {
    /// Posted when the user toggles the menu-bar icon in the General pane.
    static let wopenerMenuBarVisibilityChanged = Notification.Name("wopenerMenuBarVisibilityChanged")
}

@MainActor
final class MenuBarController: NSObject, NSMenuDelegate {
    private let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

    /// Invoked by the "Open Wopener…" item; wired by the AppDelegate.
    var onOpenSettings: () -> Void = {}

    override init() {
        super.init()
        if let button = statusItem.button {
            let icon = NSImage(named: "MenuBarIcon")
            icon?.isTemplate = true
            icon?.size = NSSize(width: 18, height: 18)
            button.image = icon
        }
        let menu = NSMenu()
        menu.delegate = self
        statusItem.menu = menu

        statusItem.isVisible = MenuBarController.iconVisible
        NotificationCenter.default.addObserver(
            self, selector: #selector(visibilityChanged),
            name: .wopenerMenuBarVisibilityChanged, object: nil
        )
    }

    /// Whether the status item should be shown (defaults to true when unset).
    static var iconVisible: Bool {
        UserDefaults.standard.object(forKey: "showMenuBarIcon") as? Bool ?? true
    }

    @objc private func visibilityChanged() {
        statusItem.isVisible = MenuBarController.iconVisible
    }

    /// Rebuild the menu each time it opens so the default-browser item reflects current state.
    func menuNeedsUpdate(_ menu: NSMenu) {
        menu.removeAllItems()

        let v = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let header = menu.addItem(withTitle: "Wopener \(v)", action: nil, keyEquivalent: "")
        header.isEnabled = false

        if !BrowserManager.shared.isDefaultBrowser() {
            menu.addItem(withTitle: "Set as Default Browser", action: #selector(setDefault), keyEquivalent: "")
                .target = self
        }

        // Latest saved links (already stored newest-first). Clicking reopens the picker.
        let recent = Array(SavedLinksStore.shared.links.prefix(3))
        if !recent.isEmpty {
            menu.addItem(.separator())
            let savedHeader = menu.addItem(withTitle: "Recently Saved", action: nil, keyEquivalent: "")
            savedHeader.isEnabled = false
            for link in recent {
                let item = menu.addItem(withTitle: link.title, action: #selector(openSavedLink(_:)), keyEquivalent: "")
                item.target = self
                item.representedObject = link.url
                item.toolTip = link.url.absoluteString
            }
        }

        menu.addItem(.separator())
        menu.addItem(withTitle: "Open Wopener…", action: #selector(openSettings), keyEquivalent: ",")
            .target = self

        menu.addItem(.separator())
        menu.addItem(withTitle: "Quit Wopener", action: #selector(quit), keyEquivalent: "q")
            .target = self
    }

    @objc private func openSettings() { onOpenSettings() }
    @objc private func setDefault() { BrowserManager.shared.makeDefaultBrowser() }
    @objc private func quit() { NSApp.terminate(nil) }

    @objc private func openSavedLink(_ sender: NSMenuItem) {
        guard let url = sender.representedObject as? URL else { return }
        PickerWindowController.shared.present(for: url)
    }
}
