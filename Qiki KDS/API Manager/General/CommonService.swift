//
//  CommonService.swift
//  Qiki KDS
//
//  Created by Nirmit Dagly on 30/11/2022.
//

import Foundation

struct CommonService {
    static let shared = CommonService()
    var baseURL: String {UserDefaults.token?.qikiSite ?? ""}
    
    //MARK: This function is called to register device token on server.
    func registerDevice(username: String, deviceToken: String, completion: @escaping (Result<GetDeviceRegistrationResponse, Error>) -> ()) {
        Logs.writeLog(onDate: Helper.getCurrentDateAndTime(), andDescription: "Register Device API called.")
        
        let apiRequest = ApiRequest(url: "\(baseURL)/register_device",
                                    params: ["username": username,
                                                "device_token": deviceToken,
                                                "device_uuid": deviceUUID,
                                                "device_name": deviceName,
                                                "device_model": deviceModel,
                                                "device_os": deviceSystemVersion,
                                                "app_version": versionNumber!,
                                                "app_build": buildNumber!],
                                    method: .post)
        WebService.shared.request(request: apiRequest, completion: completion)
    }
        
    //MARK: This function is called to get basic details of store.
    func getStoreDetails(completion: @escaping (Result<GetStoreDetailsResponse, Error>) -> ()) {
        Logs.writeLog(onDate: Helper.getCurrentDateAndTime(), andDescription: "Get Store Details API called.")
        
        let apiRequest = ApiRequest(url: "\(baseURL)/get_store_details",
                                    params: ["device_uuid": deviceUUID,
                                                "device_name": deviceName,
                                                "app_version": versionNumber!,
                                                "app_build": buildNumber!], method: .post)
        WebService.shared.request(request: apiRequest) { (result: Result<GetStoreDetailsResponse, Error>) in
            switch result {
                case .failure(let err):
                    completion(.failure(err))
                case .success(let resp):
                    completion(.success(resp))
            }
        }
    }
        
    //MARK: This function is called to get the available docket sections.
    func getDocketSections(completion: @escaping (Result<GetDocketResponse, Error>) -> ()) {
        Logs.writeLog(onDate: Helper.getCurrentDateAndTime(), andDescription: "Get Docket Section API called.")
        
        let apiRequest = ApiRequest(url: "\(baseURL)/get_dockets",
                                    params: ["device_uuid": deviceUUID,
                                             "device_name": deviceName], method: .post)
        WebService.shared.request(request: apiRequest) { (result: Result<GetDocketResponse, Error>) in
            switch result {
                case .failure(let err):
                    completion(.failure(err))
                case .success(let resp):
                    completion(.success(resp))
            }
        }
    }
}
