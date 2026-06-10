//
//  WopenerApp.swift
//  Wopener
//

import SwiftUI

@main
struct WopenerApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    var body: some Scene {
        Window("Wopener", id: "main") {
            MainWindowView()
        }
        .windowResizability(.contentSize)
    }
}
