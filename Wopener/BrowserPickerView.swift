//
//  BrowserPickerView.swift
//  Wopener
//

import AppKit
import SwiftUI

/// Full-screen overlay: a dimmed backdrop, a detached URL chip, and the glass
/// picker card. Hosted inside the borderless PickerPanel.
struct PickerOverlay: View {
    let url: URL
    let browsers: [Browser]
    let onPick: (Browser) -> Void
    let onCancel: () -> Void

    @State private var appeared = false
    @State private var selected = 0
    @State private var copied = false
    @FocusState private var focused: Bool

    var body: some View {
        ZStack {
            // Dimmed backdrop — clicking it cancels.
            Color.black
                .opacity(appeared ? 0.28 : 0)
                .ignoresSafeArea()
                .contentShape(Rectangle())
                .onTapGesture { onCancel() }

            GlassEffectContainer(spacing: 16) {
                VStack(spacing: 14) {
                    urlChip
                    card
                }
            }
            .scaleEffect(appeared ? 1 : 0.92)
            .opacity(appeared ? 1 : 0)
        }
        .focusable()
        .focused($focused)
        .focusEffectDisabled()
        .onAppear {
            withAnimation(.spring(response: 0.32, dampingFraction: 0.8)) { appeared = true }
            focused = true
        }
        .onKeyPress(action: handleKey)
    }

    // MARK: Detached URL chip

    private var urlChip: some View {
        Button {
            copyURL()
        } label: {
            HStack(spacing: 6) {
                Image(systemName: copied ? "checkmark" : "link")
                    .font(.system(size: 11, weight: .semibold))
                Text(copied ? "Copied" : displayURL)
                    .font(.system(size: 12, weight: .medium))
                    .lineLimit(1)
                    .truncationMode(.middle)
            }
            .foregroundStyle(.primary)
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
        }
        .buttonStyle(.plain)
        .frame(maxWidth: 360)
        .glassEffect(.regular.interactive(), in: .capsule)
        .help("Click to copy the link")
    }

    private var displayURL: String {
        if let host = url.host {
            let path = url.path
            return path.isEmpty || path == "/" ? host : host + path
        }
        return url.absoluteString
    }

    // MARK: Picker card

    private var card: some View {
        VStack(spacing: 12) {
            Text("Open link in…")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(.secondary)

            if browsers.isEmpty {
                Text("No browsers found")
                    .font(.system(size: 13))
                    .foregroundStyle(.secondary)
                    .padding(.vertical, 8)
            } else {
                HStack(spacing: 10) {
                    ForEach(Array(browsers.enumerated()), id: \.element.id) { index, browser in
                        tile(browser, index: index)
                    }
                }
            }
        }
        .padding(18)
        .glassEffect(.regular, in: .rect(cornerRadius: 24))
    }

    private func tile(_ browser: Browser, index: Int) -> some View {
        Button {
            onPick(browser)
        } label: {
            VStack(spacing: 6) {
                Image(nsImage: browser.icon)
                    .resizable()
                    .frame(width: 52, height: 52)
                Text("\(index + 1)")
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundStyle(index < 9 ? .secondary : Color.secondary.opacity(0))
            }
            .padding(10)
            .background {
                RoundedRectangle(cornerRadius: 16)
                    .fill(.ultraThinMaterial)
                    .opacity(selected == index ? 1 : 0)
            }
            .overlay {
                RoundedRectangle(cornerRadius: 16)
                    .strokeBorder(.white.opacity(selected == index ? 0.5 : 0), lineWidth: 1)
            }
            .contentShape(RoundedRectangle(cornerRadius: 16))
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            if hovering { selected = index }
        }
        .help(browser.name)
    }

    // MARK: Actions

    private func copyURL() {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(url.absoluteString, forType: .string)
        withAnimation(.easeInOut(duration: 0.15)) { copied = true }
    }

    private func handleKey(_ press: KeyPress) -> KeyPress.Result {
        switch press.key {
        case .escape:
            onCancel(); return .handled
        case .return:
            if browsers.indices.contains(selected) { onPick(browsers[selected]) }
            return .handled
        case .leftArrow:
            move(-1); return .handled
        case .rightArrow:
            move(1); return .handled
        default:
            if let digit = press.characters.first?.wholeNumberValue,
               digit >= 1, digit <= browsers.count {
                onPick(browsers[digit - 1]); return .handled
            }
            return .ignored
        }
    }

    private func move(_ delta: Int) {
        guard !browsers.isEmpty else { return }
        selected = (selected + delta + browsers.count) % browsers.count
    }
}
