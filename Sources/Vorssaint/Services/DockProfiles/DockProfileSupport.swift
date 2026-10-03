// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Vorssaint
// Ported from the Dock profiles feature of Notch Sidekick (GPL-3.0) by Fernando Chavarría.

import Foundation

extension DefaultsKey {
    /// The saved Dock profiles, as JSON. Part of settings backups.
    static let dockProfiles = "dockProfiles"
}

/// One app icon in a Dock profile.
struct DockAppEntry: Codable, Hashable, Identifiable {
    let id: UUID
    var bundleIdentifier: String
    var displayName: String
    var bundlePath: String

    init(id: UUID = UUID(), bundleIdentifier: String, displayName: String, bundlePath: String) {
        self.id = id
        self.bundleIdentifier = bundleIdentifier
        self.displayName = displayName
        self.bundlePath = bundlePath
    }
}

/// A named, saved set of Dock app icons, left to right.
struct DockProfile: Codable, Hashable, Identifiable {
    let id: UUID
    var name: String
    var apps: [DockAppEntry]

    init(id: UUID = UUID(), name: String, apps: [DockAppEntry]) {
        self.id = id
        self.name = name
        self.apps = apps
    }
}

/// Why a profile cannot be applied as it is.
struct DockProfileProblem: Equatable {
    /// Apps no longer installed where the profile saved them.
    var missing: [DockAppEntry] = []
    /// Apps listed more than once.
    var duplicates: [DockAppEntry] = []

    var isEmpty: Bool { missing.isEmpty && duplicates.isEmpty }
}

/// How applying a profile, or undoing one, ended.
enum DockProfileOutcome: Equatable {
    case applied(String)
    case restored
    case problem(DockProfileProblem)
    /// The preference did not read back as written. Nothing changed.
    case notWritten
    /// The preference changed but the Dock did not restart to show it.
    case notRestarted
}

/// Dock profiles switch the Dock's own app icons between saved sets.
///
/// macOS has no public interface for the Dock's apps. The Dock keeps them in
/// its preferences, `com.apple.dock`, under `persistent-apps`: an array of
/// `file-tile` dictionaries that point at app bundles. That is the format
/// `defaults write` recipes and dockutil use. It is undocumented, so a write
/// is read back and compared before it counts, and only that one key is ever
/// written: folders, files, the recent apps and every other Dock setting
/// live under other keys and stay as they are.
enum DockProfileSupport {
    static let dockDomain = "com.apple.dock"
    static let persistentAppsKey = "persistent-apps"
    /// The Dock keeps Finder first on its own; it is never part of a profile.
    static let finderBundleID = "com.apple.finder"

    static func isEnabled(in defaults: UserDefaults = .standard) -> Bool {
        AppFeature.dockProfiles.isAvailable(in: defaults)
    }

    // MARK: Saved profiles

    static func profiles(from data: Data?) -> [DockProfile] {
        guard let data, let profiles = try? JSONDecoder().decode([DockProfile].self, from: data) else { return [] }
        return profiles
    }

    static func data(for profiles: [DockProfile]) -> Data? {
        try? JSONEncoder().encode(profiles)
    }

    /// A name for a new profile that no other profile has yet: the base
    /// name, then the base name with a number.
    static func uniqueName(_ base: String, among profiles: [DockProfile]) -> String {
        let taken = Set(profiles.map { $0.name.lowercased() })
        guard taken.contains(base.lowercased()) else { return base }
        var number = 2
        while taken.contains("\(base) \(number)".lowercased()) { number += 1 }
        return "\(base) \(number)"
    }

    // MARK: Checking

    static func problem(with apps: [DockAppEntry],
                        exists: (String) -> Bool = { FileManager.default.fileExists(atPath: $0) }) -> DockProfileProblem {
        var seen = Set<String>()
        var problem = DockProfileProblem()
        for app in apps {
            if !seen.insert(normalizedPath(app.bundlePath)).inserted { problem.duplicates.append(app) }
            if !exists(app.bundlePath) { problem.missing.append(app) }
        }
        return problem
    }

    // MARK: The Dock's preference

    /// The `file-tile` for one app. Tiles the Dock writes itself also carry a
    /// cached bookmark, the bundle identifier, a GUID and dates; the Dock
    /// rebuilds those from the URL, as it does for `defaults write` recipes.
    static func tile(for app: DockAppEntry) -> [String: Any] {
        [
            "tile-data": [
                "file-data": [
                    "_CFURLString": URL(fileURLWithPath: app.bundlePath, isDirectory: true).absoluteString,
                    "_CFURLStringType": 15,
                ] as [String: Any],
                "file-label": app.displayName,
                "file-type": 41,
            ] as [String: Any],
            "tile-type": "file-tile",
        ]
    }

    /// The apps in a `persistent-apps` value, left to right. Tiles that are
    /// not apps, such as spacers, are skipped.
    static func apps(inPersistentApps value: Any?) -> [DockAppEntry] {
        guard let tiles = value as? [[String: Any]] else { return [] }
        return tiles.compactMap { tile in
            guard let data = tile["tile-data"] as? [String: Any],
                  let file = data["file-data"] as? [String: Any],
                  let string = file["_CFURLString"] as? String else { return nil }
            let path = (string.hasPrefix("file:") ? URL(string: string)?.path : string).map(normalizedPath)
            guard let path, path.hasSuffix(".app") else { return nil }
            let bundleID = data["bundle-identifier"] as? String ?? ""
            guard bundleID != finderBundleID else { return nil }
            let name = data["file-label"] as? String
                ?? URL(fileURLWithPath: path).deletingPathExtension().lastPathComponent
            return DockAppEntry(bundleIdentifier: bundleID.isEmpty ? path : bundleID, displayName: name, bundlePath: path)
        }
    }

    /// Whether the Dock shows exactly these apps in this order.
    static func dock(_ dockApps: [DockAppEntry], matches apps: [DockAppEntry]) -> Bool {
        dockApps.map { normalizedPath($0.bundlePath) } == apps.map { normalizedPath($0.bundlePath) }
    }

    static func normalizedPath(_ path: String) -> String {
        let standardized = (path as NSString).standardizingPath
        return standardized.count > 1 && standardized.hasSuffix("/") ? String(standardized.dropLast()) : standardized
    }

    // MARK: Editing

    /// Moves the app at `path` so it lands before the app now at `index`, or
    /// at the end when `index` is past the last one. Moving onto itself
    /// changes nothing.
    static func moving(_ path: String, to index: Int, in apps: [DockAppEntry]) -> [DockAppEntry] {
        guard let from = apps.firstIndex(where: { normalizedPath($0.bundlePath) == normalizedPath(path) }) else { return apps }
        var result = apps
        let app = result.remove(at: from)
        let target = from < index ? index - 1 : index
        result.insert(app, at: min(max(0, target), result.count))
        return result
    }

    /// Adds an app before `index`, or at the end. An app already in the
    /// profile is moved there instead, and Finder is never added.
    static func adding(_ app: DockAppEntry, at index: Int? = nil, to apps: [DockAppEntry]) -> [DockAppEntry] {
        guard app.bundleIdentifier != finderBundleID else { return apps }
        let target = index ?? apps.count
        if apps.contains(where: { normalizedPath($0.bundlePath) == normalizedPath(app.bundlePath) }) {
            return moving(app.bundlePath, to: target, in: apps)
        }
        var result = apps
        result.insert(app, at: min(max(0, target), result.count))
        return result
    }
}
