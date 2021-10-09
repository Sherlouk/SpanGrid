//
// SpanGridColumnSizeStrategy.swift
//
// Copyright 2021 • James Sherlock
//

import SwiftUI

// MARK: - SpanGridColumnSizeStrategy

public enum SpanGridColumnSizeStrategy {
    case fixed(count: Int, width: CGFloat, spacing: CGFloat)
    case custom((CGFloat, SpanGridTraitCollection) -> SpanGridColumnSizeResult)
    case dynamic(count: Int, configuration: SpanGridDynamicColumnSizeStrategy.Configuration)
    
    public static func dynamicProvider(
        count: Int = 3,
        configuration: SpanGridDynamicColumnSizeStrategy.Configuration = .init()
    ) -> SpanGridColumnSizeStrategy {
        .dynamic(count: count, configuration: configuration)
    }
    
    var dynamicConfiguration: SpanGridDynamicColumnSizeStrategy.Configuration? {
        switch self {
        case .dynamic(_, let configuration):
            return configuration
        default:
            return nil
        }
    }
}

// MARK: - SpanGridColumnSizeResult

public struct SpanGridColumnSizeResult {
    /// The total number of columns within a single row.
    public let columnCount: Int
    
    /// The amount of spacing inbetween each item in a row horizontally.
    public let interitemSpacing: CGFloat
    
    /// The amount of spacing inbetween each rows vertically.
    public let interrowSpacing: CGFloat
    
    /// The width of an individual tile within a single row.
    public let tileWidth: CGFloat
    
    public init(columnCount: Int, interitemSpacing: CGFloat, interrowSpacing: CGFloat? = nil, tileWidth: CGFloat) {
        self.columnCount = columnCount
        self.interitemSpacing = interitemSpacing
        self.interrowSpacing = interrowSpacing ?? interitemSpacing
        self.tileWidth = tileWidth
    }
}

internal extension SpanGridColumnSizeStrategy {
    func calculateResult(
        width: CGFloat,
        traits: SpanGridTraitCollection
    ) -> SpanGridColumnSizeResult {
        switch self {
        case .fixed(let count, let width, let spacing):
            return SpanGridColumnSizeResult(
                columnCount: count,
                interitemSpacing: spacing,
                tileWidth: width
            )
            
        case .dynamic(let columnCount, let configuration):
            return SpanGridDynamicColumnSizeStrategy(
                maximumColumnCount: columnCount,
                configuration: configuration
            ).calculate(
                width: width,
                traits: traits
            )
            
        case .custom(let implementation):
            return implementation(width, traits)
        }
    }
}
