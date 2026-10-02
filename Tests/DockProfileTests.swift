// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Vorssaint

import Foundation

enum DockProfileTests {
    static func run(_ suite: TestSuite) {
        storageContracts(suite)
        checkingContracts(suite)
        preferenceContracts(suite)
        editingContracts(suite)
        gateContracts(suite)
        stringContracts(suite)
    }

    private static func app(_ name: String, _ bundleID: String? = nil) -> DockAppEntry {
        DockAppEntry(bundleIdentifier: bundleID ?? "com.example.\(name.lowercased())", displayName: name,
                     bundlePath: "/Applications/\(name).app")
    }

    private static func storageContracts(_ suite: TestSuite) {
        let profiles = [DockProfile(name: "Work", apps: [app("Mail"), app("Notes")]), DockProfile(name: "Play", apps: [])]
        suite.expect(DockProfileSupport.profiles(from: DockProfileSupport.data(for: profiles)) == profiles,
                     "profiles survive being saved and read back, ids and order included")
        suite.expect(DockProfileSupport.profiles(from: nil).isEmpty
                        && DockProfileSupport.profiles(from: Data("not json".utf8)).isEmpty,
                     "nothing saved, or something unreadable, is no profiles rather than a crash")
        suite.expect(DockProfileSupport.uniqueName("Profile", among: []) == "Profile"
                        && DockProfileSupport.uniqueName("Work", among: profiles) == "Work 2"
                        && DockProfileSupport.uniqueName("work", among: profiles + [DockProfile(name: "Work 2", apps: [])])
                            == "work 3",
                     "a new profile gets a name no other profile has, ignoring case")
    }

    private static func checkingContracts(_ suite: TestSuite) {
        let mail = app("Mail"), notes = app("Notes"), gone = app("Gone")
        let again = DockAppEntry(bundleIdentifier: "com.example.mail", displayName: "Mail",
                                 bundlePath: "/Applications/Mail.app/")
        let problem = DockProfileSupport.problem(with: [mail, notes, gone, again]) { !$0.contains("Gone") }
        suite.expect(problem.missing == [gone], "an app that is no longer installed is reported")
        suite.expect(problem.duplicates == [again], "an app listed twice is reported, whatever its path spelling")
        suite.expect(DockProfileSupport.problem(with: [mail, notes]) { _ in true }.isEmpty,
                     "a profile of installed apps can be applied")
    }

    private static func preferenceContracts(_ suite: TestSuite) {
        let safari = app("Safari", "com.apple.Safari")
        let tile = DockProfileSupport.tile(for: safari)
        let data = tile["tile-data"] as? [String: Any]
        let file = data?["file-data"] as? [String: Any]
        suite.expect(tile["tile-type"] as? String == "file-tile" && data?["file-type"] as? Int == 41
                        && data?["file-label"] as? String == "Safari"
                        && file?["_CFURLString"] as? String == "file:///Applications/Safari.app/"
                        && file?["_CFURLStringType"] as? Int == 15,
                     "an app becomes the file tile the Dock reads")
        let written = [tile, DockProfileSupport.tile(for: app("Notes"))]
        suite.expect(DockProfileSupport.dock(DockProfileSupport.apps(inPersistentApps: written),
                                             matches: [safari, app("Notes")]),
                     "the tiles written read back as the same apps in the same order")
        let dockWritten: [[String: Any]] = [
            ["tile-type": "file-tile", "tile-data": [
                "bundle-identifier": "com.apple.mail", "file-label": "Mail",
                "file-data": ["_CFURLString": "file:///System/Applications/Mail.app/", "_CFURLStringType": 15],
            ] as [String: Any]],
            ["tile-type": "spacer-tile", "tile-data": [:] as [String: Any]],
            ["tile-type": "file-tile", "tile-data": [
                "bundle-identifier": "com.apple.finder", "file-label": "Finder",
                "file-data": ["_CFURLString": "file:///System/Library/CoreServices/Finder.app/"],
            ] as [String: Any]],
            ["tile-type": "file-tile", "tile-data": [
                "file-data": ["_CFURLString": "file:///Applications/My%20App.app/"],
            ] as [String: Any]],
        ]
        let read = DockProfileSupport.apps(inPersistentApps: dockWritten)
        suite.expect(read.map(\.bundlePath) == ["/System/Applications/Mail.app", "/Applications/My App.app"],
                     "the Dock's own tiles read as apps, skipping spacers and Finder and decoding the path")
        suite.expect(read.first?.bundleIdentifier == "com.apple.mail" && read.first?.displayName == "Mail"
                        && read.last?.displayName == "My App",
                     "a tile without a label is named after its bundle")
        suite.expect(DockProfileSupport.apps(inPersistentApps: nil).isEmpty
                        && DockProfileSupport.apps(inPersistentApps: "garbage").isEmpty,
                     "a missing or unexpected preference reads as no apps")
        suite.expect(!DockProfileSupport.dock(read, matches: Array(read.reversed())),
                     "the same apps in another order are another layout")
    }

    private static func editingContracts(_ suite: TestSuite) {
        let a = app("A"), b = app("B"), c = app("C"), d = app("D")
        let apps = [a, b, c, d]
        func names(_ list: [DockAppEntry]) -> String { list.map(\.displayName).joined() }
        suite.expect(names(DockProfileSupport.moving(c.bundlePath, to: 0, in: apps)) == "CABD",
                     "an app moves before the one at the target")
        suite.expect(names(DockProfileSupport.moving(a.bundlePath, to: 3, in: apps)) == "BCAD",
                     "moving right lands before the target, counting the gap the app leaves")
        suite.expect(names(DockProfileSupport.moving(b.bundlePath, to: 99, in: apps)) == "ACDB"
                        && names(DockProfileSupport.moving(b.bundlePath, to: 1, in: apps)) == "ABCD"
                        && names(DockProfileSupport.moving("/nowhere.app", to: 0, in: apps)) == "ABCD",
                     "past the end means last, onto itself or an unknown app changes nothing")
        suite.expect(names(DockProfileSupport.moving(b.bundlePath, to: 0, in: apps)) == "BACD"
                        && names(DockProfileSupport.moving(b.bundlePath, to: 3, in: apps)) == "ACBD",
                     "Move Left and Move Right shift one place")
        let e = app("E")
        suite.expect(names(DockProfileSupport.adding(e, to: apps)) == "ABCDE"
                        && names(DockProfileSupport.adding(e, at: 1, to: apps)) == "AEBCD",
                     "a new app is added at the end or where it was dropped")
        suite.expect(names(DockProfileSupport.adding(app("C"), at: 0, to: apps)) == "CABD",
                     "adding an app that is already there moves it instead of listing it twice")
        suite.expect(DockProfileSupport.adding(app("Finder", DockProfileSupport.finderBundleID), to: apps) == apps,
                     "Finder is never added: the Dock keeps it first on its own")
    }

    private static func gateContracts(_ suite: TestSuite) {
        let domain = "com.vorssaint.tests.dock-profiles"
        let defaults = UserDefaults(suiteName: domain)!
        defaults.removePersistentDomain(forName: domain)
        defer { defaults.removePersistentDomain(forName: domain) }
        for (key, value) in AppFeature.availabilityDefaults { defaults.set(value, forKey: key) }
        suite.expect(!AppFeature.dockProfiles.installedByDefault && !DockProfileSupport.isEnabled(in: defaults)
                        && !NotchModule.dockProfiles.isAvailable(in: defaults),
                     "Dock profiles wait on the Features page instead of installing themselves")
        defaults.set(true, forKey: AppFeature.dockProfiles.availabilityKey)
        suite.expect(DockProfileSupport.isEnabled(in: defaults) && NotchModule.dockProfiles.isAvailable(in: defaults),
                     "installing the feature offers its island page")
        suite.expect(AppFeature.dockProfiles.group == .windowsDock && AppFeature.dockProfiles.permissions.isEmpty
                        && AppFeature.dockProfiles.enabledKeys.isEmpty,
                     "a Dock feature that needs no permission and no switch of its own")
        suite.expect(AppFeature.dockProfiles.settingsDestination == FeatureSettingsDestination(.dock)
                        && FeatureVisibilitySupport.features(for: .dock).contains(.dockProfiles),
                     "its settings live on the Dock page, which it keeps visible")
        suite.expect(SettingsBackupSupport.exportKeys().contains(DefaultsKey.dockProfiles),
                     "saved profiles travel with a settings backup")
        suite.expect(NotchSupport.moduleShortcut("L", modules: NotchModule.allCases) == .dockProfiles,
                     "Option-Command-L opens the island page")
    }

    private static func stringContracts(_ suite: TestSuite) {
        let problem = DockProfileProblem(missing: [app("Gone")], duplicates: [app("Twice"), app("Twice")])
        for language in AppLanguage.allCases {
            let strings = FeatureStrings.dockProfiles(language)
            let values = Mirror(reflecting: strings).children.compactMap { $0.value as? String }
            suite.expect(values.allSatisfy { !$0.isEmpty && !$0.contains("\u{2014}") },
                         "Dock profile text is present and has no em dash (\(language.rawValue))")
            let message = strings.message(.problem(problem))
            suite.expect(message.contains("Gone") && message.components(separatedBy: "Twice").count == 2,
                         "a problem names each app once (\(language.rawValue))")
            suite.expect(strings.applied("Work").contains("Work") && strings.addApp.hasSuffix("…"),
                         "names fill their formats and Add App ends with an ellipsis (\(language.rawValue))")
            suite.expect(!FeatureStrings.notchEditor(language).summary(.dockProfiles).isEmpty,
                         "the content editor describes the page (\(language.rawValue))")
        }
    }
}
