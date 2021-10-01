//
// SpanGridWidthListener.swift
//
// Copyright 2021 • James Sherlock
//

import SwiftUI

internal struct SpanGridWidthListener: UIViewControllerRepresentable {
    internal class ViewController: UIViewController {
        var lastKnownSize: CGSize?
        let dynamicConfiguration: SpanGridDynamicColumnSizeStrategy.Configuration?
        
        init(dynamicConfiguration: SpanGridDynamicColumnSizeStrategy.Configuration?) {
            self.dynamicConfiguration = dynamicConfiguration
            super.init(nibName: nil, bundle: nil)
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        var maxGridWidth: CGFloat {
            if let dynamicConfiguration = dynamicConfiguration {
                return dynamicConfiguration.maximumGridWidth + dynamicConfiguration.minimumGutterRegular
            } else {
                return 0
            }
        }
        
        override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
            super.viewWillTransition(to: size, with: coordinator)
            
            if let lastKnownWidth = lastKnownSize?.width, size.width != lastKnownWidth {
                if lastKnownWidth <= maxGridWidth || lastKnownWidth <= size.width {
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
    
    static var notificationName = Notification.Name(rawValue: "SpanGrid.SceneWidthChanged")
    static var publisher: NotificationCenter.Publisher = NotificationCenter.default.publisher(for: notificationName)
    
    let dynamicConfiguration: SpanGridDynamicColumnSizeStrategy.Configuration?
    
    func makeUIViewController(context _: Context) -> some UIViewController {
        ViewController(dynamicConfiguration: dynamicConfiguration)
    }
    
    func updateUIViewController(_: UIViewControllerType, context _: Context) {
        // Empty
    }
}
