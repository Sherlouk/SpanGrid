//
// SpanGridDetermineRowHeight.swift
//
// Copyright 2021 • James Sherlock
//

import SwiftUI

// MARK: - SpanGridRowPreferenceKey

internal struct SpanGridRowPreferenceKey: PreferenceKey {
    static var defaultValue: [Int: CGFloat] = [:]
    
    static func reduce(value: inout [Int: CGFloat], nextValue: () -> [Int: CGFloat]) {
        nextValue().forEach { row, newValue in
            value[row] = max(value[row] ?? 0, newValue)
        }
    }
}

// MARK: - SpanGridDetermineRowHeight

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
