//
// SpanGridLayoutSize.swift
//
// Copyright 2021 • James Sherlock
//

import Foundation

// MARK: - SpanGridLayoutSize

public enum SpanGridLayoutSize {
    /// Spans a single column on a single row.
    case cell
    
    /// Spans all columns on a single row.
    case row
    
    /// Spans a provided amount of columns on a given row.
    ///
    /// - Warning: If this number is larger than the total number of columns, then it will use use the column count instead (same functionality as `row`).
    ///            If there is not enough space on a row to add this cell, then it will create whitespace on that row and start a new row.
    case span(Int)
}

// MARK: - SpanGridSizeInfoProvider

public protocol SpanGridSizeInfoProvider {
    var layoutSize: SpanGridLayoutSize { get }
}

internal extension SpanGridLayoutSize {
    func spanSize(columnCount: Int) -> Int {
        switch self {
        case .cell:
            return 1
        case .row:
            return columnCount
        case .span(let spanSize):
            return min(spanSize, columnCount)
        }
    }
}
