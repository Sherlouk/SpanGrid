//
// SpanGridDynamicColumnSizeStrategy.swift
//
// Copyright 2021 • James Sherlock
//

import SwiftUI

public struct SpanGridDynamicColumnSizeStrategy {
    public struct Configuration {
        let maximumGridWidth: CGFloat
        let maximumGridWidthAccessibility: CGFloat
        
        let minimumTileWidthCompact: CGFloat
        let minimumTileWidthRegular: CGFloat
        
        let interitemSpacingCompact: Int
        let interitemSpacingRegular: Int
        
        let minimumGutterCompact: CGFloat
        let minimumGutterRegular: CGFloat
        
        public init(
            maximumGridWidth: CGFloat = 1160,
            maximumGridWidthAccessibility: CGFloat = 840,
            minimumTileWidthCompact: CGFloat = 270,
            minimumTileWidthRegular: CGFloat = 232,
            interitemSpacingCompact: Int = 16,
            interitemSpacingRegular: Int = 24,
            minimumGutterCompact: CGFloat = 24 * 2,
            minimumGutterRegular: CGFloat = 32 * 2
        ) {
            self.maximumGridWidth = maximumGridWidth
            self.maximumGridWidthAccessibility = maximumGridWidthAccessibility
            self.minimumTileWidthCompact = minimumTileWidthCompact
            self.minimumTileWidthRegular = minimumTileWidthRegular
            self.interitemSpacingCompact = interitemSpacingCompact
            self.interitemSpacingRegular = interitemSpacingRegular
            self.minimumGutterCompact = minimumGutterCompact
            self.minimumGutterRegular = minimumGutterRegular
        }
    }
    
    let maximumColumnCount: Int
    let configuration: Configuration
    
    internal init(maximumColumnCount: Int = 3, configuration: Configuration = .init()) {
        self.maximumColumnCount = maximumColumnCount
        self.configuration = configuration
    }
    
    func calculate(
        width: CGFloat,
        traits: UITraitCollection
    ) -> SpanGridColumnSizeResult {
        let compactLayout = traits.horizontalSizeClass == .compact
        
        let minimumGutter = compactLayout ? configuration.minimumGutterCompact : configuration.minimumGutterRegular
        let minimumTileWidth = compactLayout ? configuration.minimumTileWidthCompact : configuration.minimumTileWidthRegular
        let interitemSpacing = compactLayout ? configuration.interitemSpacingRegular : configuration.interitemSpacingCompact
        
        var usableWidth = min(width, configuration.maximumGridWidth) - minimumGutter
        
        let columnSqueezeCount = usableWidth / minimumTileWidth
        var targetColumnCount = max(min(floor(columnSqueezeCount), CGFloat(maximumColumnCount)), 1)
        
        if traits.preferredContentSizeCategory.isAccessibilityCategory {
            targetColumnCount = 1
            usableWidth = min(usableWidth, configuration.maximumGridWidthAccessibility + minimumGutter)
        }
        
        let interitemSpacingTotal = CGFloat(interitemSpacing * (Int(targetColumnCount) - 1))
        
        if Int(targetColumnCount) == 1 {
            // Single column content does not include a gutter
            usableWidth += minimumGutter
        }
        
        let tileWidth = (usableWidth - interitemSpacingTotal) / targetColumnCount
        
        return SpanGridColumnSizeResult(
            columnCount: Int(targetColumnCount),
            interitemSpacing: CGFloat(interitemSpacing),
            tileWidth: tileWidth
        )
    }
}
