//
//  GeneralPane.swift
//  Wopener
//
//  App configuration — picker behaviour and appearance.
//

import SwiftUI

struct GeneralPane: View {
    @AppStorage("showNumberHints") private var showNumberHints = true

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
