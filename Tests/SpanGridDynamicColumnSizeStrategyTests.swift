//
//  SpanGridDynamicColumnSizeStrategyTests.swift
//  SpanGridTests
//
//  Created by James Sherlock on 28/09/2021.
//

import XCTest
import UIKit
import SwiftUI
import SnapshotTesting
import SpanGrid

class SpanGridDynamicColumnSizeStrategyTests: XCTestCase {
    
    func testDynamicStrategy_snapshots() {
        // https://www.ios-resolution.com/
        
        runTest(width: 320) // iPod Touch • iPhone SE (1st Gen)
        runTest(width: 375) // iPhone 13 Mini
        runTest(width: 390) // iPhone 13
        runTest(width: 428) // iPhone 13 Pro Max
        
        runTest(width: 812) // iPhone 13 Mini (Landscape)
        runTest(width: 844) // iPhone 13 (Landscape)
        runTest(width: 926) // iPhone 13 Pro Max (Landscape)
        
        runTest(width: 414) // Common Phone Size
        
        runTest(width: 744) // iPad Mini 6th Gen
        runTest(width: 768) // Common Tablet Size
        runTest(width: 834) // iPad Pro 11"
        runTest(width: 1024) // iPad Pro 12.9"
        
        runTest(width: 1133) // iPad Mini 6th Gen (Landscape)
        runTest(width: 1194) // iPad Pro 11" (Landscape)
        runTest(width: 1366) // iPad Pro 12.9" (Landscape)
        
        runTest(width: 639) // iPad Pro 12.9" (Portrait • 1/3 Split View)
        runTest(width: 981) // iPad Pro 12.9" (Landscape • 1/3 Split View)
        runTest(width: 678) // iPad Pro 12.9" (Landscape • 1/2 Split View)
        
        runTest(
            width: 1366,
            traits: .init(preferredContentSizeCategory: .accessibilityLarge),
            name: "traits.accessibility-large"
        )
    }
    
    func runTest(
        width: CGFloat,
        traits: UITraitCollection = .init(),
        name: String? = nil,
        file: StaticString = #file,
        testName: String = #function,
        line: UInt = #line
    ) {
        let data = (0..<13).map { offset -> ViewModel in
            return ViewModel(id: offset, layoutSize: offset == 0 ? .row : .cell)
        }
        
        let grid = SpanGrid(
            dataSource: data,
            columnSizeStrategy: .dynamic
        ) { viewModel, metadata in
            
            Rectangle()
                .frame(width: metadata.size.width, height: 25)
                .foregroundColor(.red)
            
        }
        
        assertSnapshot(
            matching: grid,
            as: .image(
                layout: .fixed(width: width, height: 1000),
                traits: traits
            ),
            named: name ?? "\(Int(width))",
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
