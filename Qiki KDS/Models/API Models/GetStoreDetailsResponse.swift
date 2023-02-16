//
//  GetStoreDetailsResponse.swift
//  Qiki Cusine
//
//  Created by Miamedia Developer on 8/4/21.
//

import Foundation

class GetStoreDetailsResponse: ApiResponse {
    var success: Int
    var message: String
    let storeDetails: StoreDetails?
    let isMainTerminal: Int?
    let deviceID: Int?
    let apiVersion: String?
    let mainTerminalUUID: String?
        
    enum CodingKeys: String, CodingKey {
        case success, message
        case storeDetails
        case isMainTerminal
        case deviceID = "device_id"
        case apiVersion = "api_version"
        case mainTerminalUUID
    }
}
