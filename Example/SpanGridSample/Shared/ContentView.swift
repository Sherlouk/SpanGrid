//
// ContentView.swift
//
// Copyright 2021 • James Sherlock
//

import SpanGrid
import SwiftUI

// MARK: - ContentView

struct ContentView: View {
    let data = (0 ..< 30).map { offset -> ViewModel in
        ViewModel(id: offset, layoutSize: offset == 6 || offset == 19 ? .span(offset == 6 ? 3 : 2) : .cell)
    }
    
    var body: some View {
        NavigationView {
            #if os(macOS)
                Text("Sidebar")
            #endif
            
            SpanGrid(
                dataSource: data,
                keyboardNavigationOptions: .init(enabled: true, discoverabiliyEnabled: true)
            ) { _, metadata in
                GridItem(metadata: metadata)
            }
        }
    }
    
    struct ViewModel: Identifiable, SpanGridSizeInfoProvider {
        let id: Int
        let layoutSize: SpanGridLayoutSize
    }
}

// MARK: - GridItem

struct GridItem: View {
    let metadata: SpanGridCellMetadata
    
    var body: some View {
        NavigationLink(destination: Text("Detail View")) {
            Rectangle()
                .foregroundColor(metadata.isHighlighted ? .green : .red)
                .frame(minHeight: 100)
                .frame(cellMetadata: metadata)
                .focusable()
        }
        .buttonStyle(PlainButtonStyle())
    }
}
