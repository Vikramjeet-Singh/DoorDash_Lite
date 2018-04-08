//
//  UIViewController+HUD.swift
//  DoorDashLite
//
//  Created by Vikramjeet Singh on 4/8/18.
//  Copyright © 2018 Vikramjeet Singh. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    func showHud(_ message: String) {
        let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        hud.label.text = message
        hud.isUserInteractionEnabled = false
    }
    
    func hideHUD() {
        MBProgressHUD.hide(for: self.view, animated: true)
    }
}
