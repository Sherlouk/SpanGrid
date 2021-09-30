//
//  SpanGridSpanTests.swift
//  SpanGridTests
//
//  Created by James Sherlock on 28/09/2021.
//

import XCTest
import UIKit
import SwiftUI
import SnapshotTesting
@testable import SpanGrid

class SpanGridSpanTests: XCTestCase {
    
    func testColumnSpan() {
        runTest(
            withSizeMapping: [
                [ 0 ]: .row,
            ],
            name: "basic"
        )
        
        runTest(
            withSizeMapping: [
                // A span of 100 is far too big for the grid.
                [ 0 ]: .span(100),
            ],
            name: "excessive-row"
        )
        
        runTest(
            withSizeMapping: [
                [ 2 ]: .span(2),
            ],
            name: "wrap"
        )
        
        runTest(
            withSizeMapping: [
                [ 0, 6 ]: .row,
                [ 10, 13, 16 ]: .span(2),
                [ 19 ]: .span(10)
            ],
            columnCount: 4,
            name: "complex-4"
        )
        
        runTest(
            withSizeMapping: [
                [ 0, 6 ]: .row,
                [ 10, 13, 16 ]: .span(2),
                [ 19 ]: .span(10)
            ],
            columnCount: 3,
            name: "complex-3"
        )
    }
    
    func runTest(
        withSizeMapping mapping: [[Int]: SpanGridLayoutSize],
        columnCount: Int = 3,
        name: String,
        file: StaticString = #file,
        testName: String = #function,
        line: UInt = #line
    ) {
        let data = (0..<30).map { offset -> ViewModel in
            if let value = mapping.first(where: { $0.key.contains(offset) })?.value {
                return ViewModel(id: offset, layoutSize: value)
            }
            
            return ViewModel(id: offset, layoutSize: .cell)
        }
        
        let grid = SpanGrid(
            dataSource: data,
            columnSizeStrategy: .fixed(count: columnCount, width: 100, spacing: 20)
        ) { viewModel, metadata in
            
            ZStack {
                Rectangle()
                    .frame(width: metadata.size.width, height: metadata.size.height ?? 50)
                    .foregroundColor(viewModel.layoutSize.getColor(columnCount: columnCount))
                
                Text("\(viewModel.layoutSize.spanSize(columnCount: columnCount))")
            }
            
        }
        
        assertSnapshot(
            matching: grid,
            as: .image(layout: .fixed(width: 120 * CGFloat(columnCount), height: 1200)),
            named: name,
            file: file,
            testName: testName,
            line: line
        )
    }
    
    struct ViewModel: Identifiable, SpanGridSizeInfoProvider {
        let id: Int
        let layoutSize: SpanGridLayoutSize
    }
    
}

extension SpanGridLayoutSize {
    
    fileprivate func getColor(columnCount: Int) -> Color {
        let colors: [Color] = [
            .red, .green, .blue,
            .yellow, .black, .orange,
            .gray, .pink
        ]
        
        return colors[spanSize(columnCount: columnCount) - 1]
    }
    
}
