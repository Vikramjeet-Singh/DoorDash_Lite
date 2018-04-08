//
//  DoorDashError.swift
//  DoorDashLite
//
//  Created by Vikramjeet Singh on 4/7/18.
//  Copyright © 2018 Vikramjeet Singh. All rights reserved.
//

import Foundation

enum DoorDashError: Error {
    case internalError(Error?)
    case invalidURL
    case offline
    case other(Error)
}

extension DoorDashError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .internalError(_):
            return NSLocalizedString("Internal Error occurred. Please try again later.", comment: "")
        case .invalidURL:
            return NSLocalizedString("Invalid URL. Please check the URL and try again later.", comment: "")
        case .offline:
            return NSLocalizedString("Your internet connection seems to be offline.", comment: "")
        case .other(let e):
            return e.localizedDescription
        }
    }
}
