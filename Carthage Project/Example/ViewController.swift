//
//  ViewController.swift
//  APTips-Example
//
//  Created by Anton Plebanovich on 4/12/19.
//  Copyright © 2019 Anton Plebanovich. All rights reserved.
//

import APExtensions
import APTips
import UIKit

final class ViewController: UIViewController {
    
    // ******************************* MARK: - @IBOutlets
    
    @IBOutlet private var navigationBarLeftButton: UIButton!
    @IBOutlet private var navigationBarRightButton: UIButton!
    @IBOutlet private weak var centerButton: UIButton!
    
    // ******************************* MARK: - Initialization and Setup
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        // View and outlets not yet initialized. Still, this one works!
        TipsManager.shared.show(tip: .exampleLaunch1, for: self.navigationBarLeftButton)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Outlets not yet initialized. Still, this one works!
        TipsManager.shared.show(tip: .exampleLaunch2, for: self.navigationBarRightButton)
        TipsManager.shared.show(tip: .exampleLaunch3, for: self.navigationBarLeftButton)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        TipsManager.shared.resetOnceTips()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        TipsManager.shared.show(tip: .exampleOnce, for: self.centerButton) { [weak centerButton] success in
            guard success, let _centerButton = centerButton else { return }
            TipsManager.shared.show(tip: .exampleCallbackAction, for: _centerButton)
        }
    }
    
    // ******************************* MARK: - Actions
    
    @IBAction private func onActionTap(_ sender: UIButton) {
        TipsManager.shared.show(tip: .exampleAction, for: sender)
    }
}

// ******************************* MARK: - Tips

extension Tip {
    static let exampleOnce = Tip(message: "Example show once tip", pointingMode: .center, showMode: .once)
    static let exampleAction = Tip(message: "Example action tip with long text message", pointingMode: .side, showMode: .always)
    static let exampleCallbackAction = Tip(message: "Example callback action tip which is called after initial one with long text message", pointingMode: .center, showMode: .always)
    static let exampleLaunch1 = Tip(message: "Tip message that will be shown on the first launch", pointingMode: .center, showMode: .onceAndOncePerLaunch)
    static let exampleLaunch2 = Tip(message: "Tip message that will be shown on the second launch", pointingMode: .side, showMode: .onceAndOncePerLaunch)
    static let exampleLaunch3 = Tip(message: "Tip message that will be shown on the third launch", pointingMode: .side, showMode: .onceAndOncePerLaunch)
}

// ******************************* MARK: - InstantiatableFromStoryboard

extension ViewController: InstantiatableFromStoryboard {
    static var storyboardName: String = "Main"
}
