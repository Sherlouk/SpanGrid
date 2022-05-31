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
        
        /// The configuration for the dynamic column size strategy. Determines exactly how the columns should be laid out.
        ///
        /// Parameter definitions reference "compact" and "regular" width classes. A compact width class is often a phone in portrait mode, but some larger
        /// phones or phones in landscape may return a regular width class. Likewise, a tablet might return a compact width class when split screen or slide over
        /// is being used.
        ///
        /// - Parameters:
        ///   - maximumGridWidth: The maximum total width (in points) that the grid should consume.
        ///   Consider larger tablets (iPad), widescreen displays (macOS) or televisions (tvOS). Default is 1160pt.
        ///   - maximumGridWidthAccessibility: The maximum total width (in poitns) that the grid should consume when the user's device is using an
        ///   accessible font size. Default is 840. This is often smaller than the maximum width for normal font, as the layout intentionally moves to a single
        ///   column to allow for easier reading and to maximise the content which can be seen on one line.
        ///   - minimumTileWidthCompact: The minimum width of a single tile for a compact width class.
        ///   - minimumTileWidthRegular: The minimum width of a single tile for a regular width class.
        ///   - interitemSpacingCompact: The amount of spacing between two tiles for a compact width class.
        ///   - interitemSpacingRegular: The amount of spacing between two tiles for a regular width class.
        ///   - minimumGutterCompact: The amount of space in the 'gutter' (to the left and right of the tiles) for a compact width class.
        ///   - minimumGutterRegular: The amount of space in the 'gutter' (to the left and right of the tiles) for a regular width class.
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
        traits: SpanGridTraitCollection
    ) -> SpanGridColumnSizeResult {
        let compactLayout = traits.horizontalSizeClass == .compact
        
        let minimumGutter = compactLayout ? configuration.minimumGutterCompact : configuration.minimumGutterRegular
        let minimumTileWidth = compactLayout ? configuration.minimumTileWidthCompact : configuration.minimumTileWidthRegular
        let interitemSpacing = compactLayout ? configuration.interitemSpacingRegular : configuration.interitemSpacingCompact
        
        var usableWidth = min(width, configuration.maximumGridWidth) - minimumGutter
        
        let columnSqueezeCount = usableWidth / minimumTileWidth
        var targetColumnCount = max(min(floor(columnSqueezeCount), CGFloat(maximumColumnCount)), 1)
        
        if traits.sizeCategory?.isAccessibilityCategory == true {
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
