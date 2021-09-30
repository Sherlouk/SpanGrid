//
//  SpanGridExampleImageGenerator.swift
//  SpanGridTests
//
//  Created by James Sherlock on 30/09/2021.
//

import SnapshotTesting
import SpanGrid
import SwiftUI
import UIKit
import XCTest

class SpanGridExampleImageGenerator: XCTestCase {
    func testREADME() {
        // Do I love it? Absolutely not.
        // Will it do for now? Absolutely.
        
        let data: [ViewModel] = [
            .init(title: "Welcome to SpanGrid!", layoutSize: .row),
            .init(title: "The latest", layoutSize: .cell),
            .init(title: "in SwiftUI", layoutSize: .cell),
            .init(title: "grid goodness", layoutSize: .cell),
        ]
        
        let grid = SpanGrid(dataSource: data) { viewModel, metadata in
            
            ZStack {
                Color.blue.opacity(0.2)
                
                Text(viewModel.title)
                    .foregroundColor(.primary)
                    .font(.title)
                    .padding()
            }
            .frame(cellMetadata: metadata)
            
        }.padding()
        
        assertSnapshot(
            matching: grid,
            as: .image(
                layout: .fixed(width: 850, height: 200),
                traits: .init(userInterfaceStyle: .light)
            ),
            named: "light", record: true
        )
        
        assertSnapshot(
            matching: grid,
            as: .image(
                layout: .fixed(width: 850, height: 200),
                traits: .init(userInterfaceStyle: .dark)
            ),
            named: "dark", record: true
        )
    }
    
    struct ViewModel: Identifiable, SpanGridSizeInfoProvider {
        let title: String
        let layoutSize: SpanGridLayoutSize
        
        var id: String {
            title
        }
    }
}
