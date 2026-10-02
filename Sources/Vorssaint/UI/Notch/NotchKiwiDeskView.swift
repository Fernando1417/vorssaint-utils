// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Vorssaint
// Ported from the KiwiDesk feature of Notch Sidekick (GPL-3.0) by Fernando Chavarría.

import AppKit
import SwiftUI

/// The KiwiDesk page's options, under its row in the Dynamic Island settings.
struct NotchKiwiDeskSettingsControls: View {
    @ObservedObject private var l10n = L10n.shared
    @State private var toolPath: String?
    private var text: NotchKiwiDeskStrings { FeatureStrings.notchKiwiDesk(l10n.language) }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(text.settingsHint)
                .font(.callout).foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
            HStack(spacing: 8) {
                Image(systemName: "terminal").foregroundStyle(.secondary).accessibilityHidden(true)
                Text(text.tool)
                Spacer(minLength: 8)
                Text(toolPath ?? text.toolMissing)
                    .font(.callout.monospaced()).foregroundStyle(.secondary)
                    .lineLimit(1).truncationMode(.middle).textSelection(.enabled)
            }
        }
        // Only the usual install places: the login shell is searched when the page opens.
        .onAppear {
            toolPath = KiwiDeskSupport.cliCandidates.first { FileManager.default.isExecutableFile(atPath: $0) }
        }
    }
}

/// One card per KiwiDesk space with app windows, the focused space and app
/// marked. A card switches to its space, its corner menu changes the layout,
/// and an app's icon brings it forward, with floating and sticky in its menu.
struct NotchKiwiDeskView: View {
    let size: CGSize
    @ObservedObject private var kiwiDesk = KiwiDeskService.shared
    @ObservedObject private var l10n = L10n.shared
    @Environment(\.notchSettingsPreview) private var preview
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    private var text: NotchKiwiDeskStrings { FeatureStrings.notchKiwiDesk(l10n.language) }

    var body: some View {
        Group {
            if preview {
                // A preview must not start the tool; it explains the page instead.
                NotchEmptyView(symbol: NotchModule.kiwiDesk.symbol,
                               message: FeatureStrings.notchEditor(l10n.language).kiwiDeskSummary)
            } else {
                content
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear { if !preview { kiwiDesk.start() } }
        .onDisappear { if !preview { kiwiDesk.stop() } }
    }

    @ViewBuilder private var content: some View {
        switch kiwiDesk.availability {
        case .loading:
            ProgressView().controlSize(.small).accessibilityLabel(text.loading)
        case .cliNotFound:
            NotchEmptyView(symbol: "terminal", message: text.cliNotFound)
        case .serverUnreachable:
            NotchEmptyView(symbol: "exclamationmark.triangle", message: text.serverUnreachable)
        case .cliError:
            NotchEmptyView(symbol: "exclamationmark.triangle", message: text.cliError)
        case .available:
            if kiwiDesk.spaces.isEmpty {
                NotchEmptyView(symbol: "square.on.square.dashed", message: text.noWindows)
            } else {
                cards
            }
        }
    }

    private var cards: some View {
        ScrollView(.horizontal) {
            HStack(alignment: .top, spacing: 8) {
                ForEach(kiwiDesk.spaces) { space in
                    NotchKiwiDeskSpaceCard(space: space, text: text)
                        .transition(.scale(scale: 0.9).combined(with: .opacity))
                }
            }
            .frame(maxHeight: .infinity, alignment: .top)
        }
        .scrollIndicators(.never)
        .notchScrollEdgeFade(.horizontal)
        .animation(reduceMotion ? nil : .smooth(duration: 0.3), value: kiwiDesk.spaces)
    }
}

private struct NotchKiwiDeskSpaceCard: View {
    let space: KiwiDeskSpace
    let text: NotchKiwiDeskStrings
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private static let width: CGFloat = 112
    private static let icon: CGFloat = 22
    private static let columns = 3
    private static let maximumIcons = 9

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Text(space.id)
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundStyle(space.isActive ? Color.black : Color.white.opacity(0.75))
                    .lineLimit(1)
                    .padding(.horizontal, 5)
                    .frame(minWidth: 20, minHeight: 20)
                    .background(.white.opacity(space.isActive ? 0.9 : 0.1), in: Capsule(style: .continuous))
                Spacer(minLength: 0)
                layoutMenu
            }
            icons
        }
        .padding(10)
        .frame(width: Self.width, alignment: .topLeading)
        .frame(maxHeight: .infinity, alignment: .top)
        .background(.white.opacity(space.isActive ? 0.13 : 0.06),
                    in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .strokeBorder(.white.opacity(space.isActive ? 0.35 : 0.06), lineWidth: 0.75)
        }
        .contentShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        // The icons and the layout menu answer their own clicks first.
        .onTapGesture { KiwiDeskService.shared.focusSpace(space.id) }
        .help(text.switchTo(space.id))
        .animation(reduceMotion ? nil : .smooth(duration: 0.25), value: space.isActive)
        .accessibilityElement(children: .contain)
        .accessibilityLabel(text.space(space.id))
        .accessibilityValue(space.isActive ? text.focused : space.mode.capitalized)
        .accessibilityAddTraits(space.isActive ? [.isButton, .isSelected] : .isButton)
        .accessibilityAction { KiwiDeskService.shared.focusSpace(space.id) }
    }

    private var layoutMenu: some View {
        Menu {
            Section(text.layout) {
                ForEach(KiwiDeskSupport.layoutModes, id: \.self) { mode in
                    Button {
                        KiwiDeskService.shared.setMode(mode, space: space.id)
                    } label: {
                        if mode == space.mode {
                            Label(mode.capitalized, systemImage: "checkmark")
                        } else {
                            Label(mode.capitalized, systemImage: KiwiDeskSupport.symbol(forMode: mode))
                        }
                    }
                }
            }
        } label: {
            Image(systemName: KiwiDeskSupport.symbol(forMode: space.mode))
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(.white.opacity(0.55))
                .frame(width: 20, height: 20)
                .contentShape(Rectangle())
        }
        .menuStyle(.borderlessButton)
        .menuIndicator(.hidden)
        .fixedSize()
        .help("\(text.layout): \(space.mode.capitalized)")
        .accessibilityLabel(text.layout)
        .accessibilityValue(space.mode.capitalized)
    }

    private var icons: some View {
        let shown = Array(space.apps.prefix(Self.maximumIcons))
        let more = space.apps.count - shown.count
        return LazyVGrid(columns: Array(repeating: GridItem(.fixed(Self.icon), spacing: 7), count: Self.columns),
                         alignment: .leading, spacing: 7) {
            ForEach(shown) { app in NotchKiwiDeskAppIcon(app: app, size: Self.icon, text: text) }
            if more > 0 {
                Text("+\(more)")
                    .font(.system(size: 10, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white.opacity(0.55))
                    .frame(width: Self.icon, height: Self.icon)
            }
        }
    }
}

private struct NotchKiwiDeskAppIcon: View {
    let app: KiwiDeskApp
    let size: CGFloat
    let text: NotchKiwiDeskStrings
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        Button { KiwiDeskService.shared.activate(app) } label: {
            Group {
                if let icon = KiwiDeskService.shared.icon(for: app) {
                    Image(nsImage: icon).resizable().interpolation(.high)
                } else {
                    Image(systemName: "app").font(.system(size: 14)).foregroundStyle(.white.opacity(0.55))
                }
            }
            .frame(width: size, height: size)
            .background {
                if app.isActive {
                    RoundedRectangle(cornerRadius: 7, style: .continuous)
                        .fill(.white.opacity(0.18)).padding(-3)
                }
            }
            .overlay(alignment: .bottomTrailing) {
                if app.isFloating {
                    Image(systemName: "square.on.square")
                        .font(.system(size: 6, weight: .bold))
                        .foregroundStyle(.white)
                        .padding(2)
                        .background(.black.opacity(0.7), in: Circle())
                        .offset(x: 3, y: 3)
                        .accessibilityHidden(true)
                }
            }
            .opacity(app.isActive ? 1 : 0.85)
        }
        .buttonStyle(NotchButtonStyle(cornerRadius: 7))
        .disabled(app.bundleID == nil)
        .animation(reduceMotion ? nil : .smooth(duration: 0.2), value: app.isActive)
        .contextMenu {
            if app.bundleID != nil {
                Button(text.bringForward) { KiwiDeskService.shared.activate(app) }
                Button(app.isFloating ? text.makeTiled : text.makeFloating) { KiwiDeskService.shared.toggleFloating(app) }
                Button(text.toggleSticky) { KiwiDeskService.shared.toggleSticky(app) }
            }
        }
        .help(app.isFloating ? "\(app.name) · \(text.floating)" : app.name)
        .accessibilityLabel(app.name)
        .accessibilityValue([app.isActive ? text.focused : nil, app.isFloating ? text.floating : nil]
            .compactMap { $0 }.joined(separator: ", "))
    }
}
