//
// SpanGridKeyboardNavigation.swift
//
// Copyright 2021 • James Sherlock
//

import Logging
import SwiftUI

class SpanGridKeyboardNavigation<Content: View, Data: Identifiable & SpanGridSizeInfoProvider>: ObservableObject {
    @Published var currentItem: Int? = nil
    
    let logger = Logger(label: "uk.sherlo.spangrid.keyboard-navigation")
    var grid: SpanGrid<Content, Data>?
    private var currentSpanIndex: Int = 0
    
    func setCurrentItem(newValue: Int) -> Bool {
        guard let grid = grid else {
            logger.error("Lost grid reference, ignoring.", metadata: [ "value": .stringConvertible(newValue) ])
            return false
        }
        
        guard (0 ..< grid.data.count).contains(newValue) else {
            logger.info("Value out of bounds, ignoring.", metadata: [ "value": .stringConvertible(newValue) ])
            return false
        }
        
        guard newValue != currentItem else {
            logger.trace("No change in value, ignoring.", metadata: [ "value": .stringConvertible(newValue) ])
            return false
        }
        
        currentItem = newValue
        return true
    }
    
    @available(tvOS, unavailable)
    @available(watchOS, unavailable)
    func processDirection(_ columnCount: Int) -> (SpanGridKeyboardNavigationShortcuts.Direction) -> Void {
        { [weak self] direction in
            guard let strongSelf = self else {
                return
            }
            
            guard let grid = strongSelf.grid else {
                strongSelf.logger.error("Tried to process direction without setting `grid`.")
                return
            }
            
            // If this is the first time they've pressed a shortcut, then we start them in the top left.
            if strongSelf.currentItem == nil {
                strongSelf.logger.trace("First input, setting to first item.")
                _ = strongSelf.setCurrentItem(newValue: 0)
                return
            }
            
            strongSelf.logger.trace("Handling '\(direction.rawValue)' keyboard input")
            
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
                strongSelf.logger.trace("Direction puts selection out of bounds, ignoring.")
                return
            }
            
            guard let newItem = grid.spanIndexCalculator.reverseLookup[mutableSpanIndex] else {
                strongSelf.logger.error("Unknown span index, ignoring. Input: '\(mutableSpanIndex)'.")
                return
            }
            
            if strongSelf.setCurrentItem(newValue: newItem) {
                strongSelf.currentSpanIndex = mutableSpanIndex
            }
        }
    }
    
    func isInvalidCell(spanIndex: Int, columnCount: Int, grid: SpanGrid<Content, Data>) -> Bool {
        guard let item = grid.spanIndexCalculator.reverseLookup[spanIndex] else {
            logger.error("Unknown span index, ignoring. Input: '\(spanIndex)'.")
            return false
        }
        
        guard (0 ..< grid.data.count).contains(item) else {
            logger.trace("Span index places item out of bounds, ignoring. Input: '\(spanIndex)=\(item)'.")
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
