//
//  SavedLink.swift
//  Wopener
//
//  "Save for later" — links the user stashes inside Wopener instead of opening. Persisted
//  as JSON in UserDefaults, matching the app's UserDefaults-only persistence convention.
//

import Foundation
import SwiftUI

/// A single saved link.
struct SavedLink: Identifiable, Codable, Hashable {
    let id: UUID
    let url: URL
    let dateAdded: Date

    init(url: URL, dateAdded: Date = .now, id: UUID = UUID()) {
        self.id = id
        self.url = url
        self.dateAdded = dateAdded
    }

    /// Bare host, used as the card's heading.
    var host: String { url.host ?? url.absoluteString }

    /// host + path (same shape as the picker's URL chip) — the card's subtitle/title.
    var title: String {
        if let host = url.host {
            let path = url.path
            return path.isEmpty || path == "/" ? host : host + path
        }
        return url.absoluteString
    }
}

@MainActor
@Observable
final class SavedLinksStore {
    static let shared = SavedLinksStore()

    private(set) var links: [SavedLink] = []
    private let key = "savedLinks"

    init() { load() }

    /// Save a URL. De-duped by absolute string; the newest copy moves to the front.
    func add(_ url: URL) {
        links.removeAll { $0.url.absoluteString == url.absoluteString }
        links.insert(SavedLink(url: url), at: 0)
        save()
    }

    func remove(_ link: SavedLink) {
        links.removeAll { $0.id == link.id }
        save()
    }

    func clear() {
        links.removeAll()
        save()
    }

    // MARK: Persistence

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: key),
              let decoded = try? JSONDecoder().decode([SavedLink].self, from: data) else { return }
        links = decoded
    }

    private func save() {
        guard let data = try? JSONEncoder().encode(links) else { return }
        UserDefaults.standard.set(data, forKey: key)
    }
}
