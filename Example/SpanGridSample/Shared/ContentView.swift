//
// ContentView.swift
//
// Copyright 2021 • James Sherlock
//

import SpanGrid
import SwiftUI

struct ContentView: View {
    let data = (0 ..< 30).map { offset -> ViewModel in
        ViewModel(id: offset, layoutSize: offset == 6 || offset == 19 ? .span(offset == 6 ? 3 : 2) : .cell)
    }
    
    var body: some View {
        SpanGrid(
            dataSource: data,
            keyboardNavigationOptions: .init(enabled: true, discoverabiliyEnabled: true)
        ) { _, metadata in
            Rectangle()
                .foregroundColor(metadata.isHighlighted ? .green : .red)
                .frame(minHeight: 100)
                .frame(cellMetadata: metadata)
        }
    }
    
    struct ViewModel: Identifiable, SpanGridSizeInfoProvider {
        let id: Int
        let layoutSize: SpanGridLayoutSize
    }
}
