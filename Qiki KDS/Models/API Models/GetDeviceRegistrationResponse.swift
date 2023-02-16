//
//  GetDeviceRegistrationResponse.swift
//  Qiki Cusine
//
//  Created by Nirmit Dagly on 5/7/2022.
//

import Foundation

struct GetDeviceRegistrationResponse: ApiResponse {
    var success: Int
    var message: String
    var deviceID: Int
    
    enum CodingKeys: String, CodingKey {
        case success, message
        case deviceID = "device_id"
    }
}
