//
//  BrowserManager.swift
//  Wopener
//

import AppKit
import SwiftUI

/// A browser installed on the system that can handle http/https URLs. A browser with
/// multiple profiles is represented as one `Browser` per profile (each with its own
/// `id`, number, toggle and order slot).
struct Browser: Identifiable, Hashable {
    let id: String          // bundle id, or "bundleID::<profile dir>" for a profile variant
    let bundleID: String
    let name: String        // browser name, or "Browser — Profile" for a profile variant
    let appURL: URL
    let profile: BrowserProfile?
    let icon: NSImage

    static func == (lhs: Browser, rhs: Browser) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
}

@MainActor
@Observable
final class BrowserManager {
    static let shared = BrowserManager()

    private(set) var browsers: [Browser] = []
    private(set) var disabledIDs: Set<String> = []
    private let store = BrowserOrderStore()
    private let selfBundleID = Bundle.main.bundleIdentifier ?? "dev.xkaper.Wopener"

    private static let probeURL = URL(string: "https://example.com")!

    init() {
        disabledIDs = store.disabledIDs()
        refresh()
    }

    /// Browsers shown in the picker — ordered, with disabled ones filtered out.
    var enabledBrowsers: [Browser] {
        browsers.filter { !disabledIDs.contains($0.id) }
    }

    func isEnabled(_ browser: Browser) -> Bool {
        !disabledIDs.contains(browser.id)
    }

    /// Toggle a browser on/off in the picker. Order is preserved.
    func setEnabled(_ browser: Browser, _ enabled: Bool) {
        if enabled { disabledIDs.remove(browser.id) }
        else { disabledIDs.insert(browser.id) }
        store.saveDisabled(disabledIDs)
    }

    /// Discover installed http/https handlers, drop Wopener itself, sort A→Z, then
    /// apply the user's saved custom order.
    func refresh() {
        let appURLs = NSWorkspace.shared.urlsForApplications(toOpen: Self.probeURL)
        var found: [Browser] = []
        for appURL in appURLs {
            guard let bid = Bundle(url: appURL)?.bundleIdentifier, bid != selfBundleID else { continue }
            let name = FileManager.default.displayName(atPath: appURL.path)
                .replacingOccurrences(of: ".app", with: "")

            let icon = NSWorkspace.shared.icon(forFile: appURL.path)
            let profiles = ProfileStore.profiles(forBundleID: bid)
            if profiles.isEmpty {
                found.append(Browser(id: bid, bundleID: bid, name: name, appURL: appURL,
                                     profile: nil, icon: icon))
            } else {
                for profile in profiles {
                    found.append(Browser(id: "\(bid)::\(profile.directory)", bundleID: bid,
                                         name: "\(name) — \(profile.name)", appURL: appURL,
                                         profile: profile, icon: icon))
                }
            }
        }
        found.sort { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
        browsers = store.apply(to: found)
    }

    /// Open the URL in the chosen browser (and profile, if any).
    func open(_ url: URL, in browser: Browser) {
        // A profile launch must hit the browser binary directly with
        // `--profile-directory=`: NSWorkspace's launch arguments are ignored when the
        // browser is already running, but the binary forwards args to the live
        // instance and respects the profile.
        if let profile = browser.profile,
           let exec = Bundle(url: browser.appURL)?.executableURL {
            let process = Process()
            process.executableURL = exec
            process.arguments = ["--profile-directory=\(profile.directory)", url.absoluteString]
            do { try process.run() } catch { fallbackOpen(url, in: browser) }
            return
        }
        fallbackOpen(url, in: browser)
    }

    private func fallbackOpen(_ url: URL, in browser: Browser) {
        NSWorkspace.shared.open([url], withApplicationAt: browser.appURL,
                                configuration: NSWorkspace.OpenConfiguration())
    }

    /// Reorder browsers (drag in the main window) and persist.
    func move(from source: IndexSet, to destination: Int) {
        browsers.move(fromOffsets: source, toOffset: destination)
        store.save(order: browsers.map(\.id))
    }

    // MARK: Default-browser status

    /// True when Wopener is the system default http handler.
    func isDefaultBrowser() -> Bool {
        guard let appURL = NSWorkspace.shared.urlForApplication(toOpen: Self.probeURL),
              let bid = Bundle(url: appURL)?.bundleIdentifier else { return false }
        return bid == selfBundleID
    }

    /// Ask macOS to make Wopener the default browser. This surfaces a system
    /// confirmation dialog — there is no silent supported API.
    func makeDefaultBrowser() {
        let selfURL = Bundle.main.bundleURL
        for scheme in ["http", "https"] {
            NSWorkspace.shared.setDefaultApplication(at: selfURL, toOpenURLsWithScheme: scheme)
        }
    }
}
