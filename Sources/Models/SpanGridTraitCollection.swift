//
// SpanGridTraitCollection.swift
//
// Copyright 2021 • James Sherlock
//

import Foundation
import SwiftUI

public struct SpanGridTraitCollection {
    public enum SizeClass: Equatable {
        case regular
        case compact
    }
    
    public let sizeCategory: ContentSizeCategory?
    public let horizontalSizeClass: SizeClass
}
