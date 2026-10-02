// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Vorssaint

import Foundation

enum NotchKiwiDeskTests {
    static func run(_ suite: TestSuite) {
        stateContracts(suite)
        outcomeContracts(suite)
        streamContracts(suite)
        toolContracts(suite)
        gateContracts(suite)
        stringContracts(suite)
    }

    private static let sample = """
    {"active_space":"2","spaces":[
      {"id":"web","mode":"stack","windows":[7]},
      {"id":"10","mode":"bsp","windows":[]},
      {"id":"2","mode":"bsp","windows":[3,4,5,9],"focused":3},
      {"id":"1","mode":"scrolling","windows":[1,2]}],
     "windows":[
      {"id":1,"app":"Safari","bundle_id":"com.apple.safari","floating":false},
      {"id":2,"app":"Safari","bundle_id":"com.apple.safari","floating":false},
      {"id":3,"app":"Brave Browser","bundle_id":"com.brave.browser","floating":false},
      {"id":4,"app":"Notes","bundle_id":"com.apple.notes","floating":true},
      {"id":5,"app":"Unknown Tool","floating":false},
      {"id":7,"app":"Brave Browser","bundle_id":"com.brave.browser","floating":false},
      {"id":7,"app":"Duplicate","bundle_id":"com.example.duplicate","floating":false}]}
    """

    private static func stateContracts(_ suite: TestSuite) {
        guard let state = try? JSONDecoder().decode(KiwiDeskState.self, from: Data(sample.utf8)) else {
            suite.expect(false, "the get_state sample decodes")
            return
        }
        let spaces = KiwiDeskSupport.spaces(from: state, frontmostBundleID: "com.brave.Browser") {
            $0 == "com.brave.browser" ? "Brave" : nil
        }
        suite.expect(spaces.map(\.id) == ["1", "2", "web"],
                     "numbered spaces come first in order, named ones after, and empty ones are left out")
        suite.expect(spaces.first?.apps.map(\.id) == ["com.apple.safari"],
                     "an app with several windows on a space shows once")
        let focused = spaces.first { $0.id == "2" }
        suite.expect(focused?.isActive == true && spaces.filter(\.isActive).count == 1,
                     "only the active space is marked")
        suite.expect(focused?.apps.map(\.id) == ["com.brave.browser", "com.apple.notes", "Unknown Tool"],
                     "apps keep KiwiDesk's front to back order and a missing window id is skipped")
        suite.expect(focused?.apps.first?.isActive == true && focused?.apps.first?.name == "Brave",
                     "the frontmost app is matched without case and named as it runs")
        suite.expect(spaces.last?.apps.first?.isActive == false,
                     "the same app on another space is not marked")
        suite.expect(focused?.apps[1].isFloating == true && focused?.apps[1].name == "Notes",
                     "a floating window is marked and an app that is not running keeps KiwiDesk's name")
        suite.expect(focused?.apps[2].bundleID == nil,
                     "an app without a bundle identifier has nothing to act on")
        suite.expect(spaces.last?.apps.map(\.id) == ["com.brave.browser"],
                     "a repeated window id keeps its first entry instead of crashing")
        suite.expect(KiwiDeskSupport.spaces(from: state, frontmostBundleID: nil).allSatisfy { space in
                         space.apps.allSatisfy { !$0.isActive }
                     },
                     "nothing is marked when no app is frontmost")
        suite.expect(KiwiDeskSupport.spaceOrder("2", "10") && !KiwiDeskSupport.spaceOrder("10", "2")
                        && KiwiDeskSupport.spaceOrder("9", "code") && KiwiDeskSupport.spaceOrder("code", "web"),
                     "spaces sort by number, then by name")
    }

    private static func outcomeContracts(_ suite: TestSuite) {
        let unreachable = KiwiDeskSupport.outcome(
            status: 1, timedOut: false,
            output: Data("error: cannot connect to ~/.config/KiwiDesk/KiwiDesk.sock".utf8))
        suite.expect(unreachable.0 == .serverUnreachable && unreachable.1 == nil,
                     "a closed KiwiDesk reads as not running, not as an error")
        let failed = KiwiDeskSupport.outcome(status: 2, timedOut: false, output: Data("unknown command\n".utf8))
        suite.expect(failed.0 == .cliError("unknown command"), "any other failure keeps the tool's message")
        suite.expect(KiwiDeskSupport.outcome(status: 0, timedOut: false, output: Data("not json".utf8)).0
                        != .available,
                     "unexpected output is an error rather than an empty list")
        suite.expect(KiwiDeskSupport.outcome(status: -1, timedOut: true, output: Data()).0 != .available,
                     "a tool that hangs is an error")
        let read = KiwiDeskSupport.outcome(status: 0, timedOut: false, output: Data(sample.utf8))
        suite.expect(read.0 == .available && read.1?.spaces.count == 4, "a good answer is the state")
    }

    private static func streamContracts(_ suite: TestSuite) {
        var buffer = Data("{\"event\":\"focus_change\"}\n{\"event\":\"spa".utf8)
        suite.expect(KiwiDeskSupport.takeCompleteLines(from: &buffer) == 1
                        && String(decoding: buffer, as: UTF8.self) == "{\"event\":\"spa",
                     "a complete event triggers a read and a partial one waits")
        buffer.append(Data("ce_change\"}\n\n".utf8))
        suite.expect(KiwiDeskSupport.takeCompleteLines(from: &buffer) == 2 && buffer.isEmpty,
                     "the rest of an event completes it")
        suite.expect(KiwiDeskSupport.takeCompleteLines(from: &buffer) == 0, "an empty stream asks for nothing")
        let start = KiwiDeskSupport.initialReconnectDelay
        let failing = KiwiDeskSupport.reconnectDelay(after: start, streamLifetime: 0.1)
        suite.expect(failing == start * 2, "a stream that ends at once waits longer before the next try")
        suite.expect(KiwiDeskSupport.reconnectDelay(after: 50, streamLifetime: 0) == KiwiDeskSupport.maximumReconnectDelay,
                     "the wait has a ceiling")
        suite.expect(KiwiDeskSupport.reconnectDelay(after: 32, streamLifetime: 60) == start,
                     "a stream that held up starts over at the shortest wait")
    }

    private static func toolContracts(_ suite: TestSuite) {
        let executable: (String) -> Bool = { $0 == "/nix/store/abc/bin/kiwidesk" }
        suite.expect(KiwiDeskSupport.pathFromShell("Welcome back!\n/nix/store/abc/bin/kiwidesk\n", isExecutable: executable)
                        == "/nix/store/abc/bin/kiwidesk",
                     "the tool is found after whatever the shell's profile prints")
        suite.expect(KiwiDeskSupport.pathFromShell("kiwidesk not found", isExecutable: { _ in true }) == nil
                        && KiwiDeskSupport.pathFromShell("/usr/bin/other", isExecutable: { _ in true }) == nil
                        && KiwiDeskSupport.pathFromShell("/missing/kiwidesk", isExecutable: { _ in false }) == nil,
                     "only an executable kiwidesk counts")
        suite.expect(KiwiDeskSupport.layoutModes.allSatisfy { KiwiDeskSupport.symbol(forMode: $0) != "square" }
                        && KiwiDeskSupport.symbol(forMode: "spiral") == "square",
                     "every known layout has its own symbol and a new one still shows")
    }

    private static func gateContracts(_ suite: TestSuite) {
        let domain = "com.vorssaint.tests.notch-kiwidesk"
        let defaults = UserDefaults(suiteName: domain)!
        defaults.removePersistentDomain(forName: domain)
        defer { defaults.removePersistentDomain(forName: domain) }
        for (key, value) in Defaults.registeredDefaults where key.hasPrefix("notch") { defaults.set(value, forKey: key) }
        for (key, value) in AppFeature.availabilityDefaults { defaults.set(value, forKey: key) }
        defaults.set(true, forKey: DefaultsKey.notchEnabled)
        suite.expect(!AppFeature.notchKiwiDesk.installedByDefault && !KiwiDeskSupport.isEnabled(in: defaults)
                        && !NotchSupport.modules(in: defaults).contains(.kiwiDesk),
                     "KiwiDesk waits on the Features page instead of installing itself")
        defaults.set(true, forKey: AppFeature.notchKiwiDesk.availabilityKey)
        suite.expect(KiwiDeskSupport.isEnabled(in: defaults) && NotchSupport.modules(in: defaults).contains(.kiwiDesk),
                     "installing it adds the page")
        defaults.set("kiwiDesk", forKey: DefaultsKey.notchHiddenModules)
        suite.expect(!KiwiDeskSupport.isEnabled(in: defaults), "a hidden page reads nothing")
        defaults.set("", forKey: DefaultsKey.notchHiddenModules)
        defaults.set(false, forKey: DefaultsKey.notchEnabled)
        suite.expect(!KiwiDeskSupport.isEnabled(in: defaults), "KiwiDesk needs the island")
        suite.expect(AppFeature.notchKiwiDesk.group == .dynamicIsland && AppFeature.notchKiwiDesk.permissions.isEmpty
                        && AppFeature.notchKiwiDesk.enabledKeys.isEmpty,
                     "an island extension that asks for no permission and has no switch of its own")
        suite.expect(NotchModule.kiwiDesk.shortcutKey == "k"
                        && NotchSupport.moduleShortcut("K", modules: NotchModule.allCases) == .kiwiDesk,
                     "Option-Command-K opens the page")
    }

    private static func stringContracts(_ suite: TestSuite) {
        for language in AppLanguage.allCases {
            let strings = FeatureStrings.notchKiwiDesk(language)
            let values = Mirror(reflecting: strings).children.compactMap { $0.value as? String }
            suite.expect(values.allSatisfy { !$0.isEmpty && !$0.contains("\u{2014}") },
                         "KiwiDesk text is present and has no em dash (\(language.rawValue))")
            suite.expect(strings.space("3").contains("3") && strings.switchTo("web").contains("web"),
                         "space names fill their formats (\(language.rawValue))")
            suite.expect(strings.loading.hasSuffix("…"), "loading ends with the ellipsis character (\(language.rawValue))")
            suite.expect(!FeatureStrings.notchEditor(language).summary(.kiwiDesk).isEmpty,
                         "the content editor describes the page (\(language.rawValue))")
        }
    }
}
