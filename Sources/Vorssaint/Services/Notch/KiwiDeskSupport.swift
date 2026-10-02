// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Vorssaint
// Ported from the KiwiDesk feature of Notch Sidekick (GPL-3.0) by Fernando Chavarría.

import Foundation

/// Why the KiwiDesk page can or cannot show spaces. The causes need
/// different fixes, so each one has its own message: a missing command line
/// tool is installed, an unreachable app is started.
enum KiwiDeskAvailability: Equatable {
    /// Nothing was read yet. The page waits instead of claiming no space
    /// has windows.
    case loading
    case available
    /// The `kiwidesk` command line tool is not installed where it is looked for.
    case cliNotFound
    /// The tool ran but could not reach the KiwiDesk app over its socket:
    /// the app is not running.
    case serverUnreachable
    /// The tool failed some other way. Its message is kept for the log.
    case cliError(String)
}

/// An app with at least one window on a space.
struct KiwiDeskApp: Identifiable, Equatable {
    /// The bundle identifier as KiwiDesk reports it, else the app's name.
    let id: String
    /// Absent when KiwiDesk could not tell; actions on the app need it.
    let bundleID: String?
    let name: String
    let isFloating: Bool
    /// The frontmost app, on the focused space only.
    let isActive: Bool
}

/// A KiwiDesk space and the apps with windows on it, front to back.
struct KiwiDeskSpace: Identifiable, Equatable {
    let id: String
    /// The layout mode: bsp, stack, scrolling and so on.
    let mode: String
    let apps: [KiwiDeskApp]
    let isActive: Bool
}

/// What `kiwidesk get_state` prints, as far as the page uses it.
struct KiwiDeskState: Decodable, Equatable {
    struct Space: Decodable, Equatable {
        let id: String
        let mode: String
        let windows: [UInt32]
    }

    struct Window: Decodable, Equatable {
        let id: UInt32
        let app: String
        let bundleID: String?
        let floating: Bool

        enum CodingKeys: String, CodingKey {
            case id, app, floating
            case bundleID = "bundle_id"
        }
    }

    let activeSpace: String?
    let spaces: [Space]
    let windows: [Window]

    enum CodingKeys: String, CodingKey {
        case activeSpace = "active_space"
        case spaces, windows
    }
}

/// The KiwiDesk tiling window manager seen from the island. KiwiDesk is a
/// separate app; everything here talks to it through its `kiwidesk` command
/// line tool, which reaches the app over a socket in the home folder.
enum KiwiDeskSupport {
    /// Homebrew on Apple silicon and on Intel, then the system's own folder.
    /// Other installs are found through the login shell's PATH.
    static let cliCandidates = ["/opt/homebrew/bin/kiwidesk", "/usr/local/bin/kiwidesk", "/usr/bin/kiwidesk"]

    /// Events after which the page reads the state again. Their content is
    /// not parsed: `get_state` stays the one source of truth.
    static let subscribedEvents = ["space_change", "focus_change", "layout_change",
                                   "window_created", "window_destroyed", "window_moved_to_space"]

    /// Every layout `kiwidesk set_mode` accepts, in the order the menu offers them.
    static let layoutModes = ["bsp", "stack", "scrolling", "monocle", "grid", "track", "floating"]

    /// How long one command may take before it is ended.
    static let commandTimeout: TimeInterval = 3
    /// A slow safety read in case the event stream is down. Events normally
    /// arrive at once, and every read starts a process.
    static let refreshInterval: TimeInterval = 15
    /// Rapid events, such as switching through several apps, coalesce into one read.
    static let refreshDebounce: TimeInterval = 0.2
    /// The event stream is reopened after this long, doubling while it keeps
    /// failing at once, up to `maximumReconnectDelay`.
    static let initialReconnectDelay: TimeInterval = 2
    static let maximumReconnectDelay: TimeInterval = 60
    /// A stream that stayed open this long was healthy, so the delay starts over.
    static let healthyStreamLifetime: TimeInterval = 5
    /// A card's height: its header and three rows of app icons.
    static let pageHeight: CGFloat = 128
    /// The state of a few dozen windows is a few kilobytes.
    static let maximumOutputBytes = 1024 * 1024

    static func isEnabled(in defaults: UserDefaults = .standard) -> Bool {
        NotchSupport.isEnabled(in: defaults) && AppFeature.notchKiwiDesk.isAvailable(in: defaults)
            && NotchSupport.modules(in: defaults).contains(.kiwiDesk)
    }

    // MARK: Reading the state

    /// The spaces that have app windows, numbered ones first in order, then
    /// named ones alphabetically. KiwiDesk writes bundle identifiers in
    /// lowercase, so the frontmost app is matched without case, and `name`
    /// gives an app its real, localized name when it is running.
    static func spaces(from state: KiwiDeskState, frontmostBundleID: String?,
                       name: (String) -> String? = { _ in nil }) -> [KiwiDeskSpace] {
        // Untrusted output from another process: a repeated window id must
        // not crash the app, so the first one wins.
        let windows = Dictionary(state.windows.map { ($0.id, $0) }, uniquingKeysWith: { first, _ in first })
        let frontmost = frontmostBundleID?.lowercased()
        return state.spaces.sorted { spaceOrder($0.id, $1.id) }.compactMap { space in
            let isActive = space.id == state.activeSpace
            var seen = Set<String>()
            let apps: [KiwiDeskApp] = space.windows.compactMap { windowID in
                guard let window = windows[windowID] else { return nil }
                let key = window.bundleID ?? window.app
                guard seen.insert(key.lowercased()).inserted else { return nil }
                // An app with windows on several spaces lights up on the focused one only.
                let active = isActive && frontmost != nil && window.bundleID?.lowercased() == frontmost
                return KiwiDeskApp(id: key, bundleID: window.bundleID,
                                   name: window.bundleID.flatMap(name) ?? window.app,
                                   isFloating: window.floating, isActive: active)
            }
            return apps.isEmpty ? nil : KiwiDeskSpace(id: space.id, mode: space.mode, apps: apps, isActive: isActive)
        }
    }

    static func spaceOrder(_ lhs: String, _ rhs: String) -> Bool {
        switch (Int(lhs), Int(rhs)) {
        case let (left?, right?): return left < right
        case (.some, nil): return true
        case (nil, .some): return false
        case (nil, nil): return lhs.localizedStandardCompare(rhs) == .orderedAscending
        }
    }

    /// What a finished `get_state` means for the page.
    static func outcome(status: Int32, timedOut: Bool, output: Data) -> (KiwiDeskAvailability, KiwiDeskState?) {
        let message = String(decoding: output, as: UTF8.self).trimmingCharacters(in: .whitespacesAndNewlines)
        guard !timedOut else { return (.cliError("kiwidesk get_state timed out"), nil) }
        guard status == 0 else {
            // The tool says it cannot connect to ~/.config/KiwiDesk/KiwiDesk.sock
            // when the app is not running.
            return (message.localizedCaseInsensitiveContains("cannot connect") ? .serverUnreachable : .cliError(message), nil)
        }
        guard let state = try? JSONDecoder().decode(KiwiDeskState.self, from: output) else {
            return (.cliError("kiwidesk get_state printed unexpected output"), nil)
        }
        return (.available, state)
    }

    // MARK: The event stream

    /// Takes the complete lines out of `buffer` and returns how many there
    /// were. A partial line stays for the next chunk.
    static func takeCompleteLines(from buffer: inout Data) -> Int {
        guard let last = buffer.lastIndex(of: 0x0A) else { return 0 }
        let count = buffer[...last].reduce(0) { $1 == 0x0A ? $0 + 1 : $0 }
        buffer.removeSubrange(...last)
        return count
    }

    /// The wait before the stream is opened again after it ended.
    static func reconnectDelay(after current: TimeInterval, streamLifetime: TimeInterval) -> TimeInterval {
        streamLifetime >= healthyStreamLifetime
            ? initialReconnectDelay
            : min(max(current, initialReconnectDelay) * 2, maximumReconnectDelay)
    }

    // MARK: Finding the tool

    /// The tool's path from the login shell's answer, which may follow
    /// whatever the shell's profile prints.
    static func pathFromShell(_ output: String, isExecutable: (String) -> Bool) -> String? {
        output.split(whereSeparator: \.isNewline)
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .last { $0.hasPrefix("/") && $0.hasSuffix("/kiwidesk") && isExecutable($0) }
    }

    // MARK: Showing it

    /// A symbol that looks like the layout itself, so the menu reads at a
    /// glance; layouts added to KiwiDesk later get a plain square.
    static func symbol(forMode mode: String) -> String {
        switch mode {
        case "bsp": return "rectangle.split.2x2"
        case "stack": return "square.stack"
        case "scrolling": return "rectangle.split.3x1"
        case "monocle": return "rectangle.center.inset.filled"
        case "grid": return "square.grid.3x3"
        case "track": return "rectangle.grid.3x2"
        case "floating": return "square.on.square"
        default: return "square"
        }
    }
}
