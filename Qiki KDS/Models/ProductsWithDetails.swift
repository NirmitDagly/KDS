//
//  ProductsWithDetails.swift
//  Qiki Cusine
//
//  Created by Miamedia Developer on 16/3/21.
//

import Foundation

// MARK: - Product
struct ProductsWithDetails: Codable {
    let idProduct, name, price, productDescription, linkRewrite: String
    let imagePath: String
    let docketType: [String]
    let attributesGroups: [AttributesGroup]?
    var inStock: Int?
    let takeAwayPrice: String?
    let dineInPrice: String?
    let deliveryPrice: String?
    let barcode: String

    enum CodingKeys: String, CodingKey {
        case idProduct = "id_product"
        case name, price
        case docketType = "docketTypes"
        case productDescription = "description"
        case linkRewrite = "link_rewrite"
        case imagePath = "image_path"
        case attributesGroups = "attributes_groups"
        case inStock = "in_stock"
        case takeAwayPrice = "takeaway_price"
        case dineInPrice = "dinein_price"
        case deliveryPrice = "delivery_price"
        case barcode
    }
}

enum AttributesGroups: Codable {
    case attributesGroupArray([AttributesGroup])
    case attributesGroupMap([String: AttributesGroup])

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let x = try? container.decode([AttributesGroup].self) {
            self = .attributesGroupArray(x)
            return
        }
        if let x = try? container.decode([String: AttributesGroup].self) {
            self = .attributesGroupMap(x)
            return
        }
        throw DecodingError.typeMismatch(AttributesGroups.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for AttributesGroups"))
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .attributesGroupArray(let x):
            try container.encode(x)
        case .attributesGroupMap(let x):
            try container.encode(x)
        }
    }
}

// MARK: - AttributesGroup
struct AttributesGroup: Codable {
    let idAttributeGroup: String
    let showName, isMandatory: Int
    let name, publicName: String
    let attributeValues: [AttributeValue]

    enum CodingKeys: String, CodingKey {
        case idAttributeGroup = "id_attribute_group"
        case showName = "show_name"
        case isMandatory = "is_mandatory"
        case name
        case publicName = "public_name"
        case attributeValues = "attribute_values"
    }
}

// MARK: - AttributeValue
struct AttributeValue: Codable {
    let idAttribute, name, price: String
    let position: String?
    
    enum CodingKeys: String, CodingKey {
        case idAttribute = "id_attribute"
        case name, position, price
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.idAttribute = try container.decodeIfPresent(String.self, forKey: .idAttribute) ?? ""
        self.name = try container.decodeIfPresent(String.self, forKey: .name) ?? "--"
        self.position = try container.decodeIfPresent(String.self, forKey: .position) ?? ""
        self.price = try container.decodeIfPresent(String.self, forKey: .price) ?? "0.00"
    }
}


