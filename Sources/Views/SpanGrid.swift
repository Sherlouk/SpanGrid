//
//  SpanGrid.swift
//  SpanGrid
//
//  Created by James Sherlock on 26/09/2021.
//

import SwiftUI

/// SpanGrid is a wrapper around LazyVGrid which provides a highly flexible layout.
///
/// The number of columns will change based on the parent view size, and accessibility preferences.
/// The height of the tiles will be provided in order to keep them consistent across a single row.
/// Items can span a row (all columns), or a single tile (one column).
public struct SpanGrid<Content: View, Data: Identifiable & SpanGridSizeInfoProvider>: View {
    @Environment(\.sizeCategory) var sizeCategory
    
    @State private var rowHeightLookup: [Int: CGFloat] = [:]
    
    /*
     We use a publisher to detect a change in size category in order to reset the row height cache.
     This is important as the publisher is triggered at the same time as the environment variable changes.
     
     If you detect a change in the environment, and then reset the row height, you refresh the view twice and in that
     you introduce a race condition where sometimes the second update is not processed correctly and tiles have the
     incorrect size set.
     */
    let sizeCategoryPublisher = NotificationCenter.default.publisher(for: UIContentSizeCategory.didChangeNotification)
    let widthChangePublisher = SpanGridWidthListener.publisher
    
    let data: [SpanGridData<Data>]
    let content: (Data, SpanGridCellMetadata) -> Content
    
    let columnSizeStrategy: SpanGridColumnSizeStrategy
    let rowSizeStrategy: SpanGridRowSizeStrategy
    
    let spanIndexCalculator = SpanGridSpanIndexCalculator<Content, Data>()
    
    public init(
        dataSource: [Data],
        columnSizeStrategy: SpanGridColumnSizeStrategy = .dynamic,
        rowSizeStrategy: SpanGridRowSizeStrategy = .none,
        @ViewBuilder content: @escaping (Data, SpanGridCellMetadata) -> Content
    ) {
        data = (0 ..< dataSource.count).map {
            SpanGridData(cellIndex: $0, data: dataSource[$0])
        }
        
        self.content = content
        
        self.columnSizeStrategy = columnSizeStrategy
        self.rowSizeStrategy = rowSizeStrategy
        
        spanIndexCalculator.grid = self
        rowHeightLookup.reserveCapacity(data.count)
    }
    
    func calculateCellPrefix(forItem item: SpanGridData<Data>, columnCount: Int, spanIndex: Int) -> Int {
        if columnCount == 1 {
            // Optimisation: There will never be empty cells in a list (single column grid).
            return 0
        }
        
        let desiredSpan = item.data.layoutSize.spanSize(columnCount: columnCount)
        
        if desiredSpan == 1 {
            // Optimisation: No point running the maths if the span is a single cell.
            // It will never be prefixed by an empty cell.
            return 0
        }
        
        let spaceOnRow: Int = columnCount - (spanIndex % columnCount)
        
        if desiredSpan > spaceOnRow {
            return spaceOnRow
        }
        
        return 0
    }
    
    func heightForRow(
        forItem _: SpanGridData<Data>,
        columnSizeResult: SpanGridColumnSizeResult,
        rowOffset: Int
    ) -> CGFloat? {
        switch rowSizeStrategy {
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
    
    public var body: some View {
        #if DEBUG
            if #available(iOS 15.0, *) {
                Self._printChanges()
            }
        #endif
        
        return GeometryReader { proxy in
            let columnSizeResult = columnSizeStrategy.calculateResult(
                width: proxy.size.width,
                sizeCategory: sizeCategory
            )
            
            let columns: [GridItem] = .init(
                repeating: GridItem(
                    .fixed(columnSizeResult.tileWidth),
                    spacing: columnSizeResult.interitemSpacing,
                    alignment: .topLeading
                ),
                count: columnSizeResult.columnCount
            )
            
            ScrollView {
                LazyVGrid(
                    columns: columns,
                    alignment: .center,
                    spacing: columnSizeResult.interitemSpacing
                ) {
                    ForEach(data) { viewModel in
                        createSpanView(
                            viewModel: viewModel,
                            columnSizeResult: columnSizeResult
                        )
                    }
                }
            }
            .onPreferenceChange(SpanGridRowPreferenceKey.self) { newValue in rowHeightLookup = newValue }
            .onReceive(sizeCategoryPublisher) { _ in rowHeightLookup = [:] }
            .onReceive(widthChangePublisher) { _ in rowHeightLookup = [:] }
            .overlay(SpanGridWidthListener().allowsHitTesting(false))
        }
    }
    
    @ViewBuilder func createSpanView(viewModel: SpanGridData<Data>, columnSizeResult: SpanGridColumnSizeResult) -> some View {
        let columnCount = columnSizeResult.columnCount
        
        let spanSize = viewModel.data.layoutSize.spanSize(columnCount: columnCount)
        let spanIndex = spanIndexCalculator.getSpanIndex(forItemWithOffset: viewModel.cellIndex, columnCount: columnCount)
        
        SpanGridSpanView(
            layoutSize: viewModel.data.layoutSize,
            prefixSpace: calculateCellPrefix(forItem: viewModel, columnCount: columnCount, spanIndex: spanIndex),
            columnSizeResult: columnSizeResult
        ) { width in
            let rowOffset = spanIndex / columnSizeResult.columnCount
            
            let metadata = SpanGridCellMetadata(
                size: .init(
                    width: width,
                    height: heightForRow(
                        forItem: viewModel,
                        columnSizeResult: columnSizeResult,
                        rowOffset: rowOffset
                    )
                ),
                columnCount: columnSizeResult.columnCount
            )
            
            let view = content(viewModel.data, metadata)
            
            switch rowSizeStrategy {
            // Optimisation: No value to be gained by measuring row height if the span is the full
            // width of the grid. This is because there will only be one cell on the row which can
            // determine it's own height.
            case .largest where spanSize != columnSizeResult.columnCount:
                view.overlay(SpanGridDetermineRowHeight(rowOffset: rowOffset))
            default:
                view
            }
        }
    }
}
