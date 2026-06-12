//
//  SavedLinksPane.swift
//  Wopener
//
//  The "Saved" section — links stashed via the picker's Save tile, shown as a grid of
//  glass cards. Clicking a card reopens the glass picker for that URL (the link stays).
//

import SwiftUI

struct SavedLinksPane: View {
    @State private var store = SavedLinksStore.shared
    @State private var hoveredID: SavedLink.ID?

    private let columns = [GridItem(.adaptive(minimum: 150, maximum: 220), spacing: 12)]

    var body: some View {
        Group {
            if store.links.isEmpty {
                emptyState
            } else {
                content
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(24)
    }

    private var content: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Saved for later")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.secondary)
                Spacer()
                Button("Clear All") { store.clear() }
                    .buttonStyle(.glass)
                    .controlSize(.small)
            }

            ScrollView {
                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(store.links) { link in
                        card(link)
                    }
                }
                .padding(.vertical, 2)
            }
        }
    }

    private func card(_ link: SavedLink) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Image("SaveForLater")
                .resizable()
                .interpolation(.high)
                .antialiased(true)
                .frame(width: 28, height: 28)
            Text(link.host)
                .font(.system(size: 13, weight: .semibold))
                .lineLimit(1)
                .truncationMode(.middle)
            Text(link.title)
                .font(.system(size: 11))
                .foregroundStyle(.secondary)
                .lineLimit(2)
                .truncationMode(.middle)
            Spacer(minLength: 0)
            Text(link.dateAdded, format: .relative(presentation: .named))
                .font(.system(size: 10))
                .foregroundStyle(.tertiary)
        }
        .frame(maxWidth: .infinity, minHeight: 110, alignment: .leading)
        .padding(12)
        .glassEffect(.regular.interactive(), in: .rect(cornerRadius: 16))
        .overlay(alignment: .topTrailing) { deleteButton(link) }
        .contentShape(RoundedRectangle(cornerRadius: 16))
        .onTapGesture { PickerWindowController.shared.present(for: link.url) }
        .onHover { hovering in
            if hovering { hoveredID = link.id }
            else if hoveredID == link.id { hoveredID = nil }
        }
        .contextMenu {
            Button("Copy Link") {
                NSPasteboard.general.clearContents()
                NSPasteboard.general.setString(link.url.absoluteString, forType: .string)
            }
            Button("Remove", role: .destructive) { store.remove(link) }
        }
        .help(link.url.absoluteString)
    }

    /// Hover-revealed delete control on a saved card.
    private func deleteButton(_ link: SavedLink) -> some View {
        Button {
            store.remove(link)
        } label: {
            Image(systemName: "xmark.circle.fill")
                .font(.system(size: 18, weight: .semibold))
                .symbolRenderingMode(.palette)
                .foregroundStyle(.white, .black.opacity(0.55))
                .shadow(color: .black.opacity(0.35), radius: 1.5, y: 0.5)
        }
        .buttonStyle(.plain)
        .padding(6)
        .opacity(hoveredID == link.id ? 1 : 0)
        .animation(.easeInOut(duration: 0.12), value: hoveredID)
        .zIndex(1)
        .help("Remove")
    }

    private var emptyState: some View {
        VStack(spacing: 10) {
            Image(systemName: "bookmark")
                .font(.system(size: 32, weight: .light))
                .foregroundStyle(.secondary)
            Text("No saved links yet")
                .font(.system(size: 14, weight: .medium))
            Text("In the picker, press the save key (default `) or click the Save tile to stash a link here.")
                .font(.system(size: 12))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 360)
        }
        .padding(28)
        .glassEffect(.regular, in: .rect(cornerRadius: 18))
    }
}

#Preview {
    SavedLinksPane()
}
