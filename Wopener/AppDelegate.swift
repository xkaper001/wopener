//
//  AppDelegate.swift
//  Wopener
//

import AppKit

// Apple Event constants (FourCharCodes), avoiding a Carbon import.
private let kGURL = AEEventClass(0x4755_524C)        // 'GURL'
private let kDirectObject = AEKeyword(0x2D2D_2D2D)   // '----'

final class AppDelegate: NSObject, NSApplicationDelegate {
    private var didFinishLaunching = false
    private var launchedViaURL = false

    func applicationWillFinishLaunching(_ notification: Notification) {
        // Register early so a cold launch triggered by a link is detected before
        // the main window is created.
        NSAppleEventManager.shared().setEventHandler(
            self,
            andSelector: #selector(handleGetURL(event:reply:)),
            forEventClass: kGURL,
            andEventID: AEEventID(kGURL)
        )
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        didFinishLaunching = true
        // If we launched only to handle a link, don't leave the main window open.
        if launchedViaURL {
            DispatchQueue.main.async { [weak self] in self?.hideMainWindows() }
        }
    }

    /// Clicking the Dock icon brings the main window back.
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        showMainWindow()
        return true
    }

    @objc private func handleGetURL(event: NSAppleEventDescriptor, reply: NSAppleEventDescriptor) {
        guard let string = event.paramDescriptor(forKeyword: kDirectObject)?.stringValue,
              let url = URL(string: string) else { return }
        if !didFinishLaunching { launchedViaURL = true }
        Task { @MainActor in PickerWindowController.shared.present(for: url) }
    }

    // MARK: Main window visibility

    private func mainWindows() -> [NSWindow] {
        NSApp.windows.filter { !($0 is PickerPanel) }
    }

    private func hideMainWindows() {
        mainWindows().forEach { $0.orderOut(nil) }
    }

    private func showMainWindow() {
        mainWindows().forEach { $0.makeKeyAndOrderFront(nil) }
        NSApp.activate(ignoringOtherApps: true)
    }
}
