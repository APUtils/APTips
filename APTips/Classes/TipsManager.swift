//
//  TipsManager.swift
//  APTips
//
//  Created by Anton Plebanovich on 10/16/19.
//  Copyright © 2019 Anton Plebanovich. All rights reserved.
//

import Foundation

/// Manager that is responsible for showing tips.
public final class TipsManager {
    
    /// Tip display completion.
    public typealias Completion = () -> Void
    
    /// Failable completion.
    /// - parameter success: Indicates if a tip was displayed for a user.
    public typealias FailableCompletion = (_ success: Bool) -> Void
    
    // ******************************* MARK: - Private Properties
    
    private static let defaultReusableViews: [UIView.Type] = [UITableViewCell.self, UICollectionViewCell.self]
    private var reusableViews: [UIView.Type] = TipsManager.defaultReusableViews
    
    /// Tips that are displaying atm
    private var displayingTips: [String] = []
    
    private var oncePerLaunchTipDisplayed = false
    
    // ******************************* MARK: - Initialization and Setup
    
    private init() {
        UIView.setupOnce
    }
    
    // ******************************* MARK: - Public Methods
    
    /// Add custom reusable views so `TipsManager` can properly
    /// constraint `TipView` position after reusable view was reused.
    /// `UITableViewCell` and `UICollectionViewCell` classes are always added.
    public func setReusableViewClasses(_ views: [UIView.Type]) {
        reusableViews = TipsManager.defaultReusableViews + views
    }
    
    /// Checks if tip can be shown right now.
    public func canTipBeDisplayedRightNow(_ tip: Tip) -> Bool {
        switch tip.showMode {
        case .always: return true
            
        case .once: return !displayedTips.contains(tip.id)
            && !displayingTips.contains(tip.id)
            
        case .onceAndOncePerLaunch: return !displayedTips.contains(tip.id)
            && !displayingTips.contains(tip.id)
            && !oncePerLaunchTipDisplayed
        }
    }
    
    public func show(tip: Tip, for view: @escaping @autoclosure () -> UIView?, completion: FailableCompletion? = nil) {
        switch tip.showMode {
        case .always: show(tip: tip, for: view()!) { completion?(true) }
        case .once: showOnce(tip: tip, for: view(), completion: completion)
        case .onceAndOncePerLaunch: showOnceAndOncePerLaunch(tip: tip, for: view(), completion: completion)
        }
    }
    
    /// Show tip immediatelly.
    /// - Parameters:
    ///   - tip: A tip to display
    ///   - view: View to point at.
    ///   - completion: Competion to call on tip's dismiss.
    private func show(tip: Tip, for view: UIView, completion: Completion? = nil) {
        let hostView = view._firstViewController?.view ?? view._rootView
        let tipView = TipView.create(tip: tip, for: view, deallocate: {
            completion?()
        }, completion: { tipView in
            tipView.removeFromSuperviewAnimated()
        })
        
        hostView.addTipViewAnimated(tipView)
    }
    
    /// Show specific tip once. It does it after 1s delay so this method can be called
    /// even before view is added to view hierarchy for simplicity.
    /// Additionally, it assures that there will be only one tip displayed per application launch.
    /// This way you can display some education tips without throwing all of them to the user's face at once.
    /// - Parameters:
    ///   - tip: A tip to display
    ///   - view: View to point at. You may pass not yet initialized force-unwrapped view parameter e.g. if you call this method in vc's `awakeFromNib()`.
    ///   - completion: Competion to call on tip's dismiss.
    private func showOnceAndOncePerLaunch(tip: Tip, for view: @escaping @autoclosure () -> UIView?, completion: FailableCompletion? = nil) {
        if oncePerLaunchTipDisplayed { completion?(false); return }
        oncePerLaunchTipDisplayed = true
        
        showOnce(tip: tip, for: view()) { success in
            if !success {
                self.oncePerLaunchTipDisplayed = false
            }
            
            completion?(success)
        }
    }
    
    /// Show specific tip once. It does it after 1s delay so this method can be called
    /// even before view is added to view hierarchy for simplicity.
    /// - Parameters:
    ///   - tip: A tip to display
    ///   - view: View to point at. You may pass not yet initialized force-unwrapped view parameter e.g. if you call this method in vc's `awakeFromNib()`.
    ///   - completion: Competion to call on tip's dismiss.   
    private func showOnce(tip: Tip, for view: @escaping @autoclosure () -> UIView?, completion: FailableCompletion? = nil) {
        guard !displayedTips.contains(tip.id) else { completion?(false); return }
        guard !displayingTips.contains(tip.id) else { completion?(false); return }
        displayingTips.append(tip.id)
        
        // Workaround for simplicity. There might be some animations ongoing, e.g. scrolling
        // so let all of them finish first. Also, we might need to wait before view is added to view hierarchy.
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            guard let view = view() else {
                self.displayingTips.removeAll(tip.id)
                completion?(false)
                return
            }
            
            guard let window = view.window else {
                print("Can not present a tip on a view outside of a view hierarchy. View: \(view)")
                self.displayingTips.removeAll(tip.id)
                return
            }
            
            guard view.isVisible else {
                print("Can not present a tip on an invisible view. View: \(view)")
                self.displayingTips.removeAll(tip.id)
                return
            }
            
            let hostView = view._firstViewController?.view ?? window
            let tipView = TipView.create(tip: tip, for: view, deallocate: { [weak self] in
                self?.displayingTips.removeAll(tip.id)
                completion?(true)
            }, completion: { tipView in
                tipView.removeFromSuperviewAnimated {
                    self.displayedTips.append(tip.id)
                }
            })
            
            hostView.addTipViewAnimated(tipView)
        }
    }
    
    /// Reset displayed once tips so they can be shown again.
    public func resetOnceTips() {
        displayedTips = []
    }
    
    // ******************************* MARK: - Internal and Private Methods
    
    func isReusableView(_ view: UIView) -> Bool {
        return reusableViews.reduce(false) { $0 || isReusableView(view, reusableView: $1) }
    }
    
    private func isReusableView<T>(_ view: UIView, reusableView: T.Type) -> Bool {
        return view is T
    }
}

// ******************************* MARK: - User Defaults

private let displayedTipsUserDefaultsKey = "TipsManager.displayedTips"

extension TipsManager {
    /// Tips that were displayed and dismissed by a user
    private var displayedTips: [String] {
        get {
            return UserDefaults.standard.object(forKey: displayedTipsUserDefaultsKey) as? [String] ?? []
        }
        set {
            guard displayedTips != newValue else { return }
            UserDefaults.standard.set(newValue, forKey: displayedTipsUserDefaultsKey)
        }
    }
}

// ******************************* MARK: - Singleton

public extension TipsManager {
    static let shared = TipsManager()
}

// ******************************* MARK: - Private Extensions

private extension UIView {
    
    func addTipViewAnimated(_ tipView: TipView) {
        UIView.performWithoutAnimation {
            tipView.alpha = 0
            tipView.containerView.transform = .init(scaleX: 0.5, y: 0.5)
            addSubview(tipView)
            layoutIfNeeded()
        }
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: [], animations: {
            tipView.alpha = 1
            tipView.containerView.transform = .init(scaleX: 1, y: 1)
            self.layoutIfNeeded()
        }, completion: nil)
    }
    
    func removeFromSuperviewAnimated(completion: (() -> Void)? = nil) {
        // Fade out and remove on completion
        UIView.animate(withDuration: 0.3, animations: {
            self.alpha = 0
        }, completion: { _ in
            self.removeFromSuperview()
            completion?()
        })
    }
}

private extension Array where Element: Equatable {
    
    /// Helper method to remove all objects that are equal to passed one.
    mutating func removeAll(_ element: Element) {
        removeAll { $0 == element }
    }
}
