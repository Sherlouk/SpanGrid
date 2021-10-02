//
// SpanGridCellMetadata.swift
//
// Copyright 2021 • James Sherlock
//

import SwiftUI

// MARK: - SpanGridCellMetadata

public struct SpanGridCellMetadata {
    public struct Size {
        /// The width of the cell being rendered.
        ///
        /// This will be wider than the width of a column in cases where the cell spans multiple columns.
        public let width: CGFloat
        
        /// The precalculated height for the cell.
        ///
        /// This will be returned when using a non-default row size strategy.
        public let height: CGFloat?
    }
    
    /// The size of the cell.
    public let size: Size
    
    /// The number of columns in the current layout.
    public let columnCount: Int
    
    /// Whether or not this cell is currently being highlighted by keyboard selection.
    ///
    /// This will always be `false` if you have keyboard selection disabled.
    public let isHighlighted: Bool
}

public extension View {
    /// Sets the width and height to the size provided by the metadata model.
    func frame(cellMetadata: SpanGridCellMetadata) -> some View {
        frame(width: cellMetadata.size.width)
            .frame(minHeight: cellMetadata.size.height)
    }
}
