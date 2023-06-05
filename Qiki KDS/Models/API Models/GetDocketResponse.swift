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
    var dockets: [DocketOptions]
    
    enum CodingKeys: String, CodingKey {
        case success, message
        case dockets = "dockets"
    }
}

struct DocketOptions: Codable {
    var docket: String
    var printingPolicy: PrintingPolicyOptions
    
    enum CodingKeys: String, CodingKey {
        case docket
        case printingPolicy
    }
}

struct PrintingPolicyOptions: Codable {
    var shouldPrintForTakeAway: Int
    var shouldPrintForDineIn: Int
    var shouldPrintForDelivery: Int
    
    enum CodingKeys: String, CodingKey {
        case shouldPrintForTakeAway = "takeaway"
        case shouldPrintForDineIn = "dinein"
        case shouldPrintForDelivery = "delivery"
    }
}
