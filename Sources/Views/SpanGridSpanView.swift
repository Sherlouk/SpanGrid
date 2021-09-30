//
// SpanGridSpanView.swift
//
// Copyright 2021 • James Sherlock
//

import SwiftUI

internal struct SpanGridSpanView<Content: View>: View {
    struct Column: Identifiable {
        let id: Int
        let isSpan: Bool
    }
    
    let layoutSize: SpanGridLayoutSize
    let prefixSpace: Int
    let columnSizeResult: SpanGridColumnSizeResult
    
    let content: (CGFloat) -> Content
    
    init(
        layoutSize: SpanGridLayoutSize,
        prefixSpace: Int,
        columnSizeResult: SpanGridColumnSizeResult,
        @ViewBuilder content: @escaping (CGFloat) -> Content
    ) {
        self.layoutSize = layoutSize
        self.prefixSpace = prefixSpace
        self.columnSizeResult = columnSizeResult
        self.content = content
    }
    
    var body: some View {
        let spanSize = layoutSize.spanSize(columnCount: columnSizeResult.columnCount)
        let columnWidth = columnSizeResult.tileWidth
        
        if spanSize == 1 {
            content(columnWidth)
        } else {
            let columnSpacing = columnSizeResult.interitemSpacing
            
            let columns = Array(1 ... spanSize + prefixSpace).map {
                Column(id: $0, isSpan: $0 == prefixSpace + 1)
            }
            
            ForEach(columns) { column in
                if column.isSpan {
                    content(((columnWidth + columnSpacing) * CGFloat(spanSize)) - columnSpacing)
                } else {
                    Color.clear
                }
            }
        }
    }
}
