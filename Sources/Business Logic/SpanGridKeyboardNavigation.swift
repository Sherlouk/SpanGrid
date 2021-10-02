//
// SpanGridKeyboardNavigation.swift
//
// Copyright 2021 • James Sherlock
//

import SwiftUI

class SpanGridKeyboardNavigation<Content: View, Data: Identifiable & SpanGridSizeInfoProvider>: ObservableObject {
    @Published var currentItem: Int? = nil
    
    var grid: SpanGrid<Content, Data>?
    private var currentSpanIndex: Int = 0
    
    func setCurrentItem(newValue: Int) -> Bool {
        guard let grid = grid else {
            // Lost grid reference
            return false
        }
        
        guard (0 ..< grid.data.count).contains(newValue) else {
            // Out of bounds
            return false
        }
        
        guard newValue != currentItem else {
            // No change in value
            return false
        }
        
        currentItem = newValue
        return true
    }
    
    func processDirection(_ columnCount: Int) -> (SpanGridKeyboardNavigationShortcuts.Direction) -> Void {
        { [weak self] direction in
            guard let strongSelf = self, let grid = strongSelf.grid else {
                return
            }
            
            // If this is the first time they've pressed a shortcut, then we start them in the top left.
            if strongSelf.currentItem == nil {
                _ = strongSelf.setCurrentItem(newValue: 0)
                return
            }
            
            let currentItem = strongSelf.currentItem ?? 0
            var mutableSpanIndex = strongSelf.currentSpanIndex
            let spanSize = grid.data[currentItem].data.layoutSize.spanSize(columnCount: columnCount)
            
            let originalSpanIndex = grid.spanIndexCalculator.getSpanIndex(forItemWithOffset: currentItem, columnCount: columnCount)
            let spanIndexOffset = mutableSpanIndex - originalSpanIndex
            
            #warning("Bug Fix: We need to take into account cell prefix size for whitespace")
            let spanPrefix = grid.calculateCellPrefix(spanSize: spanSize, columnCount: columnCount, spanIndex: mutableSpanIndex)
            
            switch direction {
            case .left where spanSize == 1:
                mutableSpanIndex -= spanSize - spanPrefix
            case .left:
                mutableSpanIndex -= spanSize - (spanSize - spanIndexOffset) + 1 - spanPrefix
                
            case .right where spanSize == 1:
                mutableSpanIndex += spanSize + spanPrefix
            case .right:
                mutableSpanIndex += spanSize - spanIndexOffset + spanPrefix
                
            case .up:
                mutableSpanIndex -= columnCount
            case .down:
                mutableSpanIndex += columnCount
            }
            
            if mutableSpanIndex < 0 {
                return
            }
            
            guard let newItem = strongSelf.getItem(forSpanIndex: mutableSpanIndex, grid: grid) else {
                return
            }
            
            if strongSelf.setCurrentItem(newValue: newItem) {
                strongSelf.currentSpanIndex = mutableSpanIndex
            }
        }
    }
    
    func getItem(forSpanIndex mutableSpanIndex: Int, grid: SpanGrid<Content, Data>) -> Int? {
        #warning("Optimisation: Cache a dictionary of spanIndex: itemIndex for the full range of data?")
        let spanCache = grid.spanIndexCalculator.cache.sorted(by: { $0.key < $1.key })
        var lastItem: Int?
        
        for item in spanCache {
            if item.value >= mutableSpanIndex {
                let diff = item.value - mutableSpanIndex
                
                if diff > 0 {
                    return lastItem ?? item.key
                } else {
                    return item.key
                }
            }
            
            lastItem = item.key
        }
        
        return nil
    }
}
