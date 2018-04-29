//
//  ExploreViewModel.swift
//  DoorDashLite
//
//  Created by Vikramjeet Singh on 4/7/18.
//  Copyright © 2018 Vikramjeet Singh. All rights reserved.
//

import Foundation

class ExploreViewModel: RestaurantViewModel {
    
    // MARK: - Private properties
    private(set) var restaurants: [Restaurant] = [] {
        didSet {
            self.callback(nil)
        }
    }
    
    private var callback: (Error?) -> Void = { _ in }
    
    // MARK: - Initializer
    
    init(location: Location, callback: @escaping (Error?) -> Void) {
        self.callback = callback
        fetchNearbyRestaurants(for: location)
    }
    
    // MARK: - Public methods
    
    /**
     Fetches nearby restaurants for the location
     - parameters location: Location struct that wraps latitude and longitude
     */
    func fetchNearbyRestaurants(for location: Location) {
        Restaurant.fetchNearbyRestaurants(location: location, completion: { [weak self] result in
            if let weakSelf = self {
                switch result {
                case .success(let restaurants):
                    weakSelf.restaurants = restaurants
                case .failure(let error):
                    print(error.localizedDescription)
                    weakSelf.callback(error)
                }
            }
        })
    }
    
    /**
     This method calls the completion handler with the image if it is cached,
     otherwise it fetches the image, updates the cache and then calls the completion handler
     
     - parameters
     indexPath: IndexPath for cell
     completionHandler: completion handler to be called with the image
     */
    func getImage(for indexPath: IndexPath, completionHandler: @escaping (UIImage?) -> Void) {
        if let image = restaurants[indexPath.row].image {
            completionHandler(image)
        } else {
            downloadImage(restaurants[indexPath.row].thumbnail, completion: { image in
                self.restaurants[indexPath.row].setImage(image!)
                completionHandler(image)
            })
        }
    }
    
    func update(_ rest: Restaurant, at index: Int) {
        self.restaurants[index] = rest
    }
}

// MARK: - Private methods
private extension ExploreViewModel {
    func downloadImage(_ urlStr: String, completion handler: @escaping (UIImage?) -> Void) {
        // Create image resource
        let imageResource: Resource<UIImage?> = Resource(endpoint: .custom(withString: urlStr),
                                                         method: .get,
                                                         parseBlock: { (data, error) in
                                                            // If server returned an error then wrap it with custom error
                                                            guard let data = data else {
                                                                return .failure(DoorDashError.other(error!))
                                                            }
                                                            
                                                            return .success(UIImage(data: data))
        })
        
        // Download image
        NetworkManager.fetch(resource: imageResource, completionHandler: { result in
            switch result {
            case .success(let image):
                handler(image)
            case .failure(let error):
                print(error.localizedDescription)
            }
        })
    }
}
