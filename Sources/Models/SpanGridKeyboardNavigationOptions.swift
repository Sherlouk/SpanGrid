//
// SpanGridKeyboardNavigationOptions.swift
//
// Copyright 2021 • James Sherlock
//

import Foundation

public struct SpanGridKeyboardNavigationOptions {
    public struct Localization {
        public let navigatePreviousRow: String
        public let navigatePreviousItem: String
        
        public let navigateNextRow: String
        public let navigateNextItem: String
        
        public init(navigatePreviousRow: String, navigatePreviousItem: String, navigateNextRow: String, navigateNextItem: String) {
            self.navigatePreviousRow = navigatePreviousRow
            self.navigatePreviousItem = navigatePreviousItem
            self.navigateNextRow = navigateNextRow
            self.navigateNextItem = navigateNextItem
        }
    }
    
    public let enabled: Bool
    
    public let discoverabilityEnabled: Bool
    
    public let localization: Localization
    
    public init(
        enabled: Bool = false,
        discoverabiliyEnabled: Bool = false,
        localization: Localization? = nil
    ) {
        self.enabled = enabled
        discoverabilityEnabled = discoverabiliyEnabled
        self.localization = localization ?? .init(
            navigatePreviousRow: "Navigate to previous row",
            navigatePreviousItem: "Navigate to previous item",
            navigateNextRow: "Navigate to next row",
            navigateNextItem: "Navigate to next item"
        )
    }
}
