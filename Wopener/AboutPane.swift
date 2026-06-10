//
//  AboutPane.swift
//  Wopener
//
//  Project info, version, and a link to the open-source repo.
//

import SwiftUI

struct AboutPane: View {
    private static let repoURL = URL(string: "https://github.com/xkaper/wopener")!

    private let blurb = "Wopener slips in as your default browser and, every time you click a link, hands you a sweet little glass picker so you decide which browser opens it — no rules to babysit, no memory to second-guess. Built with love, SwiftUI, and a healthy obsession with Liquid Glass."
    private let openLine = "Free and open source. Stars, issues, and pull requests are all welcome — come tinker. ✨"

    private var version: String {
        let v = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let b = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "Version \(v) (\(b))"
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                HStack(spacing: 14) {
                    Image(nsImage: NSApp.applicationIconImage)
                        .resizable()
                        .frame(width: 64, height: 64)
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Wopener")
                            .font(.system(size: 24, weight: .bold))
                        Text(version)
                            .font(.system(size: 12))
                            .foregroundStyle(.secondary)
                    }
                    Spacer(minLength: 0)
                }

                VStack(alignment: .leading, spacing: 10) {
                    Text("Your link, your choice. 🪄")
                        .font(.system(size: 14, weight: .semibold))
                    Text(verbatim: blurb)
                        .font(.system(size: 12))
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                    Text(verbatim: openLine)
                        .font(.system(size: 12))
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(16)
                .glassEffect(.regular, in: .rect(cornerRadius: 18))

                HStack {
                    Link(destination: Self.repoURL) {
                        Label("View on GitHub", systemImage: "chevron.left.forwardslash.chevron.right")
                    }
                    .buttonStyle(.glassProminent)
                    Spacer(minLength: 0)
                    Text("Made by @xkaper")
                        .font(.system(size: 11))
                        .foregroundStyle(.tertiary)
                }
            }
            .padding(24)
            .frame(maxWidth: .infinity, alignment: .topLeading)
        }
    }
}

#Preview {
    AboutPane()
}
