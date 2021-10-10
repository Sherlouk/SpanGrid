//
// App.swift
//
// Copyright 2021 • James Sherlock
//

import Logging
import SwiftUI

@main
struct SpanGridApp: App {
    init() {
        LoggingSystem.bootstrap { label in
            var stdout = StreamLogHandler.standardOutput(label: label)
            stdout.logLevel = .trace
            
            return MultiplexLogHandler([
                stdout,
            ])
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
