//
//  GeneralPane.swift
//  Wopener
//
//  App configuration — picker behaviour and appearance.
//

import AppKit
import SwiftUI

struct GeneralPane: View {
    @AppStorage("showNumberHints") private var showNumberHints = true
    @AppStorage("urlChipBelow") private var urlChipBelow = false
    @AppStorage("pickerPosition") private var pickerPositionRaw = PickerPosition.center.rawValue
    @AppStorage("saveForLaterKey") private var saveForLaterKey = "`"
    @AppStorage("showSaveTile") private var showSaveTile = true

    @State private var listening = false
    @State private var keyMonitor: Any?

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Picker")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(.secondary)

            VStack(alignment: .leading, spacing: 6) {
                Toggle(isOn: $showNumberHints) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Show number hints")
                            .font(.system(size: 13, weight: .medium))
                        Text("Number-key shortcuts (1–9) always work regardless.")
                            .font(.system(size: 11))
                            .foregroundStyle(.secondary)
                    }
                }
                .toggleStyle(.switch)
                .controlSize(.small)

                Divider()
                    .padding(.vertical, 4)

                Toggle(isOn: $showSaveTile) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Show Save tile")
                            .font(.system(size: 13, weight: .medium))
                        Text("The save-for-later tile at the front of the picker. The save key still works when hidden.")
                            .font(.system(size: 11))
                            .foregroundStyle(.secondary)
                    }
                }
                .toggleStyle(.switch)
                .controlSize(.small)

                Divider()
                    .padding(.vertical, 4)

                VStack(alignment: .leading, spacing: 6) {
                    Text("URL position")
                        .font(.system(size: 13, weight: .medium))
                    Picker("URL position", selection: $urlChipBelow) {
                        Text("Above picker").tag(false)
                        Text("Below picker").tag(true)
                    }
                    .pickerStyle(.segmented)
                    .labelsHidden()
                    .controlSize(.small)
                    Text("Where the link chip sits relative to the browser tiles.")
                        .font(.system(size: 11))
                        .foregroundStyle(.secondary)
                }

                Divider()
                    .padding(.vertical, 4)

                VStack(alignment: .leading, spacing: 6) {
                    Text("Picker location")
                        .font(.system(size: 13, weight: .medium))
                    Picker("Picker location", selection: $pickerPositionRaw) {
                        ForEach(PickerPosition.allCases) { pos in
                            Text(pos.label).tag(pos.rawValue)
                        }
                    }
                    .pickerStyle(.menu)
                    .labelsHidden()
                    .controlSize(.small)
                    .fixedSize()
                    Text("Where the picker appears on the screen under the cursor.")
                        .font(.system(size: 11))
                        .foregroundStyle(.secondary)
                }

                Divider()
                    .padding(.vertical, 4)

                VStack(alignment: .leading, spacing: 6) {
                    Text("Save key")
                        .font(.system(size: 13, weight: .medium))
                    HStack(spacing: 8) {
                        Button {
                            listening ? stopListening() : startListening()
                        } label: {
                            Text(listening ? "Press a key…" : displayKey)
                                .font(.system(size: 12, weight: .medium, design: .monospaced))
                                .frame(minWidth: 90)
                        }
                        .buttonStyle(.glass)
                        .controlSize(.small)
                        if saveForLaterKey != "`" {
                            Button("Reset to `") { saveForLaterKey = "`" }
                                .buttonStyle(.glass)
                                .controlSize(.small)
                        }
                    }
                    Text("Press this key in the picker to save the link instead of opening it.")
                        .font(.system(size: 11))
                        .foregroundStyle(.secondary)
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .glassEffect(.regular, in: .rect(cornerRadius: 18))

            Spacer()
        }
        .padding(24)
        .onDisappear { stopListening() }
    }

    /// Human-readable label for the current save key (space shows as "Space").
    private var displayKey: String {
        saveForLaterKey == " " ? "Space" : saveForLaterKey
    }

    /// Capture the next keystroke as the save key via a local event monitor.
    private func startListening() {
        listening = true
        keyMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
            // Esc cancels without rebinding.
            if event.keyCode != 53, let chars = event.charactersIgnoringModifiers, !chars.isEmpty {
                saveForLaterKey = chars
            }
            stopListening()
            return nil  // swallow the event so it doesn't reach other UI
        }
    }

    private func stopListening() {
        if let monitor = keyMonitor {
            NSEvent.removeMonitor(monitor)
            keyMonitor = nil
        }
        listening = false
    }
}

#Preview {
    GeneralPane()
}
