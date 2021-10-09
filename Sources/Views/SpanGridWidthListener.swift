//
// SpanGridWidthListener.swift
//
// Copyright 2021 • James Sherlock
//

import Foundation

// MARK: - SpanGridWidthListenerViewController

protocol SpanGridWidthListenerViewController: AnyObject {
    var lastKnownSize: CGSize? { get set }
    var dynamicConfiguration: SpanGridDynamicColumnSizeStrategy.Configuration? { get }
}

extension SpanGridWidthListenerViewController {
    func getMaxGridWidth() -> CGFloat {
        if let dynamicConfiguration = dynamicConfiguration {
            return dynamicConfiguration.maximumGridWidth + dynamicConfiguration.minimumGutterRegular
        } else {
            return 0
        }
    }
    
    func processNewSize(_ size: CGSize) {
        if let lastKnownWidth = lastKnownSize?.width, size.width != lastKnownWidth {
            if lastKnownWidth <= getMaxGridWidth() || lastKnownWidth <= size.width {
                print("[SpanGridWidthListener] Triggered.")
                NotificationCenter.default.post(name: SpanGridWidthListener.notificationName, object: nil)
            } else {
                print("[SpanGridWidthListener] Out of Scope.")
            }
        } else {
            print("[SpanGridWidthListener] No Change.")
        }
    
        lastKnownSize = size
    }
}
