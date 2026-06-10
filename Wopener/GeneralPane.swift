//
//  GeneralPane.swift
//  Wopener
//
//  App configuration — picker behaviour and appearance.
//

import SwiftUI

struct GeneralPane: View {
    @AppStorage("showNumberHints") private var showNumberHints = true
    @AppStorage("urlChipBelow") private var urlChipBelow = false
    @AppStorage("pickerPosition") private var pickerPositionRaw = PickerPosition.center.rawValue

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
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .glassEffect(.regular, in: .rect(cornerRadius: 18))

            Spacer()
        }
        .padding(24)
    }
}

#Preview {
    GeneralPane()
}
