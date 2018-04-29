//
//  RestaurantViewModel.swift
//  DoorDashLite
//
//  Created by Vikramjeet Singh on 4/29/18.
//  Copyright © 2018 Vikramjeet Singh. All rights reserved.
//

import Foundation

protocol RestaurantViewModel {
    var restaurants: [Restaurant] { get }
    var count: Int { get }
    
    func numberOfSections() -> Int
    func numberOfRowsInSection(_ section: Int) -> Int
    func name(at index: Int) -> String
    func type(at index: Int) -> String
    func deliveryFee(at index: Int) -> String
    func waitStatus(at index: Int) -> String
    func thumbnail(at index: Int) -> String
    func cancelAllPendingRequests()
    func getImage(for indexPath: IndexPath, completionHandler: @escaping (UIImage?) -> Void)
}

extension RestaurantViewModel {
    subscript(index: Int) -> Restaurant? {
        get {
            return restaurants[index]
        }
    }
    
    var count: Int {
        return restaurants.count
    }
    
    /**
     Returns number of sections for the tableView
     */
    func numberOfSections() -> Int {
        return (restaurants.count > 0) ? 1 : 0
    }
    
    /**
     Returns number of rows in the tableView section
     */
    func numberOfRowsInSection(_ section: Int) -> Int {
        return restaurants.count
    }
    
    /**
     Returns name of the Restuarant at index
     - parameters index: Index in the restaurants list
     */
    func name(at index: Int) -> String {
        return restaurants[index].name
    }
    
    /**
     Returns type of the Restuarant at index
     - parameters index: Index in the restaurants list
     */
    func type(at index: Int) -> String {
        return restaurants[index].description
    }
    
    /**
     Returns name of the Restuarant at index
     - parameters index: Index in the restaurants list
     */
    func deliveryFee(at index: Int) -> String {
        var priceStr: String
        if restaurants[index].deliveryFee == 0 {
            priceStr = "Free"
        } else {
            priceStr = String(format: "$%.2f", Double(restaurants[index].deliveryFee) / 100.00)
        }
        //        let priceStr = (restaurants[index].deliveryFee == 0) ? "Free" : "$\(restaurants[index].deliveryFee / 100)"
        return priceStr + NSLocalizedString(" delivery", comment: "")
    }
    
    /**
     Returns wait status of the Restuarant at index
     - parameters index: Index in the restaurants list
     */
    func waitStatus(at index: Int) -> String {
        return (restaurants[index].statusType == "pre-order") ? NSLocalizedString("Pre-Order", comment: "") : NSLocalizedString("\(restaurants[index].waitTime ?? 0) mins", comment: "")
    }
    
    /**
     Returns thumbnail url string of the Restuarant at index
     - parameters index: Index in the restaurants list
     */
    func thumbnail(at index: Int) -> String {
        return restaurants[index].thumbnail
    }
    
    /**
     This method cancels all the pending requests for the session
     */
    func cancelAllPendingRequests() {
        NetworkManager.cancelAllPendingRequests()
    }
}
