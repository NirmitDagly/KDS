//
//  GetDocketResponse.swift
//  Qiki Cusine
//
//  Created by Miamedia Developer on 17/2/21.
//

import Foundation

// MARK: - GetDocketResponse
class GetDocketResponse: ApiResponse {    
    var success: Int
    var message: String
    var dockets: [String]
}
