//
// ContentSizeCategory.swift
//
// Copyright 2021 • James Sherlock
//

import SwiftUI

#if !os(OSX) && !os(watchOS)
    extension ContentSizeCategory {
        var uiKit: UIContentSizeCategory {
            switch self {
            case .extraSmall: return .extraSmall
            case .small: return .small
            case .medium: return .medium
            case .large: return .large
            case .extraLarge: return .extraLarge
            case .extraExtraLarge: return .extraExtraLarge
            case .extraExtraExtraLarge: return .extraExtraExtraLarge
            case .accessibilityMedium: return .accessibilityMedium
            case .accessibilityLarge: return .accessibilityLarge
            case .accessibilityExtraLarge: return .accessibilityExtraLarge
            case .accessibilityExtraExtraLarge: return .accessibilityExtraExtraLarge
            case .accessibilityExtraExtraExtraLarge: return .accessibilityExtraExtraExtraLarge
            @unknown default: return .large
            }
        }
    }
#endif
