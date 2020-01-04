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
    
    public enum Constants {
        public enum View {
            public static var contentBackgroundColor: UIColor = #colorLiteral(red: 0.1294117647, green: 0.1333333333, blue: 0.137254902, alpha: 0.9)
            public static var contentCornerRadius: CGFloat = 8
            public static var infoBackgroundColor: UIColor = #colorLiteral(red: 0.7411764706, green: 0.7490196078, blue: 0.7568627451, alpha: 1)
            public static var infoLabelTextColor: UIColor = #colorLiteral(red: 0.1294117647, green: 0.1333333333, blue: 0.137254902, alpha: 1)
            public static var showInfoView: Bool = false
            public static var tipLabelFont: UIFont = .systemFont(ofSize: 17, weight: .bold)
            public static var tipLabelTextColor: UIColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        }
    }
    
    /// View that contains content with pointing arrows
    private(set) lazy var containerView: UIView = {
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.backgroundColor = .clear
        containerView.accessibilityIdentifier = "containerView"
        
        return containerView
    }()
    
    /// View that contains content
    private(set) lazy var contentView: UIView = {
        let contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.backgroundColor = Constants.View.contentBackgroundColor
        contentView.layer.cornerRadius = Constants.View.contentCornerRadius
        contentView.accessibilityIdentifier = "contentView"
        
        return contentView
    }()
    
    private(set) lazy var infoView: UIView = {
        let infoView = UIView()
        infoView.translatesAutoresizingMaskIntoConstraints = false
        infoView.backgroundColor = Constants.View.infoBackgroundColor
        infoView.layer.cornerRadius = Constants.Layout.infoViewSide / 2
        infoView.accessibilityIdentifier = "infoView"
        
        return infoView
    }()
    
    private(set) lazy var infoLabel: UILabel = {
        let infoLabel = UILabel()
        infoLabel.translatesAutoresizingMaskIntoConstraints = false
        infoLabel.backgroundColor = .clear
        infoLabel.text = "i"
        infoLabel.textColor = Constants.View.infoLabelTextColor
        infoLabel.accessibilityIdentifier = "infoLabel"
        infoLabel.accessibilityTraits = .staticText
        infoLabel.isAccessibilityElement = true
        
        return infoLabel
    }()
    
    private(set) lazy var tipLabel: UILabel = {
        let tipLabel = UILabel()
        tipLabel.translatesAutoresizingMaskIntoConstraints = false
        tipLabel.backgroundColor = .clear
        tipLabel.numberOfLines = 0
        tipLabel.textAlignment = .center
        tipLabel.font = Constants.View.tipLabelFont
        tipLabel.textColor = Constants.View.tipLabelTextColor
        tipLabel.accessibilityIdentifier = "tipLabel"
        tipLabel.accessibilityTraits = .staticText
        tipLabel.isAccessibilityElement = true
        
        return tipLabel
    }()
    
    // TODO: Ideally we should have whole container masked instead of having tip views. This will prevent animation bug like pixel gap between tip view and container view.
    private lazy var bottomTipShapeLayerPath: UIBezierPath = {
        // TODO: Do arrow rounded if needed later
        let bottomTipShapeLayerPath = UIBezierPath()
        bottomTipShapeLayerPath.move(to: .zero)
        bottomTipShapeLayerPath.addLine(to: .init(x: Constants.Layout.tipWidth / 2, y: Constants.Layout.tipHeight))
        bottomTipShapeLayerPath.addLine(to: .init(x: Constants.Layout.tipWidth, y: 0))
        bottomTipShapeLayerPath.addLine(to: .zero)
        
        return bottomTipShapeLayerPath
    }()
    
    private lazy var bottomTipShapeLayer: CAShapeLayer = {
        let bottomTipShapeLayer = CAShapeLayer()
        bottomTipShapeLayer.path = bottomTipShapeLayerPath.cgPath
        
        return bottomTipShapeLayer
    }()
    
    private(set) lazy var bottomArrowView: UIView = {
        let bottomArrowView = UIView(frame: .init(x: 0, y: 0, width: Constants.Layout.tipWidth, height: Constants.Layout.tipHeight))
        bottomArrowView.translatesAutoresizingMaskIntoConstraints = false
        bottomArrowView.backgroundColor = Constants.View.contentBackgroundColor
        bottomArrowView.layer.mask = bottomTipShapeLayer
        bottomArrowView.accessibilityIdentifier = "bottomArrowView"
        
        return bottomArrowView
    }()
    
    private lazy var topTipShapeLayerPath: UIBezierPath = {
        let topTipShapeLayerPath = bottomTipShapeLayerPath.copy() as! UIBezierPath
        topTipShapeLayerPath.apply(.init(translationX: -Constants.Layout.tipWidth, y: -Constants.Layout.tipHeight))
        topTipShapeLayerPath.apply(.init(rotationAngle: .pi))
        
        return topTipShapeLayerPath
    }()
    
    private lazy var topTipShapeLayer: CAShapeLayer = {
        let topTipShapeLayer = CAShapeLayer()
        topTipShapeLayer.path = topTipShapeLayerPath.cgPath
        
        return topTipShapeLayer
    }()
    
    private(set) lazy var topArrowView: UIView = {
        let topArrowView = UIView(frame: .init(x: 0, y: 0, width: Constants.Layout.tipWidth, height: Constants.Layout.tipHeight))
        topArrowView.translatesAutoresizingMaskIntoConstraints = false
        topArrowView.backgroundColor = Constants.View.contentBackgroundColor
        topArrowView.layer.mask = topTipShapeLayer
        topArrowView.accessibilityIdentifier = "topArrowView"
        
        return topArrowView
    }()
    
    private(set) lazy var completionButton: UIButton = {
        let completionButton = UIButton()
        completionButton.translatesAutoresizingMaskIntoConstraints = false
        completionButton.addTarget(self, action: #selector(onTap(_:)), for: .touchUpInside)
        completionButton.accessibilityIdentifier = "completionButton"
        completionButton.accessibilityTraits = .button
        completionButton.isAccessibilityElement = true
        if #available(iOS 13.0, *) {
            completionButton.accessibilityRespondsToUserInteraction = true
        }
        
        return completionButton
    }()
    
    // ******************************* MARK: - Properties
    
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
    
    override public func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        if let superview = superview {
            _constraintSides(to: superview)
            configureBottomConstraintIfNeeded()
        }
    }
    
    private func configureBottomConstraintIfNeeded() {
        // Reconfigure only if constraint is not yet set or become inactive
        guard positionConstraint?.isActive != true else { return }
        guard let sourceView = sourceView else { return }
        
        // Source and tip should have host view
        guard let hostView = sourceView._findCommonSuperview(with: self) else { return }
        
        switch displayMode {
        case .side:
            if shouldShowFromTop(sourceView: sourceView, hostView: hostView) {
                bottomArrowView.alpha = 1
                topArrowView.alpha = 0
                let positionConstraint = bottomArrowView.bottomAnchor.constraint(equalTo: sourceView.topAnchor, constant: Constants.Layout.tipVerticalOffset)
                positionConstraint.isActive = true
                self.positionConstraint = positionConstraint
                
                let centerXConstraint = bottomArrowView.centerXAnchor.constraint(equalTo: sourceView.centerXAnchor)
                centerXConstraint.priority = .init(2)
                centerXConstraint.isActive = true
                
            } else {
                bottomArrowView.alpha = 0
                topArrowView.alpha = 1
                let positionConstraint = sourceView.bottomAnchor.constraint(equalTo: topArrowView.topAnchor, constant: Constants.Layout.tipVerticalOffset)
                positionConstraint.isActive = true
                self.positionConstraint = positionConstraint
                
                let centerXConstraint = topArrowView.centerXAnchor.constraint(equalTo: sourceView.centerXAnchor)
                centerXConstraint.priority = .init(2)
                centerXConstraint.isActive = true
            }
            
        case .center:
            let sourceBoundsCenter = CGPoint(x: sourceView.bounds.midX, y: sourceView.bounds.midY)
            let sourceViewCenterInRoot = sourceView.convert(sourceBoundsCenter, to: hostView)
            let topSpace = sourceViewCenterInRoot.y
            let bottomSpace = hostView.bounds.maxY - sourceViewCenterInRoot.y
            if topSpace > bottomSpace {
                bottomArrowView.alpha = 1
                topArrowView.alpha = 0
                let positionConstraint = bottomArrowView.bottomAnchor.constraint(equalTo: sourceView.centerYAnchor)
                positionConstraint.isActive = true
                self.positionConstraint = positionConstraint
                
                let centerXConstraint = bottomArrowView.centerXAnchor.constraint(equalTo: sourceView.centerXAnchor)
                centerXConstraint.priority = .init(2)
                centerXConstraint.isActive = true
                
            } else {
                bottomArrowView.alpha = 0
                topArrowView.alpha = 1
                let positionConstraint = sourceView.centerYAnchor.constraint(equalTo: topArrowView.topAnchor)
                positionConstraint.isActive = true
                self.positionConstraint = positionConstraint
                
                let centerXConstraint = topArrowView.centerXAnchor.constraint(equalTo: sourceView.centerXAnchor)
                centerXConstraint.priority = .init(2)
                centerXConstraint.isActive = true
            }
        }
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        configureAnimationAnchorPoint()
    }
    
    private func configureAnimationAnchorPoint() {
        guard let sourceView = sourceView else { return }
        
        // Source and tip should have host view
        guard let hostView = sourceView._findCommonSuperview(with: self) else { return }
        let sourceViewFrameInHostView = sourceView.convert(sourceView.bounds, to: hostView)
        
        switch displayMode {
        case .side:
            if shouldShowFromTop(sourceView: sourceView, hostView: hostView) {
                containerView.adjustAnchorPointKeepingPosition(.init(x: sourceViewFrameInHostView.midX, y: sourceViewFrameInHostView.minY))
            } else {
                containerView.adjustAnchorPointKeepingPosition(.init(x: sourceViewFrameInHostView.midX, y: sourceViewFrameInHostView.maxY))
            }
            
        case .center:
            containerView.adjustAnchorPointKeepingPosition(.init(x: sourceViewFrameInHostView.midX, y: sourceViewFrameInHostView.midY))
        }
    }
    
    private func shouldShowFromTop(sourceView: UIView, hostView: UIView) -> Bool {
        let sourceViewFrameInHostView = sourceView.convert(sourceView.bounds, to: hostView)
        let topSpace = sourceViewFrameInHostView.minY
        let bottomSpace = hostView.bounds.maxY - sourceViewFrameInHostView.maxY
        return topSpace > bottomSpace
    }
    
    // ******************************* MARK: - Action
    
    @IBAction private func onTap(_ sender: Any) {
        completion(self)
    }
}

// ******************************* MARK: - Create

public extension TipView.Constants {
    enum Layout {
        public static var infoViewSide: CGFloat = 20
        public static var sideOffset: CGFloat = 8
        public static var tipHeight: CGFloat = 11
        public static var tipVerticalOffset: CGFloat = 3
        public static var tipWidth: CGFloat = 20
    }
}

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
        tipView.backgroundColor = .init(white: 0, alpha: 0.3)
        tipView.translatesAutoresizingMaskIntoConstraints = false
        tipView.accessibilityIdentifier = "tipView"
        
        // View Hierarchy
        if Constants.View.showInfoView {
            tipView.infoView.addSubview(tipView.infoLabel)
            tipView.contentView.addSubview(tipView.infoView)
        }
        
        tipView.contentView.addSubview(tipView.tipLabel)
        tipView.containerView.addSubview(tipView.contentView)
        tipView.containerView.addSubview(tipView.bottomArrowView)
        tipView.containerView.addSubview(tipView.topArrowView)
        tipView.addSubview(tipView.containerView)
        tipView.addSubview(tipView.completionButton)
        
        // Constraints
        if Constants.View.showInfoView {
            tipView.infoLabel.centerYAnchor.constraint(equalTo: tipView.infoView.centerYAnchor).isActive = true
            tipView.infoLabel.centerXAnchor.constraint(equalTo: tipView.infoView.centerXAnchor).isActive = true
            
            tipView.infoView.centerYAnchor.constraint(equalTo: tipView.contentView.centerYAnchor).isActive = true
            tipView.infoView.heightAnchor.constraint(equalToConstant: Constants.Layout.infoViewSide).isActive = true
            tipView.infoView.widthAnchor.constraint(equalToConstant: Constants.Layout.infoViewSide).isActive = true
            tipView.infoView.leadingAnchor.constraint(equalTo: tipView.contentView.leadingAnchor, constant: Constants.Layout.sideOffset).isActive = true
            tipView.tipLabel.leadingAnchor.constraint(equalTo: tipView.infoView.trailingAnchor, constant: Constants.Layout.sideOffset).isActive = true
        } else {
            tipView.tipLabel.leadingAnchor.constraint(equalTo: tipView.contentView.leadingAnchor, constant: Constants.Layout.sideOffset).isActive = true
        }
        
        tipView.tipLabel.centerYAnchor.constraint(equalTo: tipView.contentView.centerYAnchor).isActive = true
        tipView.contentView.trailingAnchor.constraint(equalTo: tipView.tipLabel.trailingAnchor, constant: Constants.Layout.sideOffset).isActive = true
        tipView.tipLabel.topAnchor.constraint(equalTo: tipView.contentView.topAnchor, constant: Constants.Layout.sideOffset).isActive = true
        tipView.contentView.bottomAnchor.constraint(equalTo: tipView.tipLabel.bottomAnchor, constant: Constants.Layout.sideOffset).isActive = true
        
        tipView.contentView.leadingAnchor.constraint(greaterThanOrEqualTo: tipView.containerView.leadingAnchor, constant: Constants.Layout.sideOffset).isActive = true
        tipView.containerView.trailingAnchor.constraint(greaterThanOrEqualTo: tipView.contentView.trailingAnchor, constant: Constants.Layout.sideOffset).isActive = true
        
        tipView.topArrowView.bottomAnchor.constraint(equalTo: tipView.contentView.topAnchor).isActive = true
        tipView.topArrowView.heightAnchor.constraint(equalToConstant: Constants.Layout.tipHeight).isActive = true
        tipView.topArrowView.widthAnchor.constraint(equalToConstant: Constants.Layout.tipWidth).isActive = true
        tipView.topArrowView.leadingAnchor.constraint(greaterThanOrEqualTo: tipView.contentView.leadingAnchor, constant: Constants.Layout.sideOffset).isActive = true
        tipView.contentView.trailingAnchor.constraint(greaterThanOrEqualTo: tipView.topArrowView.trailingAnchor, constant: Constants.Layout.sideOffset).isActive = true
        let topArrowToContentViewCenterX = tipView.topArrowView.centerXAnchor.constraint(equalTo: tipView.contentView.centerXAnchor)
        topArrowToContentViewCenterX.priority = .init(1)
        topArrowToContentViewCenterX.isActive = true
        
        tipView.contentView.bottomAnchor.constraint(equalTo: tipView.bottomArrowView.topAnchor).isActive = true
        tipView.bottomArrowView.heightAnchor.constraint(equalToConstant: Constants.Layout.tipHeight).isActive = true
        tipView.bottomArrowView.widthAnchor.constraint(equalToConstant: Constants.Layout.tipWidth).isActive = true
        tipView.bottomArrowView.leadingAnchor.constraint(greaterThanOrEqualTo: tipView.contentView.leadingAnchor, constant: Constants.Layout.sideOffset).isActive = true
        tipView.contentView.trailingAnchor.constraint(greaterThanOrEqualTo: tipView.bottomArrowView.trailingAnchor, constant: Constants.Layout.sideOffset).isActive = true
        let bottomArrowToContentViewCenterX = tipView.bottomArrowView.centerXAnchor.constraint(equalTo: tipView.contentView.centerXAnchor)
        bottomArrowToContentViewCenterX.priority = .init(1)
        bottomArrowToContentViewCenterX.isActive = true
        
        tipView.completionButton._constraintSides(to: tipView)
        tipView.containerView._constraintSides(to: tipView)
        
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
}

// ******************************* MARK: - Private Extensions

extension UIView {
    func adjustAnchorPointKeepingPosition(_ anchorPoint: CGPoint) {
        layer.anchorPoint = CGPoint(x: anchorPoint.x / bounds.width, y: anchorPoint.y / bounds.height)
        layer.position = anchorPoint
    }
}

private extension CGPoint {
    
    static func +(lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        return CGPoint(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
    }
    
    static prefix func -(point: CGPoint) -> CGPoint {
        return CGPoint(x: -point.x, y: -point.y)
    }
    
    static func -(lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        return CGPoint(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
    }
    
    static func /(lhs: CGPoint, rhs: CGFloat) -> CGPoint {
        return CGPoint(x: lhs.x / rhs, y: lhs.y / rhs)
    }
}
