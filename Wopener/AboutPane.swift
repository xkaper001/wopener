//
//  AboutPane.swift
//  Wopener
//
//  Project info, version, and a link to the open-source repo.
//

import SwiftUI

struct AboutPane: View {
    private static let repoURL = URL(string: "https://github.com/xkaper001/wopener")!
    private static let kimchiURL = URL(string: "https://tr.ee/lpzVfB")!

    private let blurb = "macOS only lets one browser be the default, and every link just obeys it. I kept opening work links in my personal browser by accident, so I built Wopener. Now the click pauses and I pick."
    private let openLine = "It's free and open source. The code lives on GitHub. Read it, fork it, or tell me what I got wrong."

    private var version: String {
        let v = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        return "Version \(v)"
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
                    Text("The Web Opener Apple Forgot. 🪄")
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

                HStack(spacing: 4) {
                    Text("Notarisation sponsored by")
                        .font(.system(size: 11))
                        .foregroundStyle(.tertiary)
                    Link("Kimchi", destination: Self.kimchiURL)
                        .font(.system(size: 11, weight: .medium))
                }
                .frame(maxWidth: .infinity, alignment: .center)
            }
            .padding(24)
            .frame(maxWidth: .infinity, alignment: .topLeading)
        }
    }
}

#Preview {
    AboutPane()
}
