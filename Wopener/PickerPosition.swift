//
//  PickerPosition.swift
//  Wopener
//
//  Where the glass picker anchors on the screen under the cursor. The overlay is
//  always full-screen; this only moves the chip + card cluster within it.
//

import SwiftUI

enum PickerPosition: String, CaseIterable, Identifiable {
    case center
    case top, bottom, leading, trailing
    case topLeading, topTrailing, bottomLeading, bottomTrailing

    var id: String { rawValue }

    var label: String {
        switch self {
        case .center:         return "Center"
        case .top:            return "Top"
        case .bottom:         return "Bottom"
        case .leading:        return "Left"
        case .trailing:       return "Right"
        case .topLeading:     return "Top Left"
        case .topTrailing:    return "Top Right"
        case .bottomLeading:  return "Bottom Left"
        case .bottomTrailing: return "Bottom Right"
        }
    }

    var alignment: Alignment {
        switch self {
        case .center:         return .center
        case .top:            return .top
        case .bottom:         return .bottom
        case .leading:        return .leading
        case .trailing:       return .trailing
        case .topLeading:     return .topLeading
        case .topTrailing:    return .topTrailing
        case .bottomLeading:  return .bottomLeading
        case .bottomTrailing: return .bottomTrailing
        }
    }
}
