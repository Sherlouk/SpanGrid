//
// SpanGridPerformanceTests.swift
//
// Copyright 2021 • James Sherlock
//

@testable import SpanGrid
import SwiftUI
import XCTest

class SpanGridPerformanceTests: XCTestCase {
    func testInitialisation() {
        let data = (0 ..< 1000).map { offset -> ViewModel in
            ViewModel(id: offset, layoutSize: .span(.random(in: 1 ... 5)))
        }
        
        let options = XCTMeasureOptions()
        options.iterationCount = 5
        
        measure(
            metrics: [
                XCTClockMetric(),
            ],
            options: options
        ) {
            // Sitting at around 0.007s
            for i in 0 ..< 10 {
                _ = SpanGrid(
                    dataSource: data,
                    columnSizeStrategy: .fixed(count: i, width: 100, spacing: 20),
                    rowSizeStrategy: .none
                ) { _, _ in
                    Rectangle()
                }
            }
        }
    }
    
    func testSpanIndexCache() {
        let data = (0 ..< 1000).map { offset -> ViewModel in
            ViewModel(id: offset, layoutSize: .span(.random(in: 1 ... 5)))
        }
        
        let grid = SpanGrid(
            dataSource: data,
            columnSizeStrategy: .fixed(count: 3, width: 100, spacing: 20),
            rowSizeStrategy: .none
        ) { _, _ in
            Rectangle()
        }
        
        let options = XCTMeasureOptions()
        options.iterationCount = 5
        
        measure(
            metrics: [
                XCTClockMetric(),
            ],
            options: options
        ) {
            // Was 0.124s, Now 0.000922s (99.3% improvement with cache)
            for i in 0 ..< 1000 {
                _ = grid.spanIndexCalculator.getSpanIndex(forItemWithOffset: i, columnCount: 3)
            }
        }
    }
    
    func testDynamicColumnStrategy() {
        let strategy = SpanGridDynamicColumnSizeStrategy()
        
        let options = XCTMeasureOptions()
        options.iterationCount = 5
        
        measure(
            metrics: [
                XCTClockMetric(),
            ],
            options: options
        ) {
            // ~0.009s
            for _ in 0 ..< 1000 {
                _ = strategy.calculate(
                    width: .random(in: 320 ... 2500),
                    traits: .init(traitsFrom: [
                        .init(preferredContentSizeCategory: Bool.random() ? .large : .accessibilityExtraExtraExtraLarge),
                    ])
                )
            }
        }
    }
    
    func testCreateSpanView() {
        let data = (0 ..< 1000).map { offset -> ViewModel in
            ViewModel(id: offset, layoutSize: .span(.random(in: 1 ... 5)))
        }
        
        let grid = SpanGrid(
            dataSource: data,
            columnSizeStrategy: .fixed(count: 3, width: 300, spacing: 20),
            rowSizeStrategy: .none
        ) { _, _ in
            Rectangle()
        }
        
        let options = XCTMeasureOptions()
        options.iterationCount = 5
        
        measure(
            metrics: [
                XCTClockMetric(),
            ],
            options: options
        ) {
            // ~0.002s
            for i in 0 ..< 1000 {
                _ = grid.createSpanView(
                    viewModel: grid.data[i],
                    columnSizeResult: .init(
                        columnCount: 3,
                        interitemSpacing: 20,
                        tileWidth: 300
                    )
                )
            }
        }
    }
    
    struct ViewModel: Identifiable, SpanGridSizeInfoProvider {
        let id: Int
        let layoutSize: SpanGridLayoutSize
    }
}
