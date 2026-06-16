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
    private var menuBar: MenuBarController?

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

        // Enable "open at login" by default on first run; respect later user opt-out.
        if !UserDefaults.standard.bool(forKey: "loginItemInitialized") {
            LoginItem.setEnabled(true)
            UserDefaults.standard.set(true, forKey: "loginItemInitialized")
        }

        // Background agent: the menu bar is the only entry point.
        let menuBar = MenuBarController()
        menuBar.onOpenSettings = { [weak self] in self?.showMainWindow() }
        self.menuBar = menuBar

        // Never leave the main window open on launch — it opens on demand from the menu
        // bar. The SwiftUI Window scene still creates the window; we just hide it.
        // Exception: if the menu-bar icon is hidden and this wasn't a link-triggered
        // launch, the menu bar is no longer an entry point — show Settings so the user
        // can reach the toggle again.
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            if !self.launchedViaURL && !MenuBarController.iconVisible {
                self.showMainWindow()
            } else {
                self.hideMainWindows()
            }
        }
    }

    /// Agent app: stay alive in the menu bar after the settings window is closed.
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        false
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
        // As an agent (.accessory) the app can't show a key window or appear in Cmd-Tab.
        // Become a regular app while the settings window is open, then drop back when it
        // closes so we vanish from the Dock again.
        NSApp.setActivationPolicy(.regular)
        guard let window = mainWindows().first else { return }
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)

        observeClose(of: window)
    }

    private var closeObserver: NSObjectProtocol?

    private func observeClose(of window: NSWindow) {
        if let token = closeObserver { NotificationCenter.default.removeObserver(token) }
        closeObserver = NotificationCenter.default.addObserver(
            forName: NSWindow.willCloseNotification, object: window, queue: .main
        ) { _ in
            MainActor.assumeIsolated { _ = NSApp.setActivationPolicy(.accessory) }
        }
    }
}
