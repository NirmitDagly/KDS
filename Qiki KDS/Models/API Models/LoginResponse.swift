//
//  LoginResponse.swift
//  Qiki Cusine
//
//  Created by Miamedia Developer on 8/2/21.
//

import Foundation

protocol ApiResponse: Decodable {
    var success: Int { get set }
    var message: String { get set }
}

// MARK: - LoginResponse
struct LoginResponse: ApiResponse {
    var success: Int
    var message: String
    let authenticated: Bool
    var data: Token?
}

// MARK: - DataClass
struct Token: Codable {
    var username, apiKey: String
    var qikiSite: String
    var orgID: String?


    enum CodingKeys: String, CodingKey {
        case username
        case apiKey = "api_key"
        case qikiSite = "qiki_site"
        case orgID = "reservation_orgid"
    }
}
