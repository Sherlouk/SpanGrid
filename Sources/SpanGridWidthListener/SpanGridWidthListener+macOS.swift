//
// SpanGridWidthListener+macOS.swift
//
// Copyright 2021 • James Sherlock
//

import Logging
import SwiftUI

#if os(OSX)
    internal struct SpanGridWidthListener: NSViewControllerRepresentable {
        internal class ViewController: NSViewController, SpanGridWidthListenerViewController {
            let logger = Logger(label: "uk.sherlo.spangrid.width-listener")
            var lastKnownSize: CGSize?
            let dynamicConfiguration: SpanGridDynamicColumnSizeStrategy.Configuration?
        
            override func loadView() {
                view = NSView()
            }
        
            init(dynamicConfiguration: SpanGridDynamicColumnSizeStrategy.Configuration?) {
                self.dynamicConfiguration = dynamicConfiguration
                super.init(nibName: nil, bundle: nil)
            }
        
            @available(*, unavailable)
            required init?(coder _: NSCoder) {
                fatalError("init(coder:) has not been implemented")
            }
        
            override func viewWillTransition(to newSize: NSSize) {
                super.viewWillTransition(to: newSize)
                processNewSize(newSize)
            }
        }

        let dynamicConfiguration: SpanGridDynamicColumnSizeStrategy.Configuration?
    
        func makeNSViewController(context _: Context) -> some NSViewController {
            ViewController(dynamicConfiguration: dynamicConfiguration)
        }
    
        func updateNSViewController(_: NSViewControllerType, context _: Context) {
            // Empty
        }
    }
#endif
