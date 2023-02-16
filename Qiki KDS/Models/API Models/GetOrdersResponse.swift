//
//  GetOrdersResponse.swift
//  Qiki Cusine
//
//  Created by Miamedia Developer on 8/2/21.
//

import Foundation

class GetOrdersResponse: ApiResponse {
    var success: Int
    var message: String
    let orders: [Order]
}
