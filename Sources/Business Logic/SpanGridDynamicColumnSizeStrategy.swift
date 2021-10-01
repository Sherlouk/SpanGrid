//
// SpanGridDynamicColumnSizeStrategy.swift
//
// Copyright 2021 • James Sherlock
//

import SwiftUI

internal struct SpanGridDynamicColumnSizeStrategy {
    let maximumColumnCount: Int = 3
    
    let maximumGridWidth: CGFloat = 1160
    let maximumGridWidthAccessibility: CGFloat = 600
    
    let minimumTileWidth: CGFloat = 232
    
    let minimumGutterCompact: CGFloat = 24 * 2
    let minimumGutterRegular: CGFloat = 32 * 2
    
    let interitemSpacingCompact: Int = 16
    let interitemSpacingRegular: Int = 24
    
    func calculate(
        width: CGFloat,
        traits: UITraitCollection
    ) -> SpanGridColumnSizeResult {
        let wideSystem = width > 840
        
        let minimumGutter = wideSystem ? minimumGutterRegular : minimumGutterCompact
        
        let minimumTileWidth = traits.horizontalSizeClass == .compact ? 270 : minimumTileWidth
        
        var usableWidth = min(width, maximumGridWidth) - minimumGutter
        
        let columnSqueezeCount = usableWidth / minimumTileWidth
        var targetColumnCount = max(min(floor(columnSqueezeCount), CGFloat(maximumColumnCount)), 1)
        
        if traits.preferredContentSizeCategory.isAccessibilityCategory {
            targetColumnCount = 1
            usableWidth = min(usableWidth, maximumGridWidthAccessibility + minimumGutter)
        }
        
        let interitemSpacing = wideSystem ? interitemSpacingRegular : interitemSpacingCompact
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
