//
// SpanGridWidthListener+watchOS.swift
//
// Copyright 2021 • James Sherlock
//

import SwiftUI

#if os(watchOS)
    internal struct SpanGridWidthListener: View {
        static var notificationName = Notification.Name(rawValue: "SpanGrid.SceneWidthChanged")
        static var publisher: NotificationCenter.Publisher = NotificationCenter.default.publisher(for: notificationName)
        
        let dynamicConfiguration: SpanGridDynamicColumnSizeStrategy.Configuration?
        
        var body: some View {
            EmptyView()
        }
    }
#endif
