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
        TipsManager.shared.showOnceAndOncePerLaunch(tip: .exampleLaunch1, for: self.navigationBarLeftButton)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Outlets not yet initialized. Still, this one works!
        TipsManager.shared.showOnceAndOncePerLaunch(tip: .exampleLaunch2, for: self.navigationBarRightButton)
        TipsManager.shared.showOnceAndOncePerLaunch(tip: .exampleLaunch3, for: self.navigationBarLeftButton)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        TipsManager.shared.resetOnceTips()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        TipsManager.shared.showOnce(tip: .exampleOnce, for: self.centerButton) { [weak centerButton] success in
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
    static let exampleOnce = Tip(message: "Example show once tip", displayMode: .center)
    static let exampleAction = Tip(message: "Example action tip with long text message", displayMode: .side)
    static let exampleCallbackAction = Tip(message: "Example callback action tip which is called after initial one with long text message", displayMode: .center)
    static let exampleLaunch1 = Tip(message: "Tip message that will be shown on the first launch", displayMode: .center)
    static let exampleLaunch2 = Tip(message: "Tip message that will be shown on the second launch", displayMode: .side)
    static let exampleLaunch3 = Tip(message: "Tip message that will be shown on the third launch", displayMode: .side)
}

// ******************************* MARK: - InstantiatableFromStoryboard

extension ViewController: InstantiatableFromStoryboard {
    static var storyboardName: String = "Main"
}
