// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Vorssaint
// Ported from the Dock profiles feature of Notch Sidekick (GPL-3.0) by Fernando Chavarría.

import AppKit
import SwiftUI

/// The saved Dock profiles, one click from the Dock. Profiles are made and
/// edited in Settings → Dock; here a click applies one.
struct NotchDockProfilesView: View {
    let size: CGSize
    @ObservedObject private var profiles = DockProfileService.shared
    @ObservedObject private var l10n = L10n.shared
    @Environment(\.notchSettingsPreview) private var preview
    private var text: DockProfileStrings { FeatureStrings.dockProfiles(l10n.language) }

    var body: some View {
        VStack(alignment: .leading, spacing: NotchLayout.rowSpacing) {
            if profiles.profiles.isEmpty {
                NotchEmptyView(symbol: NotchModule.dockProfiles.symbol, message: text.empty)
                if !preview {
                    NotchDockProfilesPill(title: text.openSettings, action: openSettings)
                        .frame(maxWidth: .infinity)
                }
            } else {
                ScrollView(.vertical) {
                    VStack(spacing: 6) {
                        ForEach(profiles.profiles) { profile in
                            NotchDockProfileRow(profile: profile, text: text, preview: preview)
                        }
                    }
                }
                .scrollIndicators(.never)
                .notchScrollEdgeFade()
                footer
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .onAppear { profiles.refresh() }
    }

    @ViewBuilder private var footer: some View {
        if profiles.outcome != nil || profiles.canUndo {
            HStack(spacing: 8) {
                if let outcome = profiles.outcome {
                    Text(text.message(outcome))
                        .font(.caption)
                        .foregroundStyle(Self.isFailure(outcome) ? Color.orange : Color.secondary)
                        .lineLimit(2)
                        .frame(maxWidth: .infinity, alignment: .leading)
                } else {
                    Spacer(minLength: 0)
                }
                if profiles.canUndo, !preview {
                    NotchDockProfilesPill(title: text.undo) { profiles.undo() }
                        .disabled(profiles.isWorking)
                }
            }
        }
    }

    static func isFailure(_ outcome: DockProfileOutcome) -> Bool {
        switch outcome {
        case .applied, .restored: return false
        case .problem, .notWritten, .notRestarted: return true
        }
    }

    private func openSettings() {
        NotchService.shared.perform {
            SettingsRouter.shared.request(FeatureSettingsDestination(.dock))
            (NSApp.delegate as? AppDelegate)?.openSettingsWindow()
        }
    }
}

private struct NotchDockProfileRow: View {
    let profile: DockProfile
    let text: DockProfileStrings
    let preview: Bool
    @ObservedObject private var profiles = DockProfileService.shared

    private var isInDock: Bool { profiles.isShownInDock(profile) }
    private var isApplying: Bool { profiles.applying == profile.id }

    var body: some View {
        Button { if !preview { profiles.apply(profile) } } label: {
            HStack(spacing: 10) {
                Image(systemName: isInDock ? "checkmark.circle.fill" : NotchModule.dockProfiles.symbol)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(isInDock ? Color.white : Color.white.opacity(0.55))
                    .frame(width: 20)
                    .accessibilityHidden(true)
                VStack(alignment: .leading, spacing: 4) {
                    Text(profile.name.isEmpty ? text.defaultName : profile.name)
                        .font(.system(size: 13, weight: .semibold))
                        .lineLimit(1)
                    icons
                }
                Spacer(minLength: 8)
                if isApplying {
                    ProgressView().controlSize(.small)
                } else if isInDock {
                    Text(text.inDock).font(.caption).foregroundStyle(.secondary)
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.white.opacity(isInDock ? 0.13 : 0.06),
                        in: RoundedRectangle(cornerRadius: 12, style: .continuous))
            .contentShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
        .buttonStyle(NotchButtonStyle(cornerRadius: 12))
        .disabled(profiles.isWorking || profile.apps.isEmpty)
        .help(text.restartHint)
        .accessibilityLabel(profile.name.isEmpty ? text.defaultName : profile.name)
        .accessibilityValue(isInDock ? text.inDock : profile.apps.map(\.displayName).joined(separator: ", "))
        .accessibilityAddTraits(isInDock ? .isSelected : [])
    }

    /// Every icon in the profile, so it is recognized before it is applied.
    private var icons: some View {
        HStack(spacing: 3) {
            ForEach(profile.apps.prefix(16)) { app in
                Image(nsImage: NSWorkspace.shared.icon(forFile: app.bundlePath))
                    .resizable()
                    .frame(width: 16, height: 16)
            }
            if profile.apps.count > 16 {
                Text("+\(profile.apps.count - 16)")
                    .font(.system(size: 10, weight: .semibold, design: .rounded))
                    .foregroundStyle(.secondary)
            }
        }
        .accessibilityHidden(true)
    }
}

private struct NotchDockProfilesPill: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 12, weight: .medium))
                .padding(.horizontal, 12)
                .frame(height: 26)
                .background(.white.opacity(0.12), in: Capsule(style: .continuous))
                .contentShape(Capsule(style: .continuous))
        }
        .buttonStyle(NotchButtonStyle(cornerRadius: 13))
    }
}
