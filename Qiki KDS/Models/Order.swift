//
//  Order.swift
//  Qiki Cusine
//
//  Created by Miamedia Developer on 8/2/21.
//

import Foundation

struct Order: Codable {
    var orderNo: Int
    var terminalOrderNo: Int
    var sequenceNo: Int
    var deliveryType: DeliveryType
    var tableNo: String?
    var tabNumber: Int?
    var tabName: String?
    var pickupTime: Int?
    var products: [Product]
    var customerName: String
    var deletedProducts: [Product]?
    var orderIdentifier: String
    var isUrgent: Int
    var orderOrigin: Int
    var dateAdded: String?
    var dateUpdated: String?
    
    enum CodingKeys: String, CodingKey {
        case orderNo
        case terminalOrderNo
        case sequenceNo = "seq_no"
        case deliveryType
        case tableNo
        case tabNumber
        case tabName
        case pickupTime
        case products
        case customerName
        case deletedProducts
        case orderIdentifier = "unique_id"
        case isUrgent = "is_urgent"
        case orderOrigin
        case dateAdded
        case dateUpdated
    }
}

enum DeliveryType: String, Codable {
    case pickup = "Pickup"
    case delivery = "Delivery"
    case dineIn = "Dine In"
}

