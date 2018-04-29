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
    let menu: [MenuItem]
    
    private var _isFavorite: Bool = false
    
    private enum CodingKeys: String, CodingKey {
        case thumbnail = "cover_img_url"
        case deliveryFee = "delivery_fee"
        case statusType = "status_type"
        case waitTime = "asap_time"
        case menu = "menus"
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
        menu = try values.decode([MenuItem].self, forKey: .menu)
        
    }
    
    mutating func setImage(_ img: UIImage) {
        self.image = img
    }
    
    var isFavorite: Bool {
        get {
            return _isFavorite
        }
        mutating set {
            self._isFavorite = newValue
        }
    }
}

extension Restaurant {
    // Restaurant Description (id and name)
    struct Business: Codable {
        var name: String
    }
    
    // Menu Items
    struct MenuItem: Codable {
        struct PopularItem: Codable {
            let price: Int
            let description: String?
            let id: Int
            let name: String
            let imgURLStr: String?
            
            enum CodingKeys: String, CodingKey {
                case price
                case description
                case id
                case name
                case imgURLStr = "img_url"
            }
        }
        
        let popularItems: [PopularItem]
        let name: String
        let id: Int
        
        enum CodingKeys: String, CodingKey {
            case popularItems = "popular_items"
            case name
            case id
        }
    }
}

extension Restaurant {
    private static var _favorites: [Int: Restaurant] = [:]
    
    static var favorites: [Restaurant] {
        return Array(Restaurant._favorites.values)
    }
    
    static func addFavorite(_ restaurant: Restaurant) {
        Restaurant._favorites[restaurant.id] = restaurant
    }
    
    static func removeFavorite(_ restaurant: Restaurant) {
        Restaurant._favorites[restaurant.id] = nil
    }
    
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
