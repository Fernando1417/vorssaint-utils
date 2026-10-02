// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Vorssaint
// Ported from the KiwiDesk feature of Notch Sidekick (GPL-3.0) by Fernando Chavarría.

import AppKit
import Combine
import os

/// Reads the KiwiDesk tiling window manager's spaces for the island and
/// sends it the page's actions. It works only while the page is on screen:
/// one `get_state` when the page opens, a `subscribe` stream whose events
/// trigger another read, and a slow safety read in case the stream is down.
/// Everything runs through the `kiwidesk` command line tool, which needs no
/// permission. Main thread only.
final class KiwiDeskService: ObservableObject {
    static let shared = KiwiDeskService()

    @Published private(set) var spaces: [KiwiDeskSpace] = []
    @Published private(set) var availability: KiwiDeskAvailability = .loading

    private static let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "Vorssaint", category: "KiwiDesk")
    private let queue = DispatchQueue(label: "KiwiDeskService", qos: .utility)

    /// Views on screen that show the spaces.
    private var viewers = 0
    private var cliPath: String?
    private var searchedShell = false
    private var searchingShell = false
    /// A newer read makes an older one's answer stale.
    private var generation = 0
    private var reading: BoundedProcessCancellation?
    private var pendingRead: DispatchWorkItem?
    private var safetyTimer: Timer?
    private var activation: AnyCancellable?

    private var stream: Process?
    private var streamBuffer = Data()
    private var streamOpened: Date?
    private var reconnectDelay = KiwiDeskSupport.initialReconnectDelay
    private var reconnect: DispatchWorkItem?

    private init() {}

    var isAvailable: Bool { availability == .available }

    // MARK: Lifecycle

    /// A view that shows the spaces appeared. Balanced by `stop()`.
    func start() {
        viewers += 1
        guard viewers == 1, KiwiDeskSupport.isEnabled() else { return }
        // Switching apps is the most common change, and it needs no stream.
        activation = NSWorkspace.shared.notificationCenter
            .publisher(for: NSWorkspace.didActivateApplicationNotification)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in self?.scheduleRefresh() }
        safetyTimer = Timer.scheduledTimer(withTimeInterval: KiwiDeskSupport.refreshInterval, repeats: true) { [weak self] _ in
            self?.refresh()
        }
        safetyTimer?.tolerance = KiwiDeskSupport.refreshInterval / 4
        refresh()
    }

    /// A view that showed the spaces went away.
    func stop() {
        viewers = max(0, viewers - 1)
        guard viewers == 0 else { return }
        tearDown()
    }

    /// The feature was uninstalled or the page hidden: everything stops at once.
    func syncWithPreferences() {
        guard !KiwiDeskSupport.isEnabled() else { return }
        tearDown()
    }

    private func tearDown() {
        activation = nil
        safetyTimer?.invalidate()
        safetyTimer = nil
        pendingRead?.cancel()
        pendingRead = nil
        reading?.cancel()
        reading = nil
        generation += 1
        closeStream()
    }

    // MARK: Reading

    private func scheduleRefresh() {
        guard viewers > 0 else { return }
        pendingRead?.cancel()
        let work = DispatchWorkItem { [weak self] in self?.refresh() }
        pendingRead = work
        DispatchQueue.main.asyncAfter(deadline: .now() + KiwiDeskSupport.refreshDebounce, execute: work)
    }

    func refresh() {
        guard viewers > 0 else { return }
        guard let path = resolvedCLIPath() else {
            // A shell search in flight reads again once it answers.
            if !searchingShell { show(.cliNotFound, spaces: []) }
            return
        }
        reading?.cancel()
        generation += 1
        let current = generation
        let cancellation = BoundedProcessCancellation()
        reading = cancellation
        queue.async { [weak self] in
            let result = BoundedProcessRunner.run(path, ["get_state"], timeout: KiwiDeskSupport.commandTimeout,
                                                  maxOutputBytes: KiwiDeskSupport.maximumOutputBytes,
                                                  cancellation: cancellation)
            guard !cancellation.isCancelled else { return }
            let (availability, state) = KiwiDeskSupport.outcome(status: result.status, timedOut: result.timedOut,
                                                                output: result.output)
            DispatchQueue.main.async { self?.finishRead(current, availability: availability, state: state) }
        }
    }

    private func finishRead(_ readGeneration: Int, availability: KiwiDeskAvailability, state: KiwiDeskState?) {
        guard readGeneration == generation, viewers > 0 else { return }
        reading = nil
        guard let state else {
            if case .cliError(let message) = availability {
                Self.logger.error("get_state failed: \(message, privacy: .public)")
            }
            show(availability, spaces: [])
            return
        }
        let running = Dictionary(NSWorkspace.shared.runningApplications.compactMap { app -> (String, NSRunningApplication)? in
            app.bundleIdentifier.map { ($0.lowercased(), app) }
        }, uniquingKeysWith: { first, _ in first })
        let next = KiwiDeskSupport.spaces(
            from: state, frontmostBundleID: NSWorkspace.shared.frontmostApplication?.bundleIdentifier,
            name: { running[$0.lowercased()]?.localizedName })
        show(.available, spaces: next)
        openStreamIfNeeded()
    }

    private func show(_ nextAvailability: KiwiDeskAvailability, spaces nextSpaces: [KiwiDeskSpace]) {
        if availability != nextAvailability { availability = nextAvailability }
        if spaces != nextSpaces { spaces = nextSpaces }
    }

    // MARK: Icons

    private var icons: [String: NSImage] = [:]

    /// The app's own icon, from the running app or from where it is installed.
    func icon(for app: KiwiDeskApp) -> NSImage? {
        guard let bundleID = app.bundleID else { return nil }
        let key = bundleID.lowercased()
        if let icon = icons[key] { return icon }
        let running = NSWorkspace.shared.runningApplications.first { $0.bundleIdentifier?.lowercased() == key }
        let icon = running?.icon
            ?? NSWorkspace.shared.urlForApplication(withBundleIdentifier: bundleID).map { NSWorkspace.shared.icon(forFile: $0.path) }
        if let icon { icons[key] = icon }
        return icon
    }

    // MARK: Actions

    func focusSpace(_ id: String) { send([["focus_space", id]]) }

    func setMode(_ mode: String, space: String) { send([["set_mode", space, mode]]) }

    /// Brings the app forward. Asked again while it is in front, KiwiDesk
    /// cycles through its windows.
    func activate(_ app: KiwiDeskApp) {
        guard let bundleID = app.bundleID else { return }
        send([["pull_or_spawn", bundleID]])
    }

    /// Floating and sticky apply to the focused window, so the app comes forward first.
    func toggleFloating(_ app: KiwiDeskApp) {
        guard let bundleID = app.bundleID else { return }
        send([["pull_or_spawn", bundleID], ["toggle_floating"]])
    }

    func toggleSticky(_ app: KiwiDeskApp) {
        guard let bundleID = app.bundleID else { return }
        send([["pull_or_spawn", bundleID], ["toggle_sticky"]])
    }

    /// Runs the commands in order, then reads the result. A failed action is
    /// logged; only a failed read changes what the page says.
    private func send(_ commands: [[String]]) {
        guard let path = cliPath else { return }
        queue.async { [weak self] in
            for arguments in commands {
                let result = BoundedProcessRunner.run(path, arguments, timeout: KiwiDeskSupport.commandTimeout,
                                                      maxOutputBytes: 64 * 1024)
                guard result.status != 0 else { continue }
                let message = String(decoding: result.output, as: UTF8.self)
                Self.logger.error("\(arguments.joined(separator: " "), privacy: .public) failed: \(message, privacy: .public)")
                break
            }
            DispatchQueue.main.async { self?.scheduleRefresh() }
        }
    }

    // MARK: Finding the tool

    private func resolvedCLIPath() -> String? {
        let files = FileManager.default
        if let cliPath, files.isExecutableFile(atPath: cliPath) { return cliPath }
        cliPath = KiwiDeskSupport.cliCandidates.first { files.isExecutableFile(atPath: $0) }
        if cliPath == nil { searchShellOnce() }
        return cliPath
    }

    /// Installs elsewhere, such as with Nix or a symlink of one's own, are on
    /// the login shell's PATH. Asking it starts a shell, so it happens once
    /// per launch and never on the main thread.
    private func searchShellOnce() {
        guard !searchedShell else { return }
        searchedShell = true
        searchingShell = true
        let shell = ProcessInfo.processInfo.environment["SHELL"].flatMap { $0.hasPrefix("/") ? $0 : nil } ?? "/bin/zsh"
        queue.async { [weak self] in
            let result = BoundedProcessRunner.runInNewSession(shell, ["-l", "-c", "command -v kiwidesk"],
                                                              timeout: KiwiDeskSupport.commandTimeout,
                                                              maxOutputBytes: 64 * 1024)
            let path = result.status == 0
                ? KiwiDeskSupport.pathFromShell(String(decoding: result.output, as: UTF8.self),
                                                isExecutable: FileManager.default.isExecutableFile(atPath:))
                : nil
            DispatchQueue.main.async {
                guard let self else { return }
                self.searchingShell = false
                if let path { self.cliPath = path }
                self.refresh()
            }
        }
    }

    // MARK: The event stream

    private func openStreamIfNeeded() {
        guard stream == nil, reconnect == nil, viewers > 0, let cliPath else { return }
        let process = Process()
        process.executableURL = URL(fileURLWithPath: cliPath)
        process.arguments = ["subscribe"] + KiwiDeskSupport.subscribedEvents
        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = FileHandle.nullDevice
        // Passed through and compared: the page closing and opening quickly can
        // replace this stream before its end is handled.
        process.terminationHandler = { [weak self] ended in
            DispatchQueue.main.async { self?.streamEnded(ended) }
        }
        pipe.fileHandleForReading.readabilityHandler = { [weak self] handle in
            let chunk = handle.availableData
            guard !chunk.isEmpty else { handle.readabilityHandler = nil; return }
            DispatchQueue.main.async { self?.streamReceived(chunk, from: process) }
        }
        do {
            try process.run()
        } catch {
            pipe.fileHandleForReading.readabilityHandler = nil
            Self.logger.error("kiwidesk subscribe did not start: \(error.localizedDescription, privacy: .public)")
            return
        }
        stream = process
        streamOpened = Date()
    }

    private func streamReceived(_ chunk: Data, from process: Process) {
        guard process === stream else { return }
        streamBuffer.append(chunk)
        if KiwiDeskSupport.takeCompleteLines(from: &streamBuffer) > 0 { scheduleRefresh() }
    }

    private func streamEnded(_ process: Process) {
        guard process === stream else { return }
        (process.standardOutput as? Pipe)?.fileHandleForReading.readabilityHandler = nil
        stream = nil
        streamBuffer.removeAll()
        let lifetime = streamOpened.map { Date().timeIntervalSince($0) } ?? 0
        streamOpened = nil
        reconnectDelay = KiwiDeskSupport.reconnectDelay(after: reconnectDelay, streamLifetime: lifetime)
        guard viewers > 0 else { return }
        // KiwiDesk may be restarting, or this version may have no stream at all.
        let work = DispatchWorkItem { [weak self] in
            self?.reconnect = nil
            self?.openStreamIfNeeded()
        }
        reconnect = work
        DispatchQueue.main.asyncAfter(deadline: .now() + reconnectDelay, execute: work)
    }

    private func closeStream() {
        reconnect?.cancel()
        reconnect = nil
        reconnectDelay = KiwiDeskSupport.initialReconnectDelay
        if let stream {
            (stream.standardOutput as? Pipe)?.fileHandleForReading.readabilityHandler = nil
            if stream.isRunning { stream.terminate() }
        }
        stream = nil
        streamOpened = nil
        streamBuffer.removeAll()
    }
}
