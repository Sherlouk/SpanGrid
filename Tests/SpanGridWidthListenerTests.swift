//
//  SpanGridWidthListenerTests.swift
//  SpanGridTests
//
//  Created by James Sherlock on 28/09/2021.
//

@testable import SpanGrid
import XCTest

class SpanGridWidthListenerTests: XCTestCase {
    func testWidthListener_sendsNotificationWhenWidthChanges() {
        let mockCoordinator = MockUIViewControllerTransitionCoordinator()
        
        let viewController = SpanGridWidthListener.ViewController()
        viewController.lastKnownSize = CGSize(width: 100, height: 120)
        
        let exp = expectation(forNotification: SpanGridWidthListener.notificationName, object: nil, handler: nil)
        exp.assertForOverFulfill = true
        exp.expectedFulfillmentCount = 1
        
        viewController.viewWillTransition(to: CGSize(width: 110, height: 120), with: mockCoordinator)
        
        waitForExpectations(timeout: 0.1, handler: nil)
    }
    
    func testWidthListener_noNotificationIfWidthExceedsMaximum() {
        let mockCoordinator = MockUIViewControllerTransitionCoordinator()
        
        let viewController = SpanGridWidthListener.ViewController()
        viewController.lastKnownSize = CGSize(width: 2000, height: 120)
        
        let exp = expectation(forNotification: SpanGridWidthListener.notificationName, object: nil, handler: nil)
        exp.assertForOverFulfill = true
        exp.expectedFulfillmentCount = 2
        
        // Notification (New Value Below Minimum)
        viewController.viewWillTransition(to: CGSize(width: 500, height: 120), with: mockCoordinator)
        
        // Notification (Last Known Value Below Minimum)
        viewController.viewWillTransition(to: CGSize(width: 2010, height: 120), with: mockCoordinator)
        
        // No Notification (Previous and Current Value Above Minimum)
        viewController.viewWillTransition(to: CGSize(width: 2020, height: 120), with: mockCoordinator)
        
        waitForExpectations(timeout: 0.5, handler: nil)
    }
    
    func testWidthListener_noNotificationIfOnlyHeightChanges() {
        let mockCoordinator = MockUIViewControllerTransitionCoordinator()
        
        let viewController = SpanGridWidthListener.ViewController()
        viewController.lastKnownSize = CGSize(width: 100, height: 120)
        
        let exp = expectation(forNotification: SpanGridWidthListener.notificationName, object: nil, handler: nil)
        exp.isInverted = true
        
        viewController.viewWillTransition(to: CGSize(width: 100, height: 130), with: mockCoordinator)
        
        waitForExpectations(timeout: 0.1, handler: nil)
    }
    
    func testWidthListener_lastKnownSizeIsUpdated() {
        let mockCoordinator = MockUIViewControllerTransitionCoordinator()
        let viewController = SpanGridWidthListener.ViewController()
        
        // Start with nothing
        XCTAssertNil(viewController.lastKnownSize)
        
        // Call the function
        viewController.viewWillTransition(to: CGSize(width: 100, height: 120), with: mockCoordinator)
        
        // Check that the last known size is updated
        XCTAssertEqual(viewController.lastKnownSize?.width, 100)
        XCTAssertEqual(viewController.lastKnownSize?.height, 120)
    }
    
    // MARK: - Mock
    
    class MockUIViewControllerTransitionCoordinator: NSObject, UIViewControllerTransitionCoordinator {
        var isAnimated: Bool = true
        var presentationStyle: UIModalPresentationStyle = .none
        var initiallyInteractive: Bool = true
        var isInterruptible: Bool = true
        var isInteractive: Bool = true
        var isCancelled: Bool = true
        var transitionDuration: TimeInterval = 0
        var percentComplete: CGFloat = 0
        var completionVelocity: CGFloat = 0
        var completionCurve: UIView.AnimationCurve = .linear
        var containerView: UIView = .init()
        var targetTransform: CGAffineTransform = .identity
        
        func viewController(forKey _: UITransitionContextViewControllerKey) -> UIViewController? {
            nil
        }
        
        func view(forKey _: UITransitionContextViewKey) -> UIView? {
            nil
        }
        
        func animate(alongsideTransition _: ((UIViewControllerTransitionCoordinatorContext) -> Void)?, completion _: ((UIViewControllerTransitionCoordinatorContext) -> Void)? = nil) -> Bool {
            true
        }
        
        func animateAlongsideTransition(in _: UIView?, animation _: ((UIViewControllerTransitionCoordinatorContext) -> Void)?, completion _: ((UIViewControllerTransitionCoordinatorContext) -> Void)? = nil) -> Bool {
            true
        }
        
        func notifyWhenInteractionEnds(_: @escaping (UIViewControllerTransitionCoordinatorContext) -> Void) {}
        
        func notifyWhenInteractionChanges(_: @escaping (UIViewControllerTransitionCoordinatorContext) -> Void) {}
    }
}
