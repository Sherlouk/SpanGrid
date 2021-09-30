//
// SpanGridRowSizeStrategyTests.swift
//
// Copyright 2021 • James Sherlock
//

import SnapshotTesting
import SpanGrid
import SwiftUI
import UIKit
import XCTest

class SpanGridRowSizeStrategyTests: XCTestCase {
    func testRowSizeStrategy() {
        runTest(withStrategy: .square, name: "square")
        runTest(withStrategy: .fixed(height: 80), name: "fixed")
        runTest(withStrategy: .largest, name: "equal")
        runTest(withStrategy: .largest, columnCount: 1, name: "equal.single")
        runTest(withStrategy: .largest, columnCount: 10, name: "equal.many")
        runTest(withStrategy: .none, name: "none")
    }
    
    func runTest(
        withStrategy strategy: SpanGridRowSizeStrategy,
        columnCount: Int = 3,
        name: String,
        file: StaticString = #file,
        testName: String = #function,
        line: UInt = #line
    ) {
        let data = (0 ..< 30).map { offset -> ViewModel in
            ViewModel(id: offset, layoutSize: .cell)
        }
        
        let row = data.count / columnCount
        
        let grid = SpanGrid(
            dataSource: data,
            columnSizeStrategy: .fixed(count: columnCount, width: 100, spacing: 20),
            rowSizeStrategy: strategy,
            content: createTile
        )
        
        let wrap = UIHostingController(rootView: grid)
        wrap.view.backgroundColor = .blue.withAlphaComponent(0.1)
        
        assertSnapshot(
            matching: wrap,
            as: .image(
                size: CGSize(
                    width: 120 * CGFloat(columnCount),
                    height: 120 * CGFloat(row)
                )
            ),
            named: name,
            file: file,
            testName: testName,
            line: line
        )
    }
    
    // MARK: - Test Data
    
    let randomHeightData: [CGFloat] = [
        48, 47, 65, 42, 54, 63, 61, 66, 69, 36,
        78, 64, 49, 49, 61, 49, 59, 33, 51, 58,
        50, 40, 35, 62, 72, 69, 39, 45, 71, 38,
        35, 76, 52, 35, 51, 54, 42, 33, 56, 72,
        61, 39, 73, 35, 74, 76, 55, 60, 43, 72,
    ]
    
    func createTile(viewModel: ViewModel, metadata: SpanGridCellMetadata) -> some View {
        ZStack {
            let height: CGFloat = self.randomHeightData[viewModel.id]
            
            VStack(spacing: 0) {
                Rectangle()
                    .foregroundColor(.black.opacity(0.5))
                    .frame(height: height)
                
                Spacer(minLength: 0)
            }
            
            Text("\(Int(height))")
                .foregroundColor(.red)
                .font(.title.bold())
        }
        .frame(cellMetadata: metadata)
        .background(Color.white.opacity(0.5))
    }
    
    struct ViewModel: Identifiable, SpanGridSizeInfoProvider {
        let id: Int
        let layoutSize: SpanGridLayoutSize
    }
}
