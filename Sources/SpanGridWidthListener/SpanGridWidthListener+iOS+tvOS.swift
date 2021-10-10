//
// SpanGridWidthListener+iOS+tvOS.swift
//
// Copyright 2021 • James Sherlock
//

import Logging
import SwiftUI

#if os(iOS) || os(tvOS)
    internal struct SpanGridWidthListener: UIViewControllerRepresentable {
        internal class ViewController: UIViewController, SpanGridWidthListenerViewController {
            let logger = Logger(label: "uk.sherlo.spangrid.width-listener")
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
    
        let dynamicConfiguration: SpanGridDynamicColumnSizeStrategy.Configuration?
    
        func makeUIViewController(context _: Context) -> some UIViewController {
            ViewController(dynamicConfiguration: dynamicConfiguration)
        }
    
        func updateUIViewController(_: UIViewControllerType, context _: Context) {
            // Empty
        }
    }
#endif
