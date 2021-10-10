//
// SpanGridKeyboardNavigationShortcuts.swift
//
// Copyright 2021 • James Sherlock
//

import SwiftUI

@available(iOS 14, *)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
struct SpanGridKeyboardNavigationShortcuts: View {
    enum Direction: String, CaseIterable {
        case up
        case down
        case left
        case right
        
        var shortcut: KeyEquivalent {
            // There appears to be a bug on iPadOS where arrow keys are not valid inputs for keyboard shortcuts.
            // As such, we currently use WASD.
            //
            // Sources:
            // - https://www.reddit.com/r/SwiftUI/comments/lj1pj5/arrow_keys_in_swiftui_does_not_seem_to_work_on/
            // - https://stackoverflow.com/questions/65584926/swiftui-keyboardshortcut-with-arrow-keys
            // - My own testing (both Simulator and Physical Device)
            //
            // Feedback: FB9675753 - Arrow keys do not work as keyboardShortcut on iPadOS
            
            switch self {
            case .up: return "w"
            case .left: return "a"
            case .down: return "s"
            case .right: return "d"
            }
        }
        
        func title(options: SpanGridKeyboardNavigationOptions) -> LocalizedStringKey {
            switch self {
            case .up: return options.localization.navigatePreviousRow
            case .left: return options.localization.navigatePreviousItem
            case .down: return options.localization.navigateNextRow
            case .right: return options.localization.navigateNextItem
            }
        }
    }
    
    let options: SpanGridKeyboardNavigationOptions
    let callback: (Direction) -> Void
    
    var body: some View {
        VStack {
            if options.enabled {
                createButton(direction: .up)
                createButton(direction: .left)
                createButton(direction: .down)
                createButton(direction: .right)
            }
        }.hidden()
    }
    
    @ViewBuilder func createButton(direction: Direction) -> some View {
        // There is not currently a fantastic way to disable discoverability, but I have discovered that adding a
        // shortcut to an EmptyView (or any non-text view) will result in no value being added to discoverability
        // on iPadOS.
        //
        // Feedback: FB9675764 - Add iPadOS discoverability title override to keyboardShortcut
        
        if options.discoverabilityEnabled {
            Button(direction.title(options: options)) { callback(direction) }
                .keyboardShortcut(direction.shortcut, modifiers: [])
        } else {
            Button(
                action: { callback(direction) },
                label: { EmptyView() }
            )
            .keyboardShortcut(direction.shortcut, modifiers: [])
        }
    }
}
