    //
    //  LoginServices.swift
    //  Qiki KDS
    //
    //  Created by Nirmit Dagly on 29/11/2022.
    //

import Foundation

struct LoginService {
    static let shared = LoginService()
    
    func login(username: String, password: String, appVersion: String, completion: @escaping (Result<LoginResponse, Error>) -> ()) {
        Logs.writeLog(onDate: Helper.getCurrentDateAndTime(), andDescription: "Login API called.")
        
        let apiRequest = ApiRequest(url: "https://crm.qiki.com.au/Services/Auth",
                                    params: ["username" : username,
                                             "password" : password,
                                             "app_version": appVersion,
                                             "device_uuid": deviceUUID,
                                             "device_name": deviceName,
                                             "app_identification": DeviceIdentification.DDS.rawValue],
                                    method: .post)
        WebService.shared.request(request: apiRequest) { (result: Result<LoginResponse, Error>) in
            switch result {
                case .failure(let err):
                    completion(.failure(err))
                case .success(let resp):
                    UserDefaults.token = resp.data
                    UserDefaults.isLoggedIn = true
                    completion(.success(resp))
            }
        }
    }
}
