//
//  APIRequest.swift
//  Qiki Cusine
//
//  Created by Miamedia Developer on 8/2/21.
//

import Foundation
import Alamofire

struct ApiRequest {
    let url: String
    let params: Parameters
    let method: HTTPMethod
}
