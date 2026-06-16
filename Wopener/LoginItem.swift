//
//  LoginItem.swift
//  Wopener
//
//  Thin wrapper over ServiceManagement's modern login-item API. Registering the main
//  app as a login item surfaces no system dialog; the user can later disable it in
//  System Settings ▸ General ▸ Login Items.
//

import ServiceManagement

enum LoginItem {
    /// True when Wopener is registered to launch at login.
    static var isEnabled: Bool { SMAppService.mainApp.status == .enabled }

    /// Register or unregister the app as a login item.
    static func setEnabled(_ on: Bool) {
        do {
            if on { try SMAppService.mainApp.register() }
            else { try SMAppService.mainApp.unregister() }
        } catch {
            NSLog("LoginItem toggle to \(on) failed: \(error)")
        }
    }
}
