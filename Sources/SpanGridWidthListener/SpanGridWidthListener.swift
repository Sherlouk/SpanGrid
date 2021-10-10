//
// SpanGridWidthListener.swift
//
// Copyright 2021 • James Sherlock
//

import Logging
import SwiftUI

// MARK: - SpanGridWidthListenerViewController

protocol SpanGridWidthListenerViewController: AnyObject {
    var logger: Logger { get }
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
        defer {
            // No matter how we exit this function, lastKnownSize should be updated.
            lastKnownSize = size
        }
        
        let metadata: Logger.Metadata = [ "width": .stringConvertible(size.width) ]
        
        guard let lastKnownWidth = lastKnownSize?.width else {
            logger.trace("No last known width... first draw.", metadata: metadata)
            return
        }
        
        guard size.width != lastKnownWidth else {
            logger.trace("Width is unchanged.", metadata: metadata)
            return
        }
        
        guard lastKnownWidth <= getMaxGridWidth() || lastKnownWidth <= size.width else {
            logger.trace("Width does not require grid redraw.", metadata: metadata)
            return
        }
        
        NotificationCenter.default.post(name: SpanGridWidthListener.getPublisher().name, object: nil)
        logger.trace("Triggered notification.", metadata: metadata)
    }
}

extension SpanGridWidthListener {
    static func getPublisher() -> NotificationCenter.Publisher {
        NotificationCenter.default.publisher(for: Notification.Name(rawValue: "SpanGrid.SceneWidthChanged"))
    }
}
