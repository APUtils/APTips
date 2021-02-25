//
//  UIView+Utils.swift
//  APTips
//
//  Created by Anton Plebanovich on 12/28/19.
//  Copyright © 2019 Anton Plebanovich. All rights reserved.
//

import Foundation

extension UIView {
    
    /// Return first view controller that contains that view using responders chain.
    var _firstViewController: UIViewController? {
        var nextResponder: UIResponder? = self
        while nextResponder != nil {
            nextResponder = nextResponder?.next
            
            if let viewController = nextResponder as? UIViewController {
                return viewController
            }
        }
        
        return nil
    }
    
    /// Root view that contains whole view hierarchy.
    var _rootView: UIView {
        var rootView: UIView = self
        while let nextView = rootView.superview {
            rootView = nextView
        }
        
        return rootView
    }
    
    /// Return all reusable views that contains that view using view hierarchy.
    var _allReusableViews: [UIView] {
        var allReuseViews: [UIView] = []
        var nextView: UIView? = self
        while nextView != nil {
            if let nextView = nextView, TipsManager.shared.isReusableView(nextView) {
                allReuseViews.append(nextView)
            }
            
            nextView = nextView?.superview
        }
        
        return allReuseViews
    }
    
    /// Consider view with alpha <0.01 as invisible because it stops receiving touches at this level:
    /// "This method ignores view objects that are hidden, that have disabled user interactions, or have an alpha level less than 0.01".
    /// This one also checks all superviews for the same parameters.
    var isVisible: Bool {
        return ([self] + superviews).allSatisfy { !$0.isHidden && $0.alpha >= 0.01 }
    }
    
    #if compiler(>=5)
    /// All view superviews to the top most
    var superviews: DropFirstSequence<UnfoldSequence<UIView, (UIView?, Bool)>> {
        return sequence(first: self, next: { $0.superview }).dropFirst(1)
    }
    #else
    /// All view superviews to the top most
    var superviews: AnySequence<UIView> {
        return sequence(first: self, next: { $0.superview }).dropFirst(1)
    }
    #endif
    
    /// Creates constraints between self and provided view for top, bottom, leading and trailing sides.
    @available(iOS 9.0, *)
    func _constraintSides(to view: UIView) {
        let constraints: [NSLayoutConstraint] = [
            bottomAnchor.constraint(equalTo: view.bottomAnchor),
            leadingAnchor.constraint(equalTo: view.leadingAnchor),
            trailingAnchor.constraint(equalTo: view.trailingAnchor),
            topAnchor.constraint(equalTo: view.topAnchor)
        ]
        
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate(constraints)
    }
    
    func _findCommonSuperview(with view: UIView) -> UIView? {
        var a: UIView? = self
        var b: UIView? = view
        var superSet = Set<UIView>()
        while a != nil || b != nil {
            
            if let aSuper = a {
                if !superSet.contains(aSuper) { superSet.insert(aSuper) }
                else { return aSuper }
            }
            if let bSuper = b {
                if !superSet.contains(bSuper) { superSet.insert(bSuper) }
                else { return bSuper }
            }
            a = a?.superview
            b = b?.superview
        }
        
        return nil
    }
    
    func adjustAnchorPointKeepingPosition(_ anchorPoint: CGPoint) {
        layer.anchorPoint = CGPoint(x: anchorPoint.x / bounds.width, y: anchorPoint.y / bounds.height)
        layer.position = anchorPoint
    }
}
