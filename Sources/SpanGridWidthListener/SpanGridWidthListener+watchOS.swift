//
// SpanGridWidthListener+watchOS.swift
//
// Copyright 2021 • James Sherlock
//

import SwiftUI

#if os(watchOS)
    internal struct SpanGridWidthListener: View {
        let dynamicConfiguration: SpanGridDynamicColumnSizeStrategy.Configuration?
        
        var body: some View {
            EmptyView()
        }
    }
#endif
