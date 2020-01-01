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
    
    @IBOutlet private weak var button: UIButton!
    
    // ******************************* MARK: - Initialization and Setup
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        TipsManager.shared.resetOnceTips()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        UIApplication.shared.doOnce(key: "ViewController.viewDidAppear") {
            let vc = ViewController.create()
            navigationController?.pushViewController(vc, animated: true) {
                vc.remove(animated: true)
                TipsManager.shared.showOnce(tip: .exampleOnce, for: vc.button, displayMode: .center) { [weak vc] success in
                    guard success, let button = vc?.button else { return }
                    TipsManager.shared.show(tip: .exampleCallbackAction, for: button, displayMode: .side)
                }
            }
        }
    }
    
    // ******************************* MARK: - Actions
    
    @IBAction private func onActionTap(_ sender: UIButton) {
        TipsManager.shared.show(tip: .exampleAction, for: sender, displayMode: .side) { [weak sender] in
            guard let sender = sender else { return }
            TipsManager.shared.show(tip: .exampleCallbackAction, for: sender, displayMode: .side)
        }
    }
}

// ******************************* MARK: - Tips

extension Tip {
    static let exampleOnce = Tip(message: "Example show once tip")
    static let exampleAction = Tip(message: "Example action tip with long text message")
    static let exampleCallbackAction = Tip(message: "Example callback action tip which is called after initial one with long text message")
}

// ******************************* MARK: - InstantiatableFromStoryboard

extension ViewController: InstantiatableFromStoryboard {
    static var storyboardName: String = "Main"
}
