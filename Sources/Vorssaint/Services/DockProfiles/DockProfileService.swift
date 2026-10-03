// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Vorssaint
// Ported from the Dock profiles feature of Notch Sidekick (GPL-3.0) by Fernando Chavarría.

import AppKit
import Combine

/// Keeps the saved Dock profiles and switches the Dock between them. Nothing
/// runs in the background: the Dock is read when a profile list appears and
/// written only when a profile is applied. Main thread only.
final class DockProfileService: ObservableObject {
    static let shared = DockProfileService()

    @Published private(set) var profiles: [DockProfile]
    /// The Dock's apps as last read, to mark the profile it shows.
    @Published private(set) var dockApps: [DockAppEntry] = []
    /// The profile being applied, or the undo in progress when nil with `isWorking`.
    @Published private(set) var applying: UUID?
    @Published private(set) var isWorking = false
    @Published private(set) var outcome: DockProfileOutcome?
    /// The Dock's apps before the last change, kept until the app quits so
    /// that change can be undone. The original tiles are kept as they were.
    @Published private(set) var canUndo = false

    private var previousTiles: [Any]?
    private let queue = DispatchQueue(label: "DockProfileService", qos: .userInitiated)

    private init() {
        profiles = DockProfileSupport.profiles(from: UserDefaults.standard.data(forKey: DefaultsKey.dockProfiles))
    }

    /// Reads the saved profiles, which an imported backup may have changed,
    /// and the Dock's current apps.
    func refresh() {
        let saved = DockProfileSupport.profiles(from: UserDefaults.standard.data(forKey: DefaultsKey.dockProfiles))
        if saved != profiles { profiles = saved }
        let current = DockProfileSupport.apps(inPersistentApps: Self.readTiles())
        if current != dockApps { dockApps = current }
    }

    func isShownInDock(_ profile: DockProfile) -> Bool {
        !profile.apps.isEmpty && DockProfileSupport.dock(dockApps, matches: profile.apps)
    }

    // MARK: Editing

    @discardableResult
    func addProfile(named name: String, apps: [DockAppEntry] = []) -> DockProfile {
        let profile = DockProfile(name: DockProfileSupport.uniqueName(name, among: profiles), apps: apps)
        profiles.append(profile)
        save()
        return profile
    }

    /// A new profile holding what the Dock shows now.
    @discardableResult
    func addProfileFromDock(named name: String) -> DockProfile {
        refresh()
        return addProfile(named: name, apps: dockApps)
    }

    func update(_ profile: DockProfile) {
        guard let index = profiles.firstIndex(where: { $0.id == profile.id }), profiles[index] != profile else { return }
        profiles[index] = profile
        save()
    }

    func delete(_ profile: DockProfile) {
        profiles.removeAll { $0.id == profile.id }
        save()
    }

    private func save() {
        UserDefaults.standard.set(DockProfileSupport.data(for: profiles), forKey: DefaultsKey.dockProfiles)
    }

    /// The entry for an app bundle chosen in a picker.
    static func entry(forAppAt url: URL) -> DockAppEntry? {
        guard let bundle = Bundle(url: url) else { return nil }
        let name = bundle.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String
            ?? bundle.object(forInfoDictionaryKey: "CFBundleName") as? String
            ?? FileManager.default.displayName(atPath: url.path)
        return DockAppEntry(bundleIdentifier: bundle.bundleIdentifier ?? url.path, displayName: name,
                            bundlePath: DockProfileSupport.normalizedPath(url.path))
    }

    // MARK: Applying

    func apply(_ profile: DockProfile) {
        guard AppFeature.dockProfiles.isAvailable, !isWorking else { return }
        let problem = DockProfileSupport.problem(with: profile.apps)
        guard problem.isEmpty else { outcome = .problem(problem); return }
        let tiles = profile.apps.map(DockProfileSupport.tile(for:))
        let expected = profile.apps
        let name = profile.name
        start(applying: profile.id)
        queue.async { [weak self] in
            let before = Self.readTiles()
            let result = Self.write(tiles, expecting: expected)
            DispatchQueue.main.async {
                guard let self else { return }
                if result != .notWritten, let before {
                    self.previousTiles = before
                    self.canUndo = true
                }
                self.finish(result ?? .applied(name))
            }
        }
    }

    /// Puts back the Dock's apps from before the last change, tiles and all.
    func undo() {
        guard let tiles = previousTiles, !isWorking else { return }
        let expected = DockProfileSupport.apps(inPersistentApps: tiles)
        start(applying: nil)
        queue.async { [weak self] in
            let result = Self.write(tiles, expecting: expected)
            DispatchQueue.main.async {
                guard let self else { return }
                if result != .notWritten {
                    self.previousTiles = nil
                    self.canUndo = false
                }
                self.finish(result ?? .restored)
            }
        }
    }

    func dismissOutcome() { outcome = nil }

    private func start(applying id: UUID?) {
        applying = id
        isWorking = true
        outcome = nil
    }

    private func finish(_ result: DockProfileOutcome?) {
        applying = nil
        isWorking = false
        outcome = result
        refresh()
    }

    // MARK: The Dock

    private static func readTiles() -> [Any]? {
        let domain = DockProfileSupport.dockDomain as CFString
        CFPreferencesAppSynchronize(domain)
        return CFPreferencesCopyAppValue(DockProfileSupport.persistentAppsKey as CFString, domain) as? [Any]
    }

    /// Writes the tiles, reads them back, and restarts the Dock so it shows
    /// them. Returns nil when all of that worked.
    private static func write(_ tiles: [Any], expecting apps: [DockAppEntry]) -> DockProfileOutcome? {
        let domain = DockProfileSupport.dockDomain as CFString
        CFPreferencesSetAppValue(DockProfileSupport.persistentAppsKey as CFString, tiles as CFArray, domain)
        guard CFPreferencesAppSynchronize(domain),
              DockProfileSupport.dock(DockProfileSupport.apps(inPersistentApps: readTiles()), matches: apps)
        else { return .notWritten }
        // The Dock reads its preferences only as it starts. A fixed tool and
        // argument: nothing from a profile reaches the command.
        let restart = BoundedProcessRunner.run("/usr/bin/killall", ["Dock"], timeout: 5, maxOutputBytes: 4096)
        return restart.status == 0 ? nil : .notRestarted
    }
}
