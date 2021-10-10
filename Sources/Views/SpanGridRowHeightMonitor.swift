//
// SpanGridRowHeightMonitor.swift
//
// Copyright 2021 • James Sherlock
//

import SwiftUI

// MARK: - SpanGridRowHeightMonitor

struct SpanGridRowHeightMonitor: View {
    let widthChangePublisher = SpanGridWidthListener.getPublisher()
    
    /*
     We use a publisher to detect a change in size category in order to reset the row height cache.
     This is important as the publisher is triggered at the same time as the environment variable changes.
     
     If you detect a change in the environment, and then reset the row height, you refresh the view twice and in that
     you introduce a race condition where sometimes the second update is not processed correctly and tiles have the
     incorrect size set.
     */
    #if os(iOS)
    let sizeCategoryPublisher = NotificationCenter.default.publisher(for: UIContentSizeCategory.didChangeNotification)
    #endif
    
    let rowHeightStorage: SpanGridRowHeightStorage
    
    var body: some View {
        EmptyView()
            .onPreferenceChange(SpanGridRowPreferenceKey.self, perform: rowHeightStorage.set)
            .onReceive(widthChangePublisher) { _ in rowHeightStorage.clear() }
        #if os(iOS)
            .onReceive(sizeCategoryPublisher) { _ in rowHeightStorage.clear() }
        #endif
    }
}

// MARK: - SpanGridRowHeightStorage

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
