//
//  SpanGridDetermineRowHeight.swift
//  SpanGrid
//
//  Created by James Sherlock on 29/09/2021.
//

import SwiftUI

internal struct SpanGridRowPreferenceKey: PreferenceKey {
    
    static var defaultValue: [Int: CGFloat] = [:]
    
    static func reduce(value: inout [Int: CGFloat], nextValue: () -> [Int: CGFloat]) {
        nextValue().forEach { row, newValue in
            value[row] = max(value[row] ?? 0, newValue)
        }
    }
    
}

internal struct SpanGridDetermineRowHeight: View {
    typealias Key = SpanGridRowPreferenceKey
    
    let rowOffset: Int
    
    var body: some View {
        GeometryReader { proxy in
            Color.clear.anchorPreference(key: Key.self, value: .bounds) { anchor in
                [ rowOffset: proxy[anchor].size.height ]
            }
        }
    }
}
