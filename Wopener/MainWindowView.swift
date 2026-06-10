//
//  MainWindowView.swift
//  Wopener
//

import SwiftUI

/// Sidebar categories for the main window, settings-app style.
enum SettingsCategory: String, CaseIterable, Identifiable {
    case browsers
    case general
    case about

    var id: String { rawValue }

    var title: String {
        switch self {
        case .browsers: return "Browsers"
        case .general:  return "General"
        case .about:    return "About"
        }
    }

    var icon: String {
        switch self {
        case .browsers: return "globe"
        case .general:  return "gearshape"
        case .about:    return "info.circle"
        }
    }
}

struct MainWindowView: View {
    @State private var selection: SettingsCategory = .browsers

    var body: some View {
        NavigationSplitView {
            List(SettingsCategory.allCases, selection: $selection) { category in
                Label(category.title, systemImage: category.icon)
                    .tag(category)
            }
            .navigationSplitViewColumnWidth(180)
        } detail: {
            Group {
                switch selection {
                case .browsers: BrowsersPane()
                case .general:  GeneralPane()
                case .about:    AboutPane()
                }
            }
            .navigationTitle(selection.title)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(minWidth: 640, minHeight: 540)
    }
}

#Preview {
    MainWindowView()
}
