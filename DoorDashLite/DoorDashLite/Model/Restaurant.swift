//
//  Restaurant.swift
//  DoorDashLite
//
//  Created by Vikramjeet Singh on 4/7/18.
//  Copyright © 2018 Vikramjeet Singh. All rights reserved.
//

import Foundation

struct Restaurant: Codable {
    private let business: Business
    private(set) var image: UIImage?
    
    let id: Int
    let name: String
    let thumbnail: String
    let description: String
    let deliveryFee: Int
    let status: String
    let statusType: String
    let waitTime: Int?
    
    private enum CodingKeys: String, CodingKey {
        case thumbnail = "cover_img_url"
        case deliveryFee = "delivery_fee"
        case statusType = "status_type"
        case waitTime = "asap_time"
        case business = "business"
        case id
        case name
        case description
        case status
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try values.decode(Int.self, forKey: .id)
        business = try values.decode(Business.self, forKey: .business)
        name = try values.decode(String.self, forKey: .name)
        thumbnail = try values.decode(String.self, forKey: .thumbnail)
        description = try values.decode(String.self, forKey: .description)
        deliveryFee = try values.decode(Int.self, forKey: .deliveryFee)
        status = try values.decode(String.self, forKey: .status)
        statusType = try values.decode(String.self, forKey: .statusType)
        waitTime = try values.decode(Int?.self, forKey: .waitTime)
    }
    
    mutating func setImage(_ img: UIImage) {
        self.image = img
    }
}

extension Restaurant {
    // Restaurant Description (id and name)
    struct Business: Codable {
        var name: String
    }
}

extension Restaurant {
    static func fetchNearbyRestaurants(location: Location, completion: @escaping (Result<[Restaurant]>) -> Void) {
        // Create restaurant list resource
        let listResource: Resource<[Restaurant]> = Resource(endpoint: .nearby(latitude: location.latitude, longitude: location.longitude),
                                                            method: .get,
                                                            parseBlock: { (data, error) in
                                                                // If server returned an error then wrap it with custom error
                                                                guard let data = data else {
                                                                    return .failure(DoorDashError.other(error!))
                                                                }
                                                                
                                                                do {
                                                                    let decoder = JSONDecoder()
                                                                    let restaurants = try decoder.decode([Restaurant].self, from: data)
                                                                    print(restaurants.count)
                                                                    return .success(restaurants)
                                                                } catch (let error) {
                                                                    // If decoding error, then return internal error
                                                                    return .failure(DoorDashError.internalError(error))
                                                                }
                                                                
        })
        
        // load restaurant list
        NetworkManager.fetch(resource: listResource, completionHandler: { result in
            completion(result)
        })
    }
}
