//
//  UIView+Utils.swift
//  APTips
//
//  Created by Anton Plebanovich on 12/28/19.
//  Copyright © 2019 Anton Plebanovich. All rights reserved.
//

import Foundation

extension UIView {
    
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
}
