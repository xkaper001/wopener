//
//  ProfileBadgeView.swift
//  Wopener
//
//  Circular per-profile avatar shown over a Chromium browser's icon. Uses the
//  signed-in Google account photo when it exists on disk; otherwise falls back to a
//  colored monogram derived from the profile name so every profile still reads as a
//  distinct avatar (matching the built-in chrome://theme avatars we can't extract).
//

import AppKit
import SwiftUI

/// Process-wide cache of decoded avatar photos, keyed by file path. Decoding an NSImage
/// from disk on every SwiftUI body eval is wasteful; the picker re-renders often.
private let avatarCache = NSCache<NSString, NSImage>()

extension BrowserProfile {
    /// The on-disk account photo, decoded once and cached. Nil for profiles not signed in.
    var avatarImage: NSImage? {
        guard let url = avatarURL else { return nil }
        let key = url.path as NSString
        if let cached = avatarCache.object(forKey: key) { return cached }
        guard let image = NSImage(contentsOf: url) else { return nil }
        avatarCache.setObject(image, forKey: key)
        return image
    }

    /// First letter of the display name, used for the monogram fallback.
    var initial: String {
        String(name.trimmingCharacters(in: .whitespaces).first ?? "?").uppercased()
    }

    /// A stable color seeded by the profile directory, so a profile keeps its hue.
    var avatarColor: Color {
        var hash = 5381
        for byte in directory.utf8 { hash = (hash &* 33) &+ Int(byte) }
        let hue = Double(abs(hash) % 360) / 360.0
        return Color(hue: hue, saturation: 0.55, brightness: 0.85)
    }
}

/// A circular profile avatar (account photo or monogram) with a thin light ring.
struct ProfileBadge: View {
    let profile: BrowserProfile
    let size: CGFloat

    var body: some View {
        Group {
            if let img = profile.avatarImage {
                Image(nsImage: img)
                    .resizable()
                    .scaledToFill()
            } else {
                ZStack {
                    Circle().fill(profile.avatarColor)
                    Text(profile.initial)
                        .font(.system(size: size * 0.55, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white)
                }
            }
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
        .overlay(Circle().strokeBorder(.white.opacity(0.9), lineWidth: max(1, size * 0.09)))
        .shadow(color: .black.opacity(0.25), radius: 1, y: 0.5)
    }
}
