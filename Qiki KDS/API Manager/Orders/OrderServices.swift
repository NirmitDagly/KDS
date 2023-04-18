//
//  OrderServices.swift
//  Qiki KDS
//
//  Created by Nirmit Dagly on 6/12/2022.
//

import Foundation

struct OrderServices {
    static let shared = OrderServices()
    var baseURL: String {UserDefaults.token?.qikiSite ?? ""}

    func getActiveOrders(orderStatus: String, completion: @escaping (Result<GetOrdersResponse, Error>) -> ()) {
        let apiRequest = ApiRequest(url: "\(baseURL)/get_kds_orders",
                                    params: ["orderStatus" : orderStatus,
                                             "device_uuid": deviceUUID,
                                             "device_name": deviceName],
                                    method: .post)
        Logs.writeLog(onDate: Helper.getCurrentDateAndTime(), andDescription: "Get Active Orders API called with \(apiRequest).")
        
        WebService.shared.requestWithJSON(request: apiRequest) { (result: Result<GetOrdersResponse, Error>) in
            switch result {
                case .failure(let error):
                    completion(.failure(error))
                case .success(let resp):
                    completion(.success(resp))
            }
        }
    }
    
    func getHistoryOrders(orderStatus: String, completion: @escaping (Result<GetOrdersResponse, Error>) -> ()) {
        let apiRequest = ApiRequest(url: "\(baseURL)/get_kds_orders",
                                    params: ["orderStatus" : orderStatus,
                                             "date": Helper.getCurrentDateOnly(),
                                             "device_uuid": deviceUUID,
                                             "device_name": deviceName,
                                             "dockets": selectedSections],
                                    method: .post)
        Logs.writeLog(onDate: Helper.getCurrentDateAndTime(), andDescription: "Get History Orders API called \(apiRequest).")

        WebService.shared.requestWithJSON(request: apiRequest) { (result: Result<GetOrdersResponse, Error>) in
            switch result {
                case .failure(let error):
                    completion(.failure(error))
                case .success(let resp):
                    completion(.success(resp))
            }
        }
    }
    
    func markOrderAsCompleted(forOrderNumber orderNo: Int, andSequenceNo seqNo: Int, forAddedProductIDs addedProductIDs: [Int], completion: @escaping (Result<GeneralResponse, Error>) -> ()) {
        let apiRequest = ApiRequest(url: "\(baseURL)/mark_kds_items_delivered",
                                    params: ["id_order": orderNo,
                                             "seq_no": seqNo,
                                             "added_product_ids": addedProductIDs,
                                             "sections_completed": selectedSections,
                                             "device_uuid": deviceUUID,
                                             "device_name": deviceName],
                                    method: .post)
        Logs.writeLog(onDate: Helper.getCurrentDateAndTime(), andDescription: "Mark Order As Completed API called \(apiRequest).")
        
        WebService.shared.requestWithJSON(request: apiRequest) { (result: Result<GeneralResponse, Error>) in
            switch result {
                case .failure(let error):
                    completion(.failure(error))
                case .success(let resp):
                    completion(.success(resp))
            }
        }
    }
    
    func markOrderAsActive(forOrderNumber orderNo: Int, andSequenceNo seqNo: Int, withProductSections productSections: [String], completion: @escaping (Result<GeneralResponse, Error>) -> ()) {
        let apiRequest = ApiRequest(url: "\(baseURL)/mark_kds_as_active",
                                    params: ["id_order": orderNo,
                                             "seq_no": seqNo,
                                             "device_uuid": deviceUUID,
                                             "device_name": deviceName,
                                             "dockets": productSections],
                                    method: .post)
        Logs.writeLog(onDate: Helper.getCurrentDateAndTime(), andDescription: "Mark Order As Active API called \(apiRequest).")

        WebService.shared.requestWithJSON(request: apiRequest) { (result: Result<GeneralResponse, Error>) in
            switch result {
                case .failure(let error):
                    completion(.failure(error))
                case .success(let resp):
                    completion(.success(resp))
            }
        }
    }
    
    func markOrderAsUrgent(forOrderNumber orderNo: Int, andSequenceNo seqNo: Int, completion: @escaping (Result<GeneralResponse, Error>) -> ()) {
        let apiRequest = ApiRequest(url: "\(baseURL)/mark_kds_as_urgent",
                                    params: ["id_order": orderNo,
                                             "seq_no": seqNo,
                                             "device_uuid": deviceUUID,
                                             "device_name": deviceName],
                                    method: .post)
        Logs.writeLog(onDate: Helper.getCurrentDateAndTime(), andDescription: "Mark Order As Urgent API called \(apiRequest).")
        
        WebService.shared.request(request: apiRequest) { (result: Result<GeneralResponse, Error>) in
            switch result {
                case .failure(let error):
                    completion(.failure(error))
                case .success(let resp):
                    completion(.success(resp))
            }
        }
    }
    
    func markItemAsDelivered(forOrderNumber orderNo: Int, andSequenceNo seqNo: Int, forAddedProductID addedProductID: Int, andHasSection section: String, andIsDelivered isDelivered: Int, completion: @escaping(Result<GeneralResponse, Error>) -> ()) {
        let apiRequest = ApiRequest(url: "\(baseURL)/mark_individual_item_delivered",
                                    params: ["id_order": orderNo,
                                             "added_product_id": addedProductID,
                                             "section": section,
                                             "seq_no": seqNo,
                                             "is_delivered": isDelivered,
                                             "device_uuid": deviceUUID,
                                             "device_name": deviceName],
                                    method: .post)
        Logs.writeLog(onDate: Helper.getCurrentDateAndTime(), andDescription: "Mark Item As Delivered API called \(apiRequest).")

        WebService.shared.request(request: apiRequest) { (result: Result<GeneralResponse, Error>) in
            switch result {
                case .failure(let error):
                    completion(.failure(error))
                case .success(let resp):
                    completion(.success(resp))
            }
        }
    }
}
