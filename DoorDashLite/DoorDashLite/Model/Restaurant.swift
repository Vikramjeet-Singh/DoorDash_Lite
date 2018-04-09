//
//  Restaurant.swift
//  DoorDashLite
//
//  Created by Vikramjeet Singh on 4/7/18.
//  Copyright © 2018 Vikramjeet Singh. All rights reserved.
//

import Foundation

struct Restaurant: Codable {
    let name: String
    let thumbnail: String
    let description: String
    let deliveryFee: Int
    let status: String
    let statusType: String
    let waitTime: Int?
    
    init(from decoder: Decoder) throws {
        let rawResponse = try RawServerResponse(from: decoder)
        
        name = rawResponse.business.name
        thumbnail = rawResponse.thumbnail
        description = rawResponse.description
        deliveryFee = rawResponse.deliveryFee
        status = rawResponse.status
        statusType = rawResponse.statusType
        waitTime = rawResponse.wait
    }
}
