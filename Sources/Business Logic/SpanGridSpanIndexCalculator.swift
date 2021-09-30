//
// SpanGridSpanIndexCalculator.swift
//
// Copyright 2021 • James Sherlock
//

import SwiftUI

internal class SpanGridSpanIndexCalculator<Content: View, Data: Identifiable & SpanGridSizeInfoProvider> {
    var grid: SpanGrid<Content, Data>?
    
    var lastColumnCount: Int = -1
    var cache: [Int: Int] = [:]
    
    func precalculateSpanIndex(columnCount: Int) {
        guard cache.isEmpty || columnCount != lastColumnCount else {
            return
        }
        
        if columnCount != lastColumnCount {
            print("[SpanIndexCalculator] Recalculating Cache")
            lastColumnCount = columnCount
        }
        
        guard let grid = grid else {
            fatalError("Grid not provided to SpanIndexCalculator")
        }
        
        var temporaryCache = [Int: Int]()
        temporaryCache.reserveCapacity(grid.data.count)
        
        let totalSpanIndex: Int = grid.data.reduce(0) { partialResult, gridData in
            temporaryCache[gridData.cellIndex] = partialResult
            return accumulateSpanIndex(partialResult: partialResult, gridData: gridData, columnCount: columnCount)
        }
        
        temporaryCache[grid.data.count] = totalSpanIndex
        cache = temporaryCache
    }
    
    func accumulateSpanIndex(partialResult: Int, gridData: SpanGridData<Data>, columnCount: Int) -> Int {
        let spaceOnRow = columnCount - (partialResult % columnCount)
        let desiredSpan = gridData.data.layoutSize.spanSize(columnCount: columnCount)

        if desiredSpan > spaceOnRow {
            return partialResult + desiredSpan + spaceOnRow
        }

        return partialResult + desiredSpan
    }
    
    func getSpanIndex(forItemWithOffset offset: Int, columnCount: Int) -> Int {
        if columnCount == 1 {
            // Optimisation: In a single column grid there can never be a difference between item offset and span index.
            // This is because every cell has a span of one.
            return offset
        }
        
        precalculateSpanIndex(columnCount: columnCount)
        
        if let cache = cache[offset] {
            return cache
        }
        
        guard let grid = grid else {
            fatalError("Grid not provided to SpanIndexCalculator")
        }
        
        print("[SpanIndexCalculator] Cache was missed, calculating on the fly.")
        
        return grid.data.prefix(offset).reduce(0) { partialResult, gridData in
            accumulateSpanIndex(partialResult: partialResult, gridData: gridData, columnCount: columnCount)
        }
    }
}
