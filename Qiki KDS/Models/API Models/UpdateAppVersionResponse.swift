//
//  UpdateAppVersionResponse.swift
//  Qiki Cusine
//
//  Created by Miamedia Developer on 10/6/21.
//

import Foundation

// MARK: - Update App Version Response
struct UpdateAppVersionResponse: ApiResponse {
    var success: Int
    var message: String
    var qikiSite: String
    
    enum CodingKeys: String, CodingKey {
        case success, message
        case qikiSite = "qiki_site"
    }
}
