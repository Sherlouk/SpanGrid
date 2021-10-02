//
// SpanGridKeyboardNavigationTests.swift
//
// Copyright 2021 • James Sherlock
//

import SnapshotTesting
@testable import SpanGrid
import SwiftUI
import UIKit
import XCTest

class SpanGridKeyboardNavigationTests: XCTestCase {
    func testInitialControls() {
        do { // On startup, currentItem is nil
            let coordinator = createKeyboardCoordinator()
            XCTAssertNil(coordinator.currentItem)
        }
        
        do { // On directional event, currentItem goes to 0
            SpanGridKeyboardNavigationShortcuts.Direction.allCases.forEach { direction in
                let coordinator = createKeyboardCoordinator()
                coordinator.processDirection(3)(direction)
                XCTAssertEqual(coordinator.currentItem, 0)
            }
        }
    }
    
    func testNavigationStraightDown() {
        let coordinator = createKeyboardCoordinator()
        let process = coordinator.processDirection(3)
        
        process(.down) // first row, first item
        XCTAssertEqual(coordinator.currentItem, 0)
        
        process(.down) // second row, first item
        XCTAssertEqual(coordinator.currentItem, 3)
        
        process(.down) // third row, first item (column span row)
        XCTAssertEqual(coordinator.currentItem, 6)
        
        process(.down) // fourth row, first item
        XCTAssertEqual(coordinator.currentItem, 7)
        
        process(.down) // fifth row, first item
        XCTAssertEqual(coordinator.currentItem, 10)
        
        process(.down) // fifth row, first item (clamped)
        XCTAssertEqual(coordinator.currentItem, 10)
    }
    
    func testNavigationAroundRowSpan() {
        let coordinator = createKeyboardCoordinator()
        let process = coordinator.processDirection(3)
        
        process(.down)
        process(.down)
        process(.down)
        XCTAssertEqual(coordinator.currentItem, 6)
        
        process(.left)
        XCTAssertEqual(coordinator.currentItem, 5)
        
        process(.right)
        XCTAssertEqual(coordinator.currentItem, 6)
        
        process(.right)
        XCTAssertEqual(coordinator.currentItem, 7)
    }
    
    func testNavigatingThroughRowSpanMaintainsColumn() {
        do { // middle column
            let coordinator = createKeyboardCoordinator()
            let process = coordinator.processDirection(3)
            
            process(.down)
            process(.down)
            process(.right) // move into second column in second row
            process(.down) // full row item (third row)
            XCTAssertEqual(coordinator.currentItem, 6)
            
            process(.down) // fourth row, still second column
            XCTAssertEqual(coordinator.currentItem, 8)
        }
        
        do { // right column
            let coordinator = createKeyboardCoordinator()
            let process = coordinator.processDirection(3)
            
            process(.down)
            process(.down)
            process(.right) // move into second column in second row
            process(.right) // move into third column in second row
            process(.down) // full row item (third row)
            XCTAssertEqual(coordinator.currentItem, 6)
            
            process(.down) // fourth row, still third olumn
            XCTAssertEqual(coordinator.currentItem, 9)
        }
    }
    
    func testNavigatingThroughPartialColumnSpan() {
        do { // left column
            let coordinator = createComplexKeyboardCoordinator()
            let process = coordinator.processDirection(3)
            
            process(.down)
            process(.down)
            process(.down)
            XCTAssertEqual(coordinator.currentItem, 6)
            process(.down)
            XCTAssertEqual(coordinator.currentItem, 8)
        }
        
        do { // middle column
            let coordinator = createComplexKeyboardCoordinator()
            let process = coordinator.processDirection(3)
            
            process(.down)
            process(.down)
            process(.right)
            process(.down)
            XCTAssertEqual(coordinator.currentItem, 6)
            process(.down)
            XCTAssertEqual(coordinator.currentItem, 9)
        }
        
        do { // right column
            let coordinator = createComplexKeyboardCoordinator()
            let process = coordinator.processDirection(3)
            
            process(.down)
            process(.down)
            process(.right)
            process(.right)
            process(.down)
            XCTAssertEqual(coordinator.currentItem, 7)
            process(.down)
            XCTAssertEqual(coordinator.currentItem, 10)
        }
    }
    
    func testNavigatingThroughWhitespaceSingle() {
        do { // vertical navigation
            let coordinator = createComplexKeyboardCoordinator()
            let process = coordinator.processDirection(3)
            
            process(.down)
            process(.down)
            process(.down)
            process(.down)
            process(.down) // fifth row
            XCTAssertEqual(coordinator.currentItem, 11)
            process(.right)
            process(.right) // third column
            XCTAssertEqual(coordinator.currentItem, 13)
            process(.down) // through the whitespace
            XCTAssertEqual(coordinator.currentItem, 17)
            process(.up) // back up through the whitespace
            XCTAssertEqual(coordinator.currentItem, 13)
        }
        
        do { // horizontal navigation
            let coordinator = createComplexKeyboardCoordinator()
            let process = coordinator.processDirection(3)
            
            process(.down)
            process(.down)
            process(.down)
            process(.down)
            process(.down)
            process(.down) // sixth row
            XCTAssertEqual(coordinator.currentItem, 14)
            process(.right) // second column
            XCTAssertEqual(coordinator.currentItem, 15)
            process(.right) // into whitespace (expect to wrap)
            XCTAssertEqual(coordinator.currentItem, 16)
            process(.right) // to next item (col span 2)
            XCTAssertEqual(coordinator.currentItem, 17)
            process(.left) // back to col span 2
            XCTAssertEqual(coordinator.currentItem, 16)
            process(.left) // back to other side of whitespace
            XCTAssertEqual(coordinator.currentItem, 15)
        }
    }
    
    func testOutOfBounds() {
        let coordinator = createKeyboardCoordinator()
        let process = coordinator.processDirection(3)
        
        process(.left)
        XCTAssertEqual(coordinator.currentItem, 0) // default
        
        process(.left)
        XCTAssertEqual(coordinator.currentItem, 0) // out of bounds left
        
        process(.up)
        XCTAssertEqual(coordinator.currentItem, 0) // out of bounds up
        
        process(.right)
        XCTAssertEqual(coordinator.currentItem, 1)
        process(.up)
        XCTAssertEqual(coordinator.currentItem, 1) // out of bounds up
        
        process(.down)
        process(.down)
        process(.down)
        XCTAssertEqual(coordinator.currentItem, 8)
        process(.down)
        XCTAssertEqual(coordinator.currentItem, 11)
        process(.down)
        XCTAssertEqual(coordinator.currentItem, 11) // out of bounds down
        process(.right)
        process(.down)
        XCTAssertEqual(coordinator.currentItem, 12) // out of bounds down
        process(.right)
        XCTAssertEqual(coordinator.currentItem, 12) // out of bounds right
    }
    
    func testMonkeyNavigationAndPerformance() {
        let options = XCTMeasureOptions()
        options.iterationCount = 2
        options.invocationOptions = [ .manuallyStart, .manuallyStop ]
        
        measure(
            metrics: [
                XCTClockMetric(),
            ],
            options: options
        ) {
            // 🚨 Was 2.2s, now 3.154s after keyboard navigation work (isInvalidCell)
            let coordinator = createKeyboardCoordinator(size: 100)
            coordinator.grid?.spanIndexCalculator.precalculateSpanIndex(columnCount: 3)
            let process = coordinator.processDirection(3)
            
            startMeasuring()
            
            for _ in 0 ..< 5000 {
                process(SpanGridKeyboardNavigationShortcuts.Direction.allCases.randomElement()!)
            }
            
            stopMeasuring()
        }
    }
    
    func createKeyboardCoordinator(size: Int = 13) -> SpanGridKeyboardNavigation<Rectangle, ViewModel> {
        let data = (0 ..< size).map { offset -> ViewModel in
            ViewModel(id: offset, layoutSize: offset == 6 ? .row : .cell)
        }
        
        return SpanGrid(
            dataSource: data,
            columnSizeStrategy: .fixed(count: 3, width: 100, spacing: 0),
            keyboardNavigationEnabled: true
        ) { _, _ in
            Rectangle()
        }.keyboardNavigationCoordinator
    }
    
    func createComplexKeyboardCoordinator() -> SpanGridKeyboardNavigation<Rectangle, ViewModel> {
        let data = (0 ..< 21).map { offset -> ViewModel in
            ViewModel(id: offset, layoutSize: offset == 6 || offset == 16 ? .span(2) : .cell)
        }
        
        return SpanGrid(
            dataSource: data,
            columnSizeStrategy: .fixed(count: 3, width: 100, spacing: 0),
            keyboardNavigationEnabled: true
        ) { _, _ in
            Rectangle()
        }.keyboardNavigationCoordinator
    }
    
    struct ViewModel: Identifiable, SpanGridSizeInfoProvider {
        let id: Int
        let layoutSize: SpanGridLayoutSize
    }
}
