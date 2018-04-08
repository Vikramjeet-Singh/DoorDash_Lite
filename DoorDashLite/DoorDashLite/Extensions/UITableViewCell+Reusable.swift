//
//  UITableViewCell+Reusable.swift
//  DoorDashLite
//
//  Created by Vikramjeet Singh on 4/8/18.
//  Copyright © 2018 Vikramjeet Singh. All rights reserved.
//

import Foundation

protocol ReusableCell: class {
    static var reuseIdentifier: String { get }
}

extension ReusableCell where Self: UITableViewCell {
    static var reuseIdentifier: String {
        return String(describing: self)
    }
}

extension UITableViewCell: ReusableCell {}
