//
//  ProfileStore.swift
//  Wopener
//
//  Discovers per-profile data for Chromium-family browsers (Chrome, Brave, Edge,
//  Vivaldi, Opera, Chromium…). Each browser keeps a `Local State` JSON listing its
//  profiles under `profile.info_cache`; a profile is launched by passing
//  `--profile-directory=<dir>` to the browser binary.
//
//  Safari has profiles too, but offers no public API/CLI to open a URL in a chosen
//  profile, so it is intentionally not handled here.
//

import Foundation

/// A browser profile: the on-disk directory name and the user-facing display name.
struct BrowserProfile: Hashable {
    let directory: String   // e.g. "Profile 1" — passed as --profile-directory
    let name: String        // e.g. "Work" — shown in the UI
    let avatarURL: URL?     // on-disk Google account photo, if the profile is signed in
}

enum ProfileStore {
    /// Bundle ID → data directory relative to `~/Library/Application Support`.
    private static let chromiumDataDirs: [String: String] = [
        "com.google.Chrome": "Google/Chrome",
        "com.google.Chrome.beta": "Google/Chrome Beta",
        "com.google.Chrome.dev": "Google/Chrome Dev",
        "com.google.Chrome.canary": "Google/Chrome Canary",
        "org.chromium.Chromium": "Chromium",
        "com.brave.Browser": "BraveSoftware/Brave-Browser",
        "com.brave.Browser.beta": "BraveSoftware/Brave-Browser-Beta",
        "com.brave.Browser.nightly": "BraveSoftware/Brave-Browser-Nightly",
        "com.microsoft.edgemac": "Microsoft Edge",
        "com.microsoft.edgemac.Beta": "Microsoft Edge Beta",
        "com.microsoft.edgemac.Dev": "Microsoft Edge Dev",
        "com.microsoft.edgemac.Canary": "Microsoft Edge Canary",
        "com.vivaldi.Vivaldi": "Vivaldi",
        "com.operasoftware.Opera": "com.operasoftware.Opera",
    ]

    /// Profiles for the given browser bundle ID. Empty unless the browser is a known
    /// Chromium variant with more than one profile (a single profile needs no picker
    /// entry of its own — the plain browser entry already launches it).
    static func profiles(forBundleID id: String) -> [BrowserProfile] {
        guard let relativeDir = chromiumDataDirs[id] else { return [] }

        let base = FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent("Library/Application Support")
            .appendingPathComponent(relativeDir)

        guard let data = try? Data(contentsOf: base.appendingPathComponent("Local State")),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let profile = json["profile"] as? [String: Any],
              let cache = profile["info_cache"] as? [String: Any]
        else { return [] }

        var result: [BrowserProfile] = []
        for (directory, value) in cache {
            // Skip stale cache entries whose directory no longer exists on disk.
            guard FileManager.default.fileExists(
                atPath: base.appendingPathComponent(directory).path) else { continue }
            let info = value as? [String: Any]
            let name = info?["name"] as? String ?? directory

            // The Google account photo, when signed in, lives on disk inside the
            // profile dir under the name in `gaia_picture_file_name`. The built-in
            // `avatar_icon` (chrome://theme/IDR_PROFILE_AVATAR_NN) is baked into the
            // browser's resources.pak and not reachable, so it's left to the monogram.
            var avatarURL: URL?
            if let file = info?["gaia_picture_file_name"] as? String, !file.isEmpty {
                let candidate = base.appendingPathComponent(directory).appendingPathComponent(file)
                if FileManager.default.fileExists(atPath: candidate.path) { avatarURL = candidate }
            }
            result.append(BrowserProfile(directory: directory, name: name, avatarURL: avatarURL))
        }

        guard result.count > 1 else { return [] }

        // "Default" first, then alphabetical by display name.
        result.sort {
            if $0.directory == "Default" { return true }
            if $1.directory == "Default" { return false }
            return $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending
        }
        return result
    }
}
