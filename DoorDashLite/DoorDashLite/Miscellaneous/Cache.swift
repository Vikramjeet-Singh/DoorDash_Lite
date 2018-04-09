//
//  Cache.swift
//  DoorDashLite
//
//  Created by Vikramjeet Singh on 4/8/18.
//  Copyright © 2018 Vikramjeet Singh. All rights reserved.
//

import Foundation
import UIKit

struct Cache<T: AnyObject> {
    private let cache = NSCache<NSString, T>()
    
    subscript(key: String) -> T? {
        get {
            return cache.object(forKey: key as NSString)
        }
        
        mutating set(newValue) {
            if let newValue = newValue {
                cache.setObject(newValue, forKey: key as NSString)

            } else {
                cache.removeObject(forKey: key as NSString)
            }
        }
    }
}

