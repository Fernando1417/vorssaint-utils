// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Vorssaint
// Ported from the Dock profiles feature of Notch Sidekick (GPL-3.0) by Fernando Chavarría.

import AppKit
import SwiftUI

/// The Dock Profiles card on the Dock page: make profiles, put their apps in
/// order and apply one.
struct DockProfilesSettingsCard: View {
    @ObservedObject private var service = DockProfileService.shared
    @ObservedObject private var l10n = L10n.shared
    private var text: DockProfileStrings { FeatureStrings.dockProfiles(l10n.language) }

    var body: some View {
        SettingsCard(title: text.title) {
            Text(text.settingsHint)
                .font(.callout).foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
            ForEach(service.profiles) { profile in
                DockProfileEditor(profile: profile, text: text)
                Divider()
            }
            HStack(spacing: 8) {
                Button(text.newFromDock) { service.addProfileFromDock(named: text.defaultName) }
                Button(text.newEmpty) { service.addProfile(named: text.defaultName) }
                Spacer(minLength: 8)
                if service.canUndo {
                    Button(text.undo) { service.undo() }
                        .disabled(service.isWorking)
                }
            }
            if let outcome = service.outcome {
                Text(text.message(outcome))
                    .font(.callout)
                    .foregroundStyle(NotchDockProfilesView.isFailure(outcome) ? Color.orange : Color.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Text(text.restartHint).font(.caption).foregroundStyle(.secondary)
        }
        .onAppear { service.refresh() }
    }
}

/// One profile: its name, its apps left to right as the Dock will show them,
/// and Apply. Apps reorder by dragging or from their menu.
private struct DockProfileEditor: View {
    let profile: DockProfile
    let text: DockProfileStrings
    @ObservedObject private var service = DockProfileService.shared
    @State private var pickingApp = false
    @State private var dropTarget: Int?

    private var problem: DockProfileProblem { DockProfileSupport.problem(with: profile.apps) }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                TextField(text.name, text: nameBinding)
                    .textFieldStyle(.roundedBorder)
                    .frame(maxWidth: 220)
                if service.isShownInDock(profile) {
                    Text(text.inDock).font(.caption.weight(.medium)).foregroundStyle(.green)
                }
                Spacer(minLength: 8)
                if service.applying == profile.id {
                    ProgressView().controlSize(.small)
                }
                Button(text.apply) { service.apply(profile) }
                    .buttonStyle(.borderedProminent)
                    .disabled(service.isWorking || profile.apps.isEmpty)
                Button(role: .destructive) { service.delete(profile) } label: {
                    Image(systemName: "trash")
                }
                .buttonStyle(.borderless)
                .help(text.delete)
                .accessibilityLabel(text.delete)
            }
            shelf
            if profile.apps.isEmpty {
                Text(text.noApps).font(.caption).foregroundStyle(.secondary)
            }
        }
        .sheet(isPresented: $pickingApp) {
            AppPickerView(canBrowseApplications: true) {
                pickingApp = false
            } onSelect: { url in
                pickingApp = false
                add(url)
            } onSelectApp: { app in
                pickingApp = false
                add(app.url)
            }
        }
    }

    private var nameBinding: Binding<String> {
        Binding(get: { profile.name }, set: { name in
            var edited = profile
            edited.name = name
            service.update(edited)
        })
    }

    /// The apps as the Dock lines them up, after Finder.
    private var shelf: some View {
        ScrollView(.horizontal) {
            HStack(alignment: .top, spacing: 6) {
                ForEach(Array(profile.apps.enumerated()), id: \.element.id) { index, app in
                    tile(app, at: index)
                }
                dropSlot(at: profile.apps.count)
                Button { pickingApp = true } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 16, weight: .medium))
                        .frame(width: 44, height: 44)
                        .background(.quaternary.opacity(0.6), in: RoundedRectangle(cornerRadius: 10, style: .continuous))
                }
                .buttonStyle(.plain)
                .help(text.addApp)
                .accessibilityLabel(text.addApp)
            }
            .padding(8)
        }
        .scrollIndicators(.never)
        .background(.quaternary.opacity(0.35), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    private func tile(_ app: DockAppEntry, at index: Int) -> some View {
        let unusable = problem.missing.contains(app) || problem.duplicates.contains(app)
        return VStack(spacing: 4) {
            Image(nsImage: NSWorkspace.shared.icon(forFile: app.bundlePath))
                .resizable()
                .frame(width: 40, height: 40)
                .opacity(problem.missing.contains(app) ? 0.4 : 1)
                .overlay(alignment: .topTrailing) {
                    if unusable {
                        Image(systemName: "exclamationmark.circle.fill")
                            .foregroundStyle(.orange)
                            .offset(x: 4, y: -4)
                    }
                }
            Text(app.displayName)
                .font(.caption2)
                .lineLimit(1)
                .truncationMode(.middle)
                .frame(width: 60)
        }
        .padding(4)
        .background(dropTarget == index ? Color.accentColor.opacity(0.2) : Color.clear,
                    in: RoundedRectangle(cornerRadius: 8, style: .continuous))
        .help(problem.missing.contains(app) ? "\(text.notInstalled): \(app.bundlePath)" : app.displayName)
        .draggable(app.bundlePath)
        .dropDestination(for: String.self) { paths, _ in
            reorder(paths, to: index)
        } isTargeted: { dropTarget = $0 ? index : (dropTarget == index ? nil : dropTarget) }
        .contextMenu {
            Button(text.moveLeft) { setApps(DockProfileSupport.moving(app.bundlePath, to: index - 1, in: profile.apps)) }
                .disabled(index == 0)
            Button(text.moveRight) { setApps(DockProfileSupport.moving(app.bundlePath, to: index + 2, in: profile.apps)) }
                .disabled(index == profile.apps.count - 1)
            Divider()
            Button(text.remove, role: .destructive) { setApps(profile.apps.filter { $0.id != app.id }) }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(app.displayName)
        .accessibilityAction(named: text.moveLeft) {
            setApps(DockProfileSupport.moving(app.bundlePath, to: index - 1, in: profile.apps))
        }
        .accessibilityAction(named: text.moveRight) {
            setApps(DockProfileSupport.moving(app.bundlePath, to: index + 2, in: profile.apps))
        }
        .accessibilityAction(named: text.remove) { setApps(profile.apps.filter { $0.id != app.id }) }
    }

    /// A target after the last app, so an app can be dropped at the end.
    private func dropSlot(at index: Int) -> some View {
        RoundedRectangle(cornerRadius: 8, style: .continuous)
            .fill(dropTarget == index ? Color.accentColor.opacity(0.2) : Color.clear)
            .frame(width: 20, height: 44)
            .dropDestination(for: String.self) { paths, _ in
                reorder(paths, to: index)
            } isTargeted: { dropTarget = $0 ? index : (dropTarget == index ? nil : dropTarget) }
    }

    private func reorder(_ paths: [String], to index: Int) -> Bool {
        dropTarget = nil
        var apps = profile.apps
        var target = index
        for path in paths {
            guard let from = apps.firstIndex(where: { $0.bundlePath == path }) else { continue }
            apps = DockProfileSupport.moving(path, to: target, in: apps)
            target = (from < target ? target : target + 1)
        }
        setApps(apps)
        return true
    }

    private func add(_ url: URL) {
        guard let entry = DockProfileService.entry(forAppAt: url) else { return }
        setApps(DockProfileSupport.adding(entry, to: profile.apps))
    }

    private func setApps(_ apps: [DockAppEntry]) {
        var edited = profile
        edited.apps = apps
        service.update(edited)
    }
}
