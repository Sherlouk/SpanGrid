//
//  SpanGridColumnSizeStrategy.swift
//  SpanGrid
//
//  Created by James Sherlock on 26/09/2021.
//

import SwiftUI

public enum SpanGridColumnSizeStrategy {
    case fixed(count: Int, width: CGFloat, spacing: CGFloat)
    case custom((CGFloat) -> SpanGridColumnSizeResult)
    case dynamic
}

public struct SpanGridColumnSizeResult {
    /// The total number of columns within a single row.
    public let columnCount: Int
    
    /// The amount of spacing inbetween each item in a row horizontally, and between each rows vertically.
    public let interitemSpacing: CGFloat
    
    /// The width of an individual tile within a single row.
    public let tileWidth: CGFloat
    
    public init(columnCount: Int, interitemSpacing: CGFloat, tileWidth: CGFloat) {
        self.columnCount = columnCount
        self.interitemSpacing = interitemSpacing
        self.tileWidth = tileWidth
    }
}

internal extension SpanGridColumnSizeStrategy {
    
    func calculateResult(
        width: CGFloat,
        sizeCategory: ContentSizeCategory
    ) -> SpanGridColumnSizeResult {
        switch self {
        case .fixed(let count, let width, let spacing):
            return SpanGridColumnSizeResult(
                columnCount: count,
                interitemSpacing: spacing,
                tileWidth: width
            )
            
        case .dynamic:
            return SpanGridDynamicColumnSizeStrategy().calculate(
                width: width,
                sizeCategory: sizeCategory
            )
            
        case .custom(let implementation):
            return implementation(width)
        }
    }
    
}
