//
//  TipView.swift
//  APTips
//
//  Created by Anton Plebanovich on 10/16/19.
//  Copyright © 2019 Anton Plebanovich. All rights reserved.
//

import UIKit

public final class TipView: UIView {
    
    // ******************************* MARK: - Display Mode
    
    /// Display mode for a tip.
    public enum DisplayMode {
        
        /// Tip will be displayed from a source center.
        case center
        
        /// Tip will be displayed from a source top or bottom side.
        case side
    }
    
    typealias Completion = (TipView) -> Void
    typealias Deallocate = () -> Void
    
    // ******************************* MARK: - Lazy Views
    
    enum Constants {
        static let infoBackgroundColor: UIColor = #colorLiteral(red: 0.7411764706, green: 0.7490196078, blue: 0.7568627451, alpha: 1)
        static let contentBackgroundColor: UIColor = #colorLiteral(red: 0.1294117647, green: 0.1333333333, blue: 0.137254902, alpha: 0.9)
        static let infoLabelTextColor: UIColor = #colorLiteral(red: 0.1294117647, green: 0.1333333333, blue: 0.137254902, alpha: 1)
        static let tipHeight: CGFloat = 11
        static let tipVerticalOffset: CGFloat = 3
        static let tipWidth: CGFloat = 20
        static let tipLabelTextColor: UIColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
    }
    
    fileprivate lazy var contentView: UIView = {
        let contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.backgroundColor = Constants.contentBackgroundColor
        contentView.layer.cornerRadius = 3
        contentView.accessibilityIdentifier = "contentView"
        
        return contentView
    }()
    
    fileprivate lazy var infoView: UIView = {
        let infoView = UIView()
        infoView.translatesAutoresizingMaskIntoConstraints = false
        infoView.backgroundColor = Constants.infoBackgroundColor
        infoView.layer.cornerRadius = 12
        infoView.accessibilityIdentifier = "infoView"
        
        return infoView
    }()
    
    fileprivate lazy var infoLabel: UILabel = {
        let infoLabel = UILabel()
        infoLabel.translatesAutoresizingMaskIntoConstraints = false
        infoLabel.backgroundColor = .clear
        infoLabel.text = "i"
        infoLabel.textColor = Constants.infoLabelTextColor
        infoLabel.accessibilityIdentifier = "infoLabel"
        
        return infoLabel
    }()
    
    fileprivate lazy var tipLabel: UILabel = {
        let tipLabel = UILabel()
        tipLabel.translatesAutoresizingMaskIntoConstraints = false
        tipLabel.backgroundColor = .clear
        tipLabel.numberOfLines = 0
        tipLabel.textColor = Constants.tipLabelTextColor
        tipLabel.accessibilityIdentifier = "tipLabel"
        
        return tipLabel
    }()
    
    fileprivate lazy var topArrowView: UIView = {
        let topArrowView = UIView()
        topArrowView.translatesAutoresizingMaskIntoConstraints = false
        topArrowView.backgroundColor = Constants.contentBackgroundColor
        topArrowView.accessibilityIdentifier = "topArrowView"
        
        return topArrowView
    }()
    
    fileprivate lazy var bottomArrowView: UIView = {
        let bottomArrowView = UIView()
        bottomArrowView.translatesAutoresizingMaskIntoConstraints = false
        bottomArrowView.backgroundColor = Constants.contentBackgroundColor
        bottomArrowView.accessibilityIdentifier = "bottomArrowView"
        
        return bottomArrowView
    }()
    
    fileprivate lazy var completionButton: UIButton = {
        let completionButton = UIButton()
        completionButton.translatesAutoresizingMaskIntoConstraints = false
        completionButton.addTarget(self, action: #selector(onTap(_:)), for: .touchUpInside)
        completionButton.accessibilityIdentifier = "completionButton"
        
        return completionButton
    }()
    
    // ******************************* MARK: - Properties
    
    private let topTipShapeLayer = CAShapeLayer()
    private let bottomTipShapeLayer = CAShapeLayer()
    private var displayMode: DisplayMode = .side
    private var completion: Completion = { _ in }
    private var deallocate: Deallocate = {}
    private weak var sourceView: UIView?
    private weak var positionConstraint: NSLayoutConstraint?
    
    // ******************************* MARK: - Initialization and Setup
    
    private func setup() {
        // Reconfigure constraints on view moving back to view hierarchy.
        // TODO: There is actually an undefined behavior on reuse but right now it should be ok. Fix later if needed.
        sourceView?._allReusableViews.forEach {
            $0._onDidMoveToSuperview = { [weak self] in
                self?.configureBottomConstraintIfNeeded()
            }
        }
    }
    
    deinit {
        deallocate()
    }
    
    // ******************************* MARK: - Layout
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        configureMask()
    }
    
    private func configureMask() {
        let tipMinX = (bottomArrowView.bounds.size.width - Constants.tipWidth) / 2
        let tipMaxX = (bottomArrowView.bounds.size.width + Constants.tipWidth) / 2
        
        // TODO: Do arrow rounded if needed later
        let path = UIBezierPath()
        path.move(to: .init(x: tipMinX, y: 0))
        path.addLine(to: .init(x: tipMaxX, y: 0))
        path.addLine(to: .init(x: bottomArrowView.bounds.size.width / 2, y: Constants.tipHeight))
        path.addLine(to: .init(x: tipMinX, y: 0))
        bottomTipShapeLayer.path = path.cgPath
        bottomArrowView.layer.mask = bottomTipShapeLayer
        
        path.apply(.init(translationX: -bottomArrowView.bounds.size.width, y: -bottomArrowView.bounds.size.height))
        path.apply(.init(rotationAngle: .pi))
        topTipShapeLayer.path = path.cgPath
        topArrowView.layer.mask = topTipShapeLayer
    }
    
    override public func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        if let superview = superview {
            topAnchor.constraint(equalTo: superview.topAnchor).isActive = true
            leadingAnchor.constraint(equalTo: superview.leadingAnchor).isActive = true
            trailingAnchor.constraint(equalTo: superview.trailingAnchor).isActive = true
            bottomAnchor.constraint(equalTo: superview.bottomAnchor).isActive = true
            
            configureBottomConstraintIfNeeded()
        }
    }
    
    private func configureBottomConstraintIfNeeded() {
        // Reconfigure only if constraint is not yet set or become inactive
        guard positionConstraint?.isActive != true else { return }
        guard let sourceView = sourceView else { return }
        
        // Root view must be the same for tip and source views
        guard sourceView._rootView === _rootView else { return }
        
        switch displayMode {
        case .side:
            let sourceViewInRootFrame = sourceView.convert(sourceView.bounds, to: sourceView._rootView)
            let topSpace = sourceViewInRootFrame.minY
            let bottomSpace = sourceView._rootView.bounds.maxY - sourceViewInRootFrame.maxY
            if topSpace > bottomSpace {
                bottomArrowView.alpha = 1
                topArrowView.alpha = 0
                let positionConstraint = bottomArrowView.bottomAnchor.constraint(equalTo: sourceView.topAnchor, constant: Constants.tipVerticalOffset)
                positionConstraint.isActive = true
                self.positionConstraint = positionConstraint
                
            } else {
                bottomArrowView.alpha = 0
                topArrowView.alpha = 1
                let positionConstraint = sourceView.bottomAnchor.constraint(equalTo: topArrowView.topAnchor, constant: Constants.tipVerticalOffset)
                positionConstraint.isActive = true
                self.positionConstraint = positionConstraint
            }
            
        case .center:
            let sourceBoundsCenter = CGPoint(x: sourceView.bounds.midX, y: sourceView.bounds.midY)
            let sourceViewCenterInRoot = sourceView.convert(sourceBoundsCenter, to: sourceView._rootView)
            let topSpace = sourceViewCenterInRoot.y
            let bottomSpace = sourceView._rootView.bounds.maxY - sourceViewCenterInRoot.y
            if topSpace > bottomSpace {
                bottomArrowView.alpha = 1
                topArrowView.alpha = 0
                let positionConstraint = bottomArrowView.bottomAnchor.constraint(equalTo: sourceView.centerYAnchor)
                positionConstraint.isActive = true
                self.positionConstraint = positionConstraint
                
            } else {
                bottomArrowView.alpha = 0
                topArrowView.alpha = 1
                let positionConstraint = sourceView.centerYAnchor.constraint(equalTo: topArrowView.topAnchor)
                positionConstraint.isActive = true
                self.positionConstraint = positionConstraint
            }
        }
    }
    
    // ******************************* MARK: - Action
    
    @IBAction private func onTap(_ sender: Any) {
        completion(self)
    }
}

// ******************************* MARK: - Create

extension TipView {
    static func create(tip: Tip, for source: UIView, displayMode: DisplayMode, deallocate: @escaping Deallocate = {}, completion: @escaping Completion) -> TipView {
        let view = createFromCode()
        view.tipLabel.text = tip.message
        view.displayMode = displayMode
        view.completion = completion
        view.deallocate = deallocate
        view.sourceView = source
        view.setup()
        
        return view
    }
    
    private static func createFromCode() -> TipView {
        let tipView = TipView(frame: UIScreen.main.bounds)
        tipView.backgroundColor = .clear
        tipView.translatesAutoresizingMaskIntoConstraints = false
        tipView.accessibilityIdentifier = "tipView"
        
        // View Hierarchy
        tipView.infoView.addSubview(tipView.infoLabel)
        tipView.contentView.addSubview(tipView.infoView)
        tipView.contentView.addSubview(tipView.tipLabel)
        tipView.addSubview(tipView.topArrowView)
        tipView.addSubview(tipView.contentView)
        tipView.addSubview(tipView.bottomArrowView)
        tipView.addSubview(tipView.completionButton)
        
        // Constraints
        tipView.infoLabel.centerYAnchor.constraint(equalTo: tipView.infoView.centerYAnchor).isActive = true
        tipView.infoLabel.centerXAnchor.constraint(equalTo: tipView.infoView.centerXAnchor).isActive = true
        
        tipView.infoView.centerYAnchor.constraint(equalTo: tipView.contentView.centerYAnchor).isActive = true
        tipView.infoView.heightAnchor.constraint(equalToConstant: 24).isActive = true
        tipView.infoView.widthAnchor.constraint(equalToConstant: 24).isActive = true
        tipView.infoView.leadingAnchor.constraint(equalTo: tipView.contentView.leadingAnchor, constant: 16).isActive = true
        tipView.tipLabel.leadingAnchor.constraint(equalTo: tipView.infoView.trailingAnchor, constant: 16).isActive = true
        
        tipView.tipLabel.centerYAnchor.constraint(equalTo: tipView.contentView.centerYAnchor).isActive = true
        tipView.contentView.trailingAnchor.constraint(equalTo: tipView.tipLabel.trailingAnchor, constant: 16).isActive = true
        tipView.tipLabel.topAnchor.constraint(equalTo: tipView.contentView.topAnchor, constant: 16).isActive = true
        tipView.contentView.bottomAnchor.constraint(equalTo: tipView.tipLabel.bottomAnchor, constant: 16).isActive = true
        
        tipView.contentView.leadingAnchor.constraint(greaterThanOrEqualTo: tipView.leadingAnchor, constant: 16).isActive = true
        tipView.trailingAnchor.constraint(greaterThanOrEqualTo: tipView.contentView.trailingAnchor, constant: 16).isActive = true
        tipView.contentView.centerXAnchor.constraint(equalTo: tipView.centerXAnchor).isActive = true
        
        tipView.topArrowView.bottomAnchor.constraint(equalTo: tipView.contentView.topAnchor).isActive = true
        tipView.topArrowView.leadingAnchor.constraint(equalTo: tipView.contentView.leadingAnchor).isActive = true
        tipView.topArrowView.trailingAnchor.constraint(equalTo: tipView.contentView.trailingAnchor).isActive = true
        tipView.topArrowView.heightAnchor.constraint(equalToConstant: 11).isActive = true
        
        tipView.bottomArrowView.topAnchor.constraint(equalTo: tipView.contentView.bottomAnchor).isActive = true
        tipView.bottomArrowView.leadingAnchor.constraint(equalTo: tipView.contentView.leadingAnchor).isActive = true
        tipView.bottomArrowView.trailingAnchor.constraint(equalTo: tipView.contentView.trailingAnchor).isActive = true
        tipView.bottomArrowView.heightAnchor.constraint(equalToConstant: 11).isActive = true
        
        tipView.completionButton.topAnchor.constraint(equalTo: tipView.topAnchor).isActive = true
        tipView.completionButton.leadingAnchor.constraint(equalTo: tipView.leadingAnchor).isActive = true
        tipView.completionButton.trailingAnchor.constraint(equalTo: tipView.trailingAnchor).isActive = true
        tipView.completionButton.bottomAnchor.constraint(equalTo: tipView.bottomAnchor).isActive = true
        
        return tipView
    }
}

// ******************************* MARK: - Swizzle Functions

private func swizzleClassMethods(class: AnyClass, originalSelector: Selector, swizzledSelector: Selector) {
    guard class_isMetaClass(`class`) else { return }
    
    let originalMethod = class_getClassMethod(`class`, originalSelector)!
    let swizzledMethod = class_getClassMethod(`class`, swizzledSelector)!
    
    swizzleMethods(class: `class`, originalSelector: originalSelector, originalMethod: originalMethod, swizzledSelector: swizzledSelector, swizzledMethod: swizzledMethod)
}

private func swizzleMethods(class: AnyClass, originalSelector: Selector, swizzledSelector: Selector) {
    guard !class_isMetaClass(`class`) else { return }
    
    let originalMethod = class_getInstanceMethod(`class`, originalSelector)!
    let swizzledMethod = class_getInstanceMethod(`class`, swizzledSelector)!
    
    swizzleMethods(class: `class`, originalSelector: originalSelector, originalMethod: originalMethod, swizzledSelector: swizzledSelector, swizzledMethod: swizzledMethod)
}

private func swizzleMethods(class: AnyClass, originalSelector: Selector, originalMethod: Method, swizzledSelector: Selector, swizzledMethod: Method) {
    let didAddMethod = class_addMethod(`class`, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod))
    
    if didAddMethod {
        class_replaceMethod(`class`, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod))
    } else {
        method_exchangeImplementations(originalMethod, swizzledMethod)
    }
}

// ******************************* MARK: - Load

extension UIView {
    static var setupOnce: Void {
        struct Private {
            static var setupOnce: Void = {
                swizzleMethods(class: UIView.self, originalSelector: #selector(didMoveToSuperview), swizzledSelector: #selector(_tipView_didMoveToSuperview))
            }()
        }
        
        return Private.setupOnce
    }
}

// ******************************* MARK: - UIView Method Listening

private var c_onDidMoveToSuperviewAssociationKey = 0

private extension UIView {
    typealias Action = () -> Void
    
    var _onDidMoveToSuperview: Action? {
        get {
            return objc_getAssociatedObject(self, &c_onDidMoveToSuperviewAssociationKey) as? Action
        }
        set {
            objc_setAssociatedObject(self, &c_onDidMoveToSuperviewAssociationKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    @objc private func _tipView_didMoveToSuperview() {
        _tipView_didMoveToSuperview()
        _onDidMoveToSuperview?()
    }
}
