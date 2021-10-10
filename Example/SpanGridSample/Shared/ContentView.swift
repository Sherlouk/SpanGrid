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
                rowSizeStrategy: .largest,
                keyboardNavigationOptions: .init(enabled: true, discoverabiliyEnabled: true)
            ) { viewModel, metadata in
                GridItem(viewModel: viewModel, metadata: metadata)
            }
        }
        #if os(iOS)
            .navigationViewStyle(.stack)
        #endif
    }
    
    struct ViewModel: Identifiable, SpanGridSizeInfoProvider {
        let id: Int
        let layoutSize: SpanGridLayoutSize
        let randomHeight: CGFloat
        
        init(id: Int, layoutSize: SpanGridLayoutSize) {
            self.id = id
            self.layoutSize = layoutSize
            randomHeight = .random(in: 50 ... 150)
        }
    }
}

// MARK: - GridItem

struct GridItem: View {
    let viewModel: ContentView.ViewModel
    let metadata: SpanGridCellMetadata
    
    var body: some View {
        NavigationLink(destination: Text("Detail View")) {
            Rectangle()
                .frame(minHeight: viewModel.randomHeight)
                .frame(cellMetadata: metadata)
                .foregroundColor(metadata.isHighlighted ? .green : .red)
                .overlay(Text("\(Int(viewModel.randomHeight))"))
            #if os(tvOS) || os(watchOS)
                .focusable()
            #endif
        }
        .buttonStyle(PlainButtonStyle())
    }
}
