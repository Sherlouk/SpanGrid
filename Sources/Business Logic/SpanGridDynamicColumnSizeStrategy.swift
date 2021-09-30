//
//  SpanGridDynamicColumnSizeStrategy.swift
//  SpanGrid
//
//  Created by James Sherlock on 26/09/2021.
//

import SwiftUI

internal struct SpanGridDynamicColumnSizeStrategy {
    
    let maximumColumnCount: Int = 3
    
    let maximumGridWidth: CGFloat = 960
    let maximumGridWidthAccessibility: CGFloat = 600
    
    let minimumTileWidth: CGFloat = 232
    
    let minimumGutterCompact: CGFloat = 20 * 2
    let minimumGutterRegular: CGFloat = 32 * 2
    
    let interitemSpacingCompact: Int = 16
    let interitemSpacingRegular: Int = 24
    
    func calculate(
        width: CGFloat,
        sizeCategory: ContentSizeCategory
    ) -> SpanGridColumnSizeResult {
        #warning("Design: Need to understand these breakpoints more.")
        let wideSystem = width > 800
        
        let minimumGutter = wideSystem ? minimumGutterRegular : minimumGutterCompact
        
        var usableWidth = min(width, maximumGridWidth) - minimumGutter
        
        let columnSqueezeCount = usableWidth / minimumTileWidth
        var targetColumnCount = max(min(floor(columnSqueezeCount), CGFloat(maximumColumnCount)), 1)
        
        if sizeCategory.isAccessibilityCategory {
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
