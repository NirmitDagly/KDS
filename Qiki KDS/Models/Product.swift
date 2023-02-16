//
//  Product.swift
//  Qiki Cusine
//
//  Created by Miamedia Developer on 8/2/21.
//

import Foundation

struct Product: Codable {
    var name: String
    var qty: Int
    var price: String
    var id, dietary: String
    var docketType: [String]
    var addedProductID: Int?
    
    var attributes: [AttributeValue]?
    var isDeleted: Int
    var isDelivered: Int?

    enum CodingKeys: String, CodingKey {
        case name, qty, price, id, dietary, addedProductID
        case docketType = "docketTypes"
        case attributes
        case isDeleted
        case isDelivered = "is_delivered"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try container.decodeIfPresent(String.self, forKey: .name) ?? ""
        self.qty = try container.decodeIfPresent(Int.self, forKey: .qty) ?? 0
        self.price = try container.decodeIfPresent(String.self, forKey: .price) ?? "0.00"
        self.id = try container.decodeIfPresent(String.self, forKey: .id) ?? "0"
        self.dietary = try container.decodeIfPresent(String.self, forKey: .dietary) ?? "--"
        self.docketType = try container.decodeIfPresent([String].self, forKey: .docketType) ?? [String]()
        self.addedProductID = try container.decodeIfPresent(Int.self, forKey: .addedProductID) ?? 0
        self.attributes = try container.decodeIfPresent([AttributeValue].self, forKey: .attributes) ?? [AttributeValue]()
        self.isDeleted = try container.decodeIfPresent(Int.self, forKey: .isDeleted) ?? 0
        self.isDelivered = try container.decodeIfPresent(Int.self, forKey: .isDelivered) ?? 0
    }
}

extension Product {
    init(from name: String, qty: Int, price: String, id: String, dietary: String, docketType: [String], addedProductID: Int, isDeleted: Int, isDelivered: Int) {
        self.name = name
        self.qty = qty
        self.price = price
        self.id = id
        self.dietary = dietary
        self.docketType = docketType
        self.addedProductID = addedProductID
        self.isDeleted = isDeleted
        self.isDelivered = isDelivered
    }
}

extension Product: Equatable {
    static func ==(lhs: Product, rhs: Product) -> Bool {
        // Using "identifier" property for comparison
        return lhs.id == rhs.id && lhs.name == rhs.name && lhs.qty == rhs.qty && lhs.price == rhs.price && lhs.dietary == rhs.dietary && lhs.docketType == rhs.docketType && lhs.addedProductID == rhs.addedProductID && lhs.isDeleted == rhs.isDeleted && lhs.isDelivered == rhs.isDelivered
    }
}
