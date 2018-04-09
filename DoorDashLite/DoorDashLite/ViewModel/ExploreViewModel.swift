//
//  ExploreViewModel.swift
//  DoorDashLite
//
//  Created by Vikramjeet Singh on 4/7/18.
//  Copyright © 2018 Vikramjeet Singh. All rights reserved.
//

import Foundation

class ExploreViewModel {
    
    // MARK: - Private properties
    private var restaurants: [Restaurant] = [] {
        didSet {
            self.callback(nil)
        }
    }
    
    private var imageCache = Cache<UIImage>()
    private var callback: (Error?) -> Void = { _ in }
    
    // MARK: - Initializer
    
    init(location: Location, callback: @escaping (Error?) -> Void) {
        self.callback = callback
        fetchNearbyRestaurants(for: location)
    }
    
    var restaurantCount: Int {
        return restaurants.count
    }
    
    // MARK: - Public methods
    
    /**
     Fetches nearby restaurants for the location
     - parameters location: Location struct that wraps latitude and longitude
     */
    func fetchNearbyRestaurants(for location: Location) {
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
        NetworkManager.fetch(resource: listResource, completionHandler: { [weak self] result in
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
        let imageURLStr = thumbnail(at: indexPath.row)
        
        if let image = self.imageCache[imageURLStr] {
            completionHandler(image)
        } else {
            downloadImage(imageURLStr, completion: completionHandler)
        }
    }
    
    /**
     This method cancels all the pending requests for the session
     */
    func cancelAllPendingRequests() {
        NetworkManager.cancelAllPendingRequests()
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
        let priceStr = (restaurants[index].deliveryFee == 0) ? "Free" : "$\(restaurants[index].deliveryFee)"
        return priceStr + NSLocalizedString(" delivery", comment: "")
    }
    
    /**
     Returns wait status of the Restuarant at index
     - parameters index: Index in the restaurants list
     */
    func waitStatus(at index: Int) -> String {
        return (restaurants[index].statusType == "pre-order") ? NSLocalizedString("Pre-Order", comment: "") : restaurants[index].status
    }
    
    /**
     Returns thumbnail url string of the Restuarant at index
     - parameters index: Index in the restaurants list
     */
    func thumbnail(at index: Int) -> String {
        return restaurants[index].thumbnail
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
        NetworkManager.fetch(resource: imageResource, completionHandler: { [weak self] result in
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
