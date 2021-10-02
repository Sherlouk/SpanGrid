//
// SpanGridSpanIndexCalculator.swift
//
// Copyright 2021 • James Sherlock
//

import SwiftUI

internal class SpanGridSpanIndexCalculator<Content: View, Data: Identifiable & SpanGridSizeInfoProvider> {
    var grid: SpanGrid<Content, Data>?
    
    var lastColumnCount: Int = -1
    
    // Maps cellIndex to spanIndex
    var cache: [Int: Int] = [:]
    
    // Maps spanIndex to cellIndex
    var reverseLookup: [Int: Int] = [:]
    
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
        
        var reverseCache = [Int: Int]()
        // reverseCache size will always be <= grid.data.count
        reverseCache.reserveCapacity(grid.data.count)
        
        var lastPartial = 0
        var lastCellIndex = 0
        
        let totalSpanIndex: Int = grid.data.reduce(0) { partialResult, gridData in
            // Populate any gaps in the reverse lookup cache.
            // This is appropriate where the last cell had a span of more than 1.
            (lastPartial...partialResult).forEach {
                reverseCache[$0] = lastCellIndex
            }
            
            // Set cache results for this cell
            temporaryCache[gridData.cellIndex] = partialResult
            reverseCache[partialResult] = gridData.cellIndex
            
            // Store current position for next loop cycle
            lastPartial = partialResult
            lastCellIndex = gridData.cellIndex
            
            return accumulateSpanIndex(partialResult: partialResult, gridData: gridData, columnCount: columnCount)
        }
        
        temporaryCache[grid.data.count] = totalSpanIndex
        reverseCache[totalSpanIndex] = grid.data.count
        
        cache = temporaryCache
        reverseLookup = reverseCache
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
