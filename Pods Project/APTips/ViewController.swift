//
//  ViewController.swift
//  APTips
//
//  Created by Anton Plebanovich on 12/28/2019.
//  Copyright (c) 2019 Anton Plebanovich. All rights reserved.
//

import APTips
import UIKit

class ViewController: UIViewController {
    
    @IBAction fileprivate func onTap(_ sender: UIButton) {
        var configuration = TipView.Configuration.default
        configuration.borderColor = .red
        configuration.borderWidth = 5
        
        let tip = Tip(message: "Ta-da",
                      configuration: configuration,
                      pointingMode: .side(offset: -20),
                      showMode: .always)
        
        TipsManager.shared.show(tip: tip, for: sender)
    }
}
