//
// SpanGridDynamicColumnSizeStrategyTests.swift
//
// Copyright 2021 • James Sherlock
//

import SnapshotTesting
import SpanGrid
import SwiftUI
import UIKit
import XCTest

class SpanGridDynamicColumnSizeStrategyTests: XCTestCase {
    func testDynamicStrategy_snapshots() {
        // https://www.ios-resolution.com/
        
        runTest(device: .iPhoneSe(.portrait), name: "iPhone SE (Portrait)")
        runTest(device: .iPhoneSe(.landscape), name: "iPhone SE (Landscape)")
        
        runTest(device: .iPhone8(.portrait), name: "iPhone 8 (Portrait)")
        runTest(device: .iPhone8(.landscape), name: "iPhone 8 (Landscape)")
        
        runTest(device: .iPhoneXsMax(.portrait), name: "iPhone XS Max (Portrait)")
        runTest(device: .iPhoneXsMax(.landscape), name: "iPhone XS Max (Landscape)")
        
        runTest(device: .iPadMini(.portrait), name: "iPad Mini (Portrait)")
        runTest(device: .iPadMini(.portrait(splitView: .twoThirds)), name: "iPad Mini (Portrait • Two Thirds)")
        runTest(device: .iPadMini(.landscape(splitView: .oneHalf)), name: "iPad Mini (Landscape • One Half)")
        
        runTest(device: .iPadPro11(.portrait), name: "iPad Pro 11\" (Portrait)")
        runTest(device: .iPadPro11(.landscape), name: "iPad Pro 11\" (Landscape)")
        runTest(device: .iPadPro11(.portrait(splitView: .twoThirds)), name: "iPad Pro 11\" (Portrait • Two Thirds)")
        runTest(device: .iPadPro11(.landscape(splitView: .oneHalf)), name: "iPad Pro 11\" (Landscape • One Half)")
        
        runTest(device: .iPadPro12_9(.portrait), name: "iPad Pro 12.9\" (Portrait) or iPad Mini (Landscape)")
        runTest(device: .iPadPro12_9(.landscape), name: "iPad Pro 12.9\" (Landscape)")
        runTest(device: .iPadPro12_9(.portrait(splitView: .twoThirds)), name: "iPad Pro 12.9\" (Portrait • Two Thirds)")
        runTest(device: .iPadPro12_9(.landscape(splitView: .oneHalf)), name: "iPad Pro 12.9\" (Landscape • One Half)")
        
        runTest(device: .iPhoneSe, name: "iPhone SE • Accessibility",
                traits: .init(preferredContentSizeCategory: .accessibilityLarge))
        runTest(device: .iPhoneXsMax, name: "iPhone XS Max • Accessibility",
                traits: .init(preferredContentSizeCategory: .accessibilityLarge))
        runTest(device: .iPadMini, name: "iPad Pro 12.9\" • Accessibility",
                traits: .init(preferredContentSizeCategory: .accessibilityLarge))
        runTest(device: .iPadPro12_9(.landscape), name: "iPad Pro 12.9\" • Accessibility",
                traits: .init(preferredContentSizeCategory: .accessibilityLarge))
    }
    
    func runTest(
        device: ViewImageConfig,
        name: String,
        traits: UITraitCollection = .init(),
        file: StaticString = #file,
        testName: String = #function,
        line: UInt = #line
    ) {
        let width: CGFloat = device.size?.width ?? 0
        
        let data = (0 ..< 7).map { offset -> ViewModel in
            ViewModel(id: offset, layoutSize: offset == 0 ? .row : .cell)
        }
        
        let grid = SpanGrid(
            dataSource: data,
            columnSizeStrategy: .dynamic
        ) { viewModel, metadata in
            
            ZStack {
                VStack {
                    if viewModel.id == 0 {
                        Text(name)
                            .font(.system(size: 14, weight: .bold))
                    }
                    
                    Text("\(Int(metadata.size.width))")
                        .font(.system(size: 14))
                }
            }
            .frame(width: metadata.size.width, height: viewModel.id == 0 ? 100 : 24)
            .background(Color.blue.opacity(0.2))
        }
        
        let combinedTraits = UITraitCollection(traitsFrom: [ device.traits, traits ])
        
        let name: String = [
            "\(Int(width))",
            traits.horizontalSizeClass == .compact ? "compact" : nil,
            traits.preferredContentSizeCategory == .accessibilityLarge ? "accessibility" : nil,
        ]
        .compactMap { $0 }
        .joined(separator: ".")
        
        assertSnapshot(
            matching: grid,
            as: .image(
                layout: .fixed(width: width, height: 1000),
                traits: combinedTraits
            ),
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
