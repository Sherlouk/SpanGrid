//
// SpanGridWidthListener+iOS.swift
//
// Copyright 2021 • James Sherlock
//

import SwiftUI

#if os(iOS) || os(tvOS)
    internal struct SpanGridWidthListener: UIViewControllerRepresentable {
        internal class ViewController: UIViewController, SpanGridWidthListenerViewController {
            var lastKnownSize: CGSize?
            let dynamicConfiguration: SpanGridDynamicColumnSizeStrategy.Configuration?
        
            init(dynamicConfiguration: SpanGridDynamicColumnSizeStrategy.Configuration?) {
                self.dynamicConfiguration = dynamicConfiguration
                super.init(nibName: nil, bundle: nil)
            }
        
            @available(*, unavailable)
            required init?(coder _: NSCoder) {
                fatalError("init(coder:) has not been implemented")
            }
        
            override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
                super.viewWillTransition(to: size, with: coordinator)
                processNewSize(size)
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
#endif
