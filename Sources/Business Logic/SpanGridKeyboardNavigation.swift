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
    
    @available(tvOS, unavailable)
    @available(watchOS, unavailable)
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
            
            let spanPrefix = grid.calculateCellPrefix(
                spanSize: spanSize,
                columnCount: columnCount,
                spanIndex: direction == .left ? mutableSpanIndex : originalSpanIndex
            )
            
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
                repeat {
                    mutableSpanIndex -= columnCount
                } while strongSelf.isInvalidCell(spanIndex: mutableSpanIndex, columnCount: columnCount, grid: grid)
            case .down:
                repeat {
                    mutableSpanIndex += columnCount
                } while strongSelf.isInvalidCell(spanIndex: mutableSpanIndex, columnCount: columnCount, grid: grid)
            }
            
            if mutableSpanIndex < 0 {
                return
            }
            
            guard let newItem = grid.spanIndexCalculator.reverseLookup[mutableSpanIndex] else {
                print("[SpanGridKeyboardNavigation] Unknown Span Index: \(mutableSpanIndex)")
                return
            }
            
            if strongSelf.setCurrentItem(newValue: newItem) {
                strongSelf.currentSpanIndex = mutableSpanIndex
            }
        }
    }
    
    func isInvalidCell(spanIndex: Int, columnCount: Int, grid: SpanGrid<Content, Data>) -> Bool {
        guard let item = grid.spanIndexCalculator.reverseLookup[spanIndex] else {
            return false
        }
        
        guard (0 ..< grid.data.count).contains(item) else {
            return false
        }
        
        let spanSize = grid.data[item].data.layoutSize.spanSize(columnCount: columnCount)
        
        let originalSpanIndex = grid.spanIndexCalculator.getSpanIndex(forItemWithOffset: item, columnCount: columnCount)
        let spanIndexOffset = spanIndex - originalSpanIndex
        
        let spanPrefix = grid.calculateCellPrefix(spanSize: spanSize, columnCount: columnCount, spanIndex: originalSpanIndex)
        
        if spanIndexOffset < spanPrefix {
            return true
        }
        
        return false
    }
}
