//
//  MainWindowView.swift
//  Wopener
//

import SwiftUI

struct MainWindowView: View {
    @State private var manager = BrowserManager.shared
    @State private var isDefault = BrowserManager.shared.isDefaultBrowser()

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            header
            statusSection
            browsersSection
        }
        .padding(24)
        .frame(width: 420, height: 520)
        .onAppear { refreshStatus() }
    }

    private var header: some View {
        HStack(spacing: 10) {
            Image(systemName: "globe")
                .font(.system(size: 22, weight: .semibold))
                .foregroundStyle(.tint)
            Text("Wopener")
                .font(.system(size: 22, weight: .bold))
            Spacer()
        }
    }

    private var statusSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: isDefault ? "checkmark.circle.fill" : "exclamationmark.circle.fill")
                    .foregroundStyle(isDefault ? .green : .orange)
                Text(isDefault ? "Wopener is your default browser" : "Wopener is not the default browser")
                    .font(.system(size: 13, weight: .medium))
            }
            if !isDefault {
                Text("Set Wopener as default so link clicks show the picker.")
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)
                HStack {
                    Button("Set as Default Browser") {
                        manager.makeDefaultBrowser()
                        // Re-check shortly after the system dialog.
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { refreshStatus() }
                    }
                    .buttonStyle(.glassProminent)
                    Button("Open System Settings") {
                        if let url = URL(string: "x-apple.systempreferences:") {
                            NSWorkspace.shared.open(url)
                        }
                    }
                    .buttonStyle(.glass)
                }
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .glassEffect(.regular, in: .rect(cornerRadius: 18))
    }

    private var browsersSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Browsers")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(.secondary)
            Text("Drag to reorder — order sets the picker's number-key shortcuts.")
                .font(.system(size: 11))
                .foregroundStyle(.secondary)
            List {
                ForEach(Array(manager.browsers.enumerated()), id: \.element.id) { index, browser in
                    HStack(spacing: 10) {
                        Text("\(index + 1)")
                            .font(.system(size: 12, weight: .bold, design: .rounded))
                            .foregroundStyle(.secondary)
                            .frame(width: 18)
                        Image(nsImage: browser.icon)
                            .resizable()
                            .frame(width: 22, height: 22)
                        Text(browser.name)
                            .font(.system(size: 13))
                        Spacer()
                        Image(systemName: "line.3.horizontal")
                            .foregroundStyle(.tertiary)
                    }
                }
                .onMove { manager.move(from: $0, to: $1) }
            }
            .listStyle(.inset)
        }
    }

    private func refreshStatus() {
        manager.refresh()
        isDefault = manager.isDefaultBrowser()
    }
}

#Preview {
    MainWindowView()
}
