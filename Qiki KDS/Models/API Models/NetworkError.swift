//
//  NetworkError.swift
//  Qiki Cusine
//
//  Created by Miamedia Developer on 8/2/21.
//

import Foundation

enum NetworkError: Error, LocalizedError {
    
    case notSuccessful(String)

    var errorDescription: String? {
            switch self {
            case .notSuccessful(let msg):
                return msg
            }
        }
    
}
