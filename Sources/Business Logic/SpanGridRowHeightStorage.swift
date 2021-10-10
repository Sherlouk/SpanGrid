//
// SpanGridRowHeightStorage.swift
//
// Copyright 2021 • James Sherlock
//

import SwiftUI

class SpanGridRowHeightStorage: ObservableObject {
    @Published var rowHeightLookup: [Int: CGFloat] = [:]
    
    let strategy: SpanGridRowSizeStrategy
    
    init(strategy: SpanGridRowSizeStrategy) {
        self.strategy = strategy
    }
    
    func clear() {
        rowHeightLookup = [:]
    }
    
    func set(_ newValue: [Int: CGFloat]) {
        rowHeightLookup = newValue
    }
    
    func heightForRow(
        columnSizeResult: SpanGridColumnSizeResult,
        rowOffset: Int
    ) -> CGFloat? {
        switch strategy {
        case .fixed(let height):
            return height
        case .largest where columnSizeResult.columnCount == 1:
            // Optimisation: There is no value storing/retrieving row heights when there is nothing to align on
            return nil
        case .largest:
            return rowHeightLookup[rowOffset]
        case .square:
            return columnSizeResult.tileWidth
        case .none:
            return nil
        }
    }
}
