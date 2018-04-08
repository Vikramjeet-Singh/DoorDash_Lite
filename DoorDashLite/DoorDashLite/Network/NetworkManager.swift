//
//  NetworkManager.swift
//  DoorDashLite
//
//  Created by Vikramjeet Singh on 4/7/18.
//  Copyright © 2018 Vikramjeet Singh. All rights reserved.
//

import Foundation

// MARK: - Result

enum Result<T> {
    case success(T)
    case failure(Error)
}

// MARK: - Network Manager
final class NetworkManager {
    
    // MARK: - Public Properties
    static let shared = NetworkManager(withSession: URLSession.shared)
    
    // MARK: - Private properties
    
    private let session: URLSession
    private var reachability = Reachability.forInternetConnection()!
    private var isNetworkAvailable: Bool {
        return reachability.currentReachabilityStatus().rawValue != 0
    }
    
    // MARK: - Initialzer
    
    private init(withSession session: URLSession) {
        self.session = session
        reachability.startNotifier()
    }
    
    deinit {
        reachability.stopNotifier()
    }
}

// MARK: - Public methods
extension NetworkManager {
    typealias ResultBlock<T> = (Result<T>) -> Void
    
    static func startObservingReachability(_ observer: AnyObject, callback: @escaping (Bool) -> Void) {
        NotificationCenter.default.addObserver(forName: .reachabilityChanged,
                                               object: nil,
                                               queue: OperationQueue.main,
                                               using: { notification in
                                                    callback(NetworkManager.shared.isNetworkAvailable)
                                                })
    }
    
    static func stopObservingReachability(_ observer: AnyObject) {
        NotificationCenter.default.removeObserver(observer, name: .reachabilityChanged, object: nil)
    }

    static func fetchNearbyRestaurants(resource: Resource<[Restaurant]>, completion completionHandler: ResultBlock<[Restaurant]>? = nil) {
        NetworkManager.shared.fetchNearbyRestaurants(resource: resource, completion: completionHandler)
    }
    
    static func fetch<T>(resource: Resource<T>, completion: ResultBlock<T>? = nil) {
        NetworkManager.shared.fetch(resource: resource, completion: completion)
    }
    
    static func cancelAllPendingRequests() {
        NetworkManager.shared.session.getAllTasks { (tasks) in
            // Cancel all outstanding tasks
            tasks.forEach({ task in
                if task.state != .canceling || task.state != .completed {
                    task.cancel()
                }
            })
        }
    }
}

// MARK: - Private methods
private extension NetworkManager {
    
    func fetchNearbyRestaurants(resource: Resource<[Restaurant]>, completion completionHandler: ResultBlock<[Restaurant]>? = nil) {
        self.fetch(resource: resource, completion: completionHandler)
    }
    
    func fetch<T>(resource: Resource<T>, completion: ResultBlock<T>? = nil) {
        if (isNetworkAvailable) {
            guard let url = resource.url else { return (completion?(.failure(DoorDashError.invalidURL)))! }
            
            // Create request object (mainly useful in case of POST request)
            var request = URLRequest(url: url)
            request.httpMethod = resource.methodType
            request.httpBody = resource.data
            
            // Start request
            session.dataTask(with: request, completionHandler: { (data, response, error) in
                completion?(resource.parseData(data, error))
            }).resume()
        } else {
            completion?(.failure(DoorDashError.offline))
        }
    }
}
