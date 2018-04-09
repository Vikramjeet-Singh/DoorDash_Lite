//
//  Resource.swift
//  DoorDashLite
//
//  Created by Vikramjeet Singh on 4/7/18.
//  Copyright © 2018 Vikramjeet Singh. All rights reserved.
//

import Foundation

// MARK: - Resource

struct Resource<T> {
    let endpoint: RequestEndpoint
    let method: RequestMethod
    let parseData: (Data?, Error?) -> Result<T>
    
    init(endpoint: RequestEndpoint,
         method: RequestMethod,
         parseBlock: @escaping (Data?, Error?) -> Result<T>)
    {
        self.endpoint = endpoint
        self.method = method
        self.parseData = parseBlock
    }
    
    var url: URL? {
        return self.endpoint.url
    }
    
    var methodType: String {
        return self.method.method
    }
    
    var data: Data? {
        if case let .post(json) = method {
            let data = try? JSONSerialization.data(withJSONObject: json as Any, options: [])
            return data
        }
        
        return nil
    }
}

// MARK: - Request Method

enum RequestMethod {
    case get
    case post(data: [String : Any]?)
    
    fileprivate var method: String {
        switch self {
        case .get:
            return "GET"
        case .post:
            return "POST"
        }
    }
}

// MARK: - RequestEndpoint

enum RequestEndpoint {
    case base
    case nearby(latitude: String, longitude: String)
    case custom(withString: String)
    
    // MARK: - Private Endpoint properties
    private var baseURLStr: String {
        return "https://api.doordash.com/"
    }
    
    // MARK: - Public Endpoint properties
    var url: URL? {
        switch self {
        case .base:
            return URL(string: baseURLStr)
        case .nearby(let latitude, let longitude):
            return URL(string: baseURLStr + "v1/store_search/?lat=\(latitude)&lng=\(longitude)")
        case .custom(let urlStr):
            return URL(string: urlStr)
        }
    }
}
