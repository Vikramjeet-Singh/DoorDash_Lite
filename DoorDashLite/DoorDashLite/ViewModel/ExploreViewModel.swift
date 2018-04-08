//
//  ExploreViewModel.swift
//  DoorDashLite
//
//  Created by Vikramjeet Singh on 4/7/18.
//  Copyright © 2018 Vikramjeet Singh. All rights reserved.
//

import Foundation

protocol Listener {
    func didUpdate(_ error: Error?)
}

class ExploreViewModel {
    
    // MARK: - Private properties
    private var restaurants: [Restaurant] = [] {
        didSet {
            self.listener.didUpdate(nil)
        }
    }
    
    private let listener: Listener
    private var imageCache = Cache<UIImage>()
    
    // MARK: - Initializer
    
    init(location: Location, listener: Listener) {
        self.listener = listener
        fetchNearbyRestaurants(for: location)
    }
    
    // MARK: - Public methods
    func fetchNearbyRestaurants(for location: Location) {
        // Create restaurant list resource
        let restaurantListResource: Resource<[Restaurant]> = Resource(endpoint: .nearby(latitude: location.latitude, longitude: location.longitude),
                                                                  method: .get,
                                                                  parseBlock: { (data, error) in
                                                                    // If server returned an error then wrap it with custom error
                                                                    guard let data = data else {
                                                                        return .failure(DoorDashError.other(error!))
                                                                    }
                                                                    
                                                                    do {
                                                                        let decoder = JSONDecoder()
                                                                        let restaurants = try decoder.decode([Restaurant].self, from: data)
                                                                        return .success(restaurants)
                                                                    } catch (let error) {
                                                                        // If decoding error, then return internal error
                                                                        return .failure(DoorDashError.internalError(error))
                                                                    }
                                                        
                                                                })
        
        // load restaurant list
        NetworkManager.fetch(resource: restaurantListResource, completion: { [weak self] result in
            if let weakSelf = self {
                switch result {
                case .success(let restaurants):
                    weakSelf.restaurants = restaurants
                case .failure(let error):
                    print(error.localizedDescription)
                    weakSelf.listener.didUpdate(error)
                }
            }
        })
    }
    
    func getImage(for indexPath: IndexPath, completionHandler: @escaping (UIImage?) -> Void) {
        let imageURLStr = restaurants[indexPath.row].thumbnail
        
        if let image = self.imageCache[imageURLStr] {
            completionHandler(image)
        } else {
            downloadImage(imageURLStr, completion: completionHandler)
        }
    }
    
    func cancelAllPendingRequests() {
        NetworkManager.cancelAllPendingRequests()
    }
    
    func numberOfRowsInSection(_ section: Int) -> Int {
        return restaurants.count
    }
    
    func name(at index: Int) -> String {
        return restaurants[index].name
    }
    
    func type(at index: Int) -> String {
        return restaurants[index].description
    }
    
    func deliveryFee(at index: Int) -> String {
        let priceStr = (restaurants[index].deliveryFee == 0) ? "Free" : "$\(restaurants[index].deliveryFee)"
        return priceStr + NSLocalizedString(" delivery", comment: "")
    }
    
    func waitStatus(at index: Int) -> String {
        return (restaurants[index].statusType == "pre-order") ? NSLocalizedString("Pre-Order", comment: "") : restaurants[index].status
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
        NetworkManager.fetch(resource: imageResource, completion: { [weak self] result in
            switch result {
            case .success(let image):
                if let weakSelf = self {
                    weakSelf.imageCache[urlStr] = image
                    handler(image)
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        })
    }
}
