//
// SpanGrid.swift
//
// Copyright 2021 • James Sherlock
//

import SwiftUI

/// SpanGrid is a wrapper around LazyVGrid which provides a highly flexible layout.
///
/// The number of columns will change based on the parent view size, and accessibility preferences.
/// The height of the tiles will be provided in order to keep them consistent across a single row.
/// Items can span a row (all columns), or a single tile (one column).
public struct SpanGrid<Content: View, Data: Identifiable & SpanGridSizeInfoProvider>: View {
    @Environment(\.sizeCategory) var sizeCategory
    
    #if os(iOS)
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    #endif
    
    /// An array containing all of the data for the grid.
    let data: [SpanGridData<Data>]
    
    /// A closure which produces a SwiftUI view for every piece of data within the grid.
    let content: (Data, SpanGridCellMetadata) -> Content
    
    /// Defines how to calculate column widths for the grid.
    let columnSizeStrategy: SpanGridColumnSizeStrategy
    
    /// Defines how to calculate row heights for the grid.
    let rowSizeStrategy: SpanGridRowSizeStrategy
    
    /// The amount of spacing added to the top and bottom of the scroll view
    let verticalPadding: CGFloat
    
    /// Calculates the span index for each item in the grid.
    /// The "span index" is the sum of the column spans of all items before it.
    let spanIndexCalculator = SpanGridSpanIndexCalculator<Content, Data>()
    
    /// Stores information about whether keyboard navigation is enabled, where supported.
    let keyboardNavigationOptions: SpanGridKeyboardNavigationOptions
    
    @ObservedObject var keyboardNavigationCoordinator = SpanGridKeyboardNavigation<Content, Data>()
    @ObservedObject var rowHeightStorage: SpanGridRowHeightStorage
    
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
    
    public init(
        dataSource: [Data],
        columnSizeStrategy: SpanGridColumnSizeStrategy = .dynamicProvider(),
        rowSizeStrategy: SpanGridRowSizeStrategy = .none,
        keyboardNavigationOptions: SpanGridKeyboardNavigationOptions = .init(),
        verticalPadding: CGFloat = 0,
        @ViewBuilder content: @escaping (Data, SpanGridCellMetadata) -> Content
    ) {
        data = (0 ..< dataSource.count).map {
            SpanGridData(cellIndex: $0, data: dataSource[$0])
        }
        
        self.content = content
        
        self.columnSizeStrategy = columnSizeStrategy
        self.rowSizeStrategy = rowSizeStrategy
        rowHeightStorage = .init(strategy: rowSizeStrategy)
        self.keyboardNavigationOptions = keyboardNavigationOptions
        self.verticalPadding = verticalPadding
        
        spanIndexCalculator.grid = self
        rowHeightStorage.rowHeightLookup.reserveCapacity(data.count)
        
        if keyboardNavigationOptions.enabled {
            keyboardNavigationCoordinator.grid = self
        }
    }
    
    public var body: some View {
        GeometryReader { proxy in
            let columnSizeResult = columnSizeStrategy.calculateResult(
                width: proxy.size.width,
                traits: buildTraitCollection()
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
                .padding(.vertical, verticalPadding)
            }
            .onPreferenceChange(SpanGridRowPreferenceKey.self, perform: rowHeightStorage.set)
            .onReceive(widthChangePublisher) { _ in rowHeightStorage.clear() }
            #if os(iOS)
                .onReceive(sizeCategoryPublisher) { _ in rowHeightStorage.clear() }
            #endif
            .overlay(SpanGridWidthListener(dynamicConfiguration: columnSizeStrategy.dynamicConfiguration)
                .allowsHitTesting(false))
            #if os(iOS)
                .overlay(SpanGridKeyboardNavigationShortcuts(
                    options: keyboardNavigationOptions,
                    callback: keyboardNavigationCoordinator.processDirection(columnSizeResult.columnCount)
                ))
            #endif
        }
    }
    
    @ViewBuilder func createSpanView(viewModel: SpanGridData<Data>, columnSizeResult: SpanGridColumnSizeResult) -> some View {
        let columnCount = columnSizeResult.columnCount
        
        let spanSize = viewModel.data.layoutSize.spanSize(columnCount: columnCount)
        let spanIndex = spanIndexCalculator.getSpanIndex(forItemWithOffset: viewModel.cellIndex, columnCount: columnCount)
        let prefixSpace = spanIndexCalculator.calculateCellPrefix(spanSize: spanSize, columnCount: columnCount, spanIndex: spanIndex)
        SpanGridSpanView(
            layoutSize: viewModel.data.layoutSize,
            prefixSpace: prefixSpace,
            columnSizeResult: columnSizeResult
        ) { width in
            let rowOffset = (spanIndex + prefixSpace) / columnSizeResult.columnCount
            
            let metadata = SpanGridCellMetadata(
                size: .init(
                    width: width,
                    height: rowHeightStorage.heightForRow(
                        columnSizeResult: columnSizeResult,
                        rowOffset: rowOffset
                    )
                ),
                columnCount: columnSizeResult.columnCount,
                isHighlighted: keyboardNavigationCoordinator.currentItem == viewModel.cellIndex
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
    
    private func buildTraitCollection() -> SpanGridTraitCollection {
        #if os(iOS)
        SpanGridTraitCollection(
            sizeCategory: sizeCategory,
            horizontalSizeClass: horizontalSizeClass == .regular ? .regular : .compact
        )
        #elseif os(tvOS)
        SpanGridTraitCollection(
            sizeCategory: sizeCategory,
            horizontalSizeClass: .regular
        )
        #else
        SpanGridTraitCollection(
            sizeCategory: nil,
            horizontalSizeClass: .regular
        )
        #endif
    }
}
