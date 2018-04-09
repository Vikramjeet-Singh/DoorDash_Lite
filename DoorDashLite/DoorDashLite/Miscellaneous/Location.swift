//
//  Location.swift
//  DoorDashLite
//
//  Created by Vikramjeet Singh on 4/8/18.
//  Copyright © 2018 Vikramjeet Singh. All rights reserved.
//

import Foundation
import CoreLocation

struct Location {
    private let _coordinate: CLLocationCoordinate2D
    private let _street: String
    private let _city: String
    
    var coordinate: CLLocationCoordinate2D {
        return _coordinate
    }
    
    var street: String {
        return _street
    }
    
    var city: String {
        return _city
    }
    
    var latitude: String {
        return String(_coordinate.latitude)
    }
    
    var longitude: String {
        return String(_coordinate.longitude)
    }
    
    init(coordinate: CLLocationCoordinate2D, street: String = "", city: String = "") {
        _coordinate = coordinate
        _street = street
        _city = city
    }
}
