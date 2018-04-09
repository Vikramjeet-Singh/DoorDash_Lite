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
    
    /**
     Method to start observing for Reachability
     - parameters
     observer: Observer to start listening for Reachability change notifications
     callback: callback method with boolean argument indicating whether network is available or not
     */
    static func startObservingReachability(_ observer: AnyObject, callback: @escaping (Bool) -> Void) {
        NotificationCenter.default.addObserver(forName: .reachabilityChanged,
                                               object: nil,
                                               queue: OperationQueue.main,
                                               using: { notification in
                                                    callback(NetworkManager.shared.isNetworkAvailable)
                                                })
    }
    
    /**
     Method to stop observing for Reachability
     - parameters
     observer: Observer to stop listening for Reachability change notifications
     */
    static func stopObservingReachability(_ observer: AnyObject) {
        NotificationCenter.default.removeObserver(observer, name: .reachabilityChanged, object: nil)
    }

    /**
     Method to fetch the resource
     - parameters
     resource: Resource struct that includes the url to fetch
     callback: callback method with Result enum as the parameter
     */
    static func fetch<T>(resource: Resource<T>, completionHandler: ResultBlock<T>? = nil) {
        NetworkManager.shared.fetch(resource: resource, completion: completionHandler)
    }
    
    /**
     Method to cancel all the outstanding/pending requests for the session
     */
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
