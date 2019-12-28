//
//  ViewController.swift
//  APTips-Example
//
//  Created by Anton Plebanovich on 4/12/19.
//  Copyright © 2019 Anton Plebanovich. All rights reserved.
//

import APTips
import UIKit

final class ViewController: UIViewController {
    
    // ******************************* MARK: - @IBOutlets
    
    @IBOutlet private weak var button: UIButton!
    
    // ******************************* MARK: - Initialization and Setup
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        TipsManager.shared.resetOnceTips()
        TipsManager.shared.showOnce(tip: .exampleOnce, for: button, displayMode: .center)
    }
    
    // ******************************* MARK: - Actions
    
    @IBAction private func onActionTap(_ sender: UIButton) {
        TipsManager.shared.show(tip: .exampleAction, for: sender, displayMode: .side)
    }
}

extension Tip {
    static let exampleOnce = Tip(message: "Example show once tip")
    static let exampleAction = Tip(message: "Example action tip with long text message")
}
