//
//  SpanGridRowSizeStrategy.swift
//  SpanGrid
//
//  Created by James Sherlock on 27/09/2021.
//

import SwiftUI

public enum SpanGridRowSizeStrategy {
    /// The height of all cells will be the same fixed size.
    case fixed(height: CGFloat)
    
    /// The height of the cell will be determined by the largest in the given row.
    /// This means all cells will be the same equal height.
    /// Each row may receive a different height.
    case largest
    
    /// The height of each cell will be the same as the width of a single column.
    case square
    
    /// No height will be provided by the grid.
    case none
}
