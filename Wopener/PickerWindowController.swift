//
//  PickerWindowController.swift
//  Wopener
//

import AppKit
import SwiftUI

/// Borderless panel that can take key focus so the picker receives keystrokes.
final class PickerPanel: NSPanel {
    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { true }
}

@MainActor
final class PickerWindowController {
    static let shared = PickerWindowController()

    private var panel: PickerPanel?

    /// Show the picker for `url`, centered on the screen under the cursor.
    func present(for url: URL) {
        dismiss()

        let screen = screenUnderCursor()
        let panel = PickerPanel(
            contentRect: screen.frame,
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )
        panel.level = .popUpMenu
        panel.isOpaque = false
        panel.backgroundColor = .clear
        panel.hasShadow = false
        panel.isMovable = false
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .transient]

        let overlay = PickerOverlay(
            url: url,
            browsers: BrowserManager.shared.enabledBrowsers,
            onPick: { [weak self] browser in
                BrowserManager.shared.open(url, in: browser)
                self?.dismiss()
            },
            onCancel: { [weak self] in self?.dismiss() }
        )

        let hosting = NSHostingView(rootView: overlay)
        hosting.frame = screen.frame
        panel.contentView = hosting
        panel.setFrame(screen.frame, display: true)

        NSApp.activate(ignoringOtherApps: true)
        panel.makeKeyAndOrderFront(nil)
        self.panel = panel
    }

    func dismiss() {
        panel?.orderOut(nil)
        panel = nil
    }

    private func screenUnderCursor() -> NSScreen {
        let mouse = NSEvent.mouseLocation
        return NSScreen.screens.first { NSMouseInRect(mouse, $0.frame, false) }
            ?? NSScreen.main
            ?? NSScreen.screens[0]
    }
}
