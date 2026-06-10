//
//  BrowserOrderStore.swift
//  Wopener
//

import Foundation

/// Persists the user's custom browser order (array of bundle IDs) and the set of
/// disabled browsers in UserDefaults. Newly installed browsers are appended in
/// their A→Z position and enabled by default; uninstalled ones drop.
struct BrowserOrderStore {
    private let orderKey = "browserOrder"
    private let disabledKey = "browserDisabled"

    // MARK: Order

    func save(order: [String]) {
        UserDefaults.standard.set(order, forKey: orderKey)
    }

    private func savedOrder() -> [String] {
        UserDefaults.standard.stringArray(forKey: orderKey) ?? []
    }

    /// Apply the saved order on top of the discovered (A→Z) list.
    func apply(to discovered: [Browser]) -> [Browser] {
        let saved = savedOrder()
        guard !saved.isEmpty else { return discovered }

        var remaining = Dictionary(discovered.map { ($0.id, $0) }, uniquingKeysWith: { first, _ in first })
        var ordered: [Browser] = []
        for id in saved {
            if let browser = remaining.removeValue(forKey: id) { ordered.append(browser) }
        }
        // Append browsers not in the saved order, preserving the A→Z order.
        ordered.append(contentsOf: discovered.filter { remaining[$0.id] != nil })
        return ordered
    }

    // MARK: Disabled set

    func disabledIDs() -> Set<String> {
        Set(UserDefaults.standard.stringArray(forKey: disabledKey) ?? [])
    }

    func saveDisabled(_ ids: Set<String>) {
        UserDefaults.standard.set(Array(ids), forKey: disabledKey)
    }
}
