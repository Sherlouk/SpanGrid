//
// SpanGridTraitCollection.swift
//
// Copyright 2021 • James Sherlock
//

import Foundation
import SwiftUI

/// A simple model containing information about a given cells size. This is used as a proxy to UIKit's trait collection which doesn't exist in every platform SpanGrid
/// supports.
public struct SpanGridTraitCollection {
    public enum SizeClass: Equatable {
        case regular
        case compact
    }
    
    public let sizeCategory: ContentSizeCategory?
    public let horizontalSizeClass: SizeClass
}
