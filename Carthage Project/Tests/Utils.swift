//
//  Utils.swift
//  APTips
//
//  Created by Anton Plebanovich on 1/2/20.
//  Copyright © 2020 Anton Plebanovich. All rights reserved.
//

import UIKit
import Nimble
import Nimble_Snapshots
import Quick
@testable import APTips_Example

// ******************************* MARK: - UI Tests Window

let u = Utils.self

enum Utils {
    
    /// Default Window size to use for UI checking unit tests
    static let defaultWindowRect = CGRect(x: 0, y: 0, width: 375, height: 667)
    
    /// Shows VC in a default window.
    /// This method must be used for UI unit tests.
    static func showInWindow(vc: UIViewController) {
        let window = UIWindow(frame: defaultWindowRect)
        AppDelegate.shared.window = window
        window.rootViewController = vc
        window.makeKeyAndVisible()
        window.layoutIfNeeded()
    }
    
    /// Shows view with inner height in a default window.
    /// This method must be used for UI unit tests.
    /// - parameter innerHeightView: View that has specific inner height that shouldn't be broken.
    static func showInWindow(innerHeightView: UIView) {
        let vc = UIViewController()
        vc.view.addSubview(innerHeightView)
        innerHeightView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            innerHeightView.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor),
            innerHeightView.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor),
            innerHeightView.topAnchor.constraint(equalTo: vc.view.topAnchor)
        ])
        showInWindow(vc: vc)
    }
    
    /// Shows view with selected size.
    /// This method must be used for UI unit tests.
    /// - parameter innerView: View that should be shown with selected size.
    /// - parameter size: View size for testing.
    static func showInWindow(innerView: UIView, size: CGSize) {
        let vc = UIViewController()
        vc.view.addSubview(innerView)
        innerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            innerView.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor),
            innerView.topAnchor.constraint(equalTo: vc.view.topAnchor),
            innerView.heightAnchor.constraint(equalToConstant: size.height),
            innerView.widthAnchor.constraint(equalToConstant: size.width)
        ])
        showInWindow(vc: vc)
    }
    
    /// Shows view with View frame size.
    /// This method must be used for UI unit tests.
    /// - parameter innerView: View that should be shown with selected size.
    static func showInWindowWithViewFrameSize(innerView: UIView) {
        showInWindow(innerView: innerView, size: innerView.frame.size)
    }
    
    /// Shows resizeable view in a default window.
    /// This method must be used for UI unit tests.
    /// - parameter resizeableView: View that may be resized to any size and properly layout for that.
    static func showInWindow(resizeableView: UIView) {
        let vc = UIViewController()
        vc.view = resizeableView
        showInWindow(vc: vc)
    }
}

// ******************************* MARK: - Snapshots Recording

/// Set to true to update snapshots
private let recordSnapshots = false

private let clearFailureDiffsOnce: Void = {
    guard let failureDiffsURLString = ProcessInfo.processInfo.environment["IMAGE_DIFF_DIR"]?.asFileURL else { return }
    try? FileManager.default.removeItem(at: failureDiffsURLString)
}()

func haveValidSnapshot(named name: String? = nil, identifier: String? = nil, usesDrawRect: Bool = false, tolerance: CGFloat? = 0.005) -> Predicate<Snapshotable> {
    _ = clearFailureDiffsOnce
    if recordSnapshots {
        return recordSnapshot(named: name, identifier: identifier, usesDrawRect: usesDrawRect)
    } else {
        return Nimble_Snapshots.haveValidSnapshot(named: name, identifier: identifier, usesDrawRect: usesDrawRect, tolerance: tolerance)
    }
}

/// Checks that view has proper layout
func shouldHaveProperLayout(_ view: @escaping @autoclosure () -> UIView, file: FileString = #file, line: UInt = #line) {
    it("should have proper layout") {
        expect(view(), file: file, line: line).to(haveValidSnapshot())
    }
}
