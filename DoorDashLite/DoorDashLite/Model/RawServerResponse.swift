//
//  RawServerResponse.swift
//  DoorDashLite
//
//  Created by Vikramjeet Singh on 4/7/18.
//  Copyright © 2018 Vikramjeet Singh. All rights reserved.
//

import Foundation

// MARK: - RawServerResponse
struct RawServerResponse: Codable {
    
    // Restaurant Description (id and name)
    struct Business: Codable {
        var name: String
    }
    
    private enum CodingKeys: String, CodingKey {
        case deliveryFee = "delivery_fee"
        case business = "business"
        case thumbnail = "cover_img_url"
        case statusType = "status_type"
        case description
        case status
    }
    
    let thumbnail: String
    let description: String
    let deliveryFee: Int
    let status: String
    let statusType: String
    let business: Business
}
