//
//  StoreDetails.swift
//  Qiki Cusine
//
//  Created by Miamedia Developer on 8/4/21.
//

import Foundation

// MARK: - StoreDetailsClass
struct StoreDetails: Codable {
    let shopName, logoURL, address, phone: String
    let reg: String
    let openingHours: String?
    let closingHours: String?
    
    enum CodingKeys: String, CodingKey {
        case shopName = "shop_name"
        case logoURL = "logo_url"
        case address, phone, reg
        case openingHours = "opening_hours"
        case closingHours = "closing_hours"
    }
}
