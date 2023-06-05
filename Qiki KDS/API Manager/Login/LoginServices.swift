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
        
        let apiRequest = ApiRequest(url: "https://www.services.qiki.com.au/api/auth",
                                    params: ["username" : username,
                                             "password" : password,
                                             "app_version": appVersion,
                                             "device_uuid": deviceUUID,
                                             "device_name": deviceName],
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
    
    //MARK: This function is called to get base URL from the server.
    func getBaseURL(appVersion: String, completion: @escaping (Result<UpdateAppVersionResponse, Error>) -> ()) {
        Logs.writeLog(onDate: Helper.getCurrentDateAndTime(), andDescription: "Update Version Number API called.")
        
        let apiRequest = ApiRequest(url: "https://www.services.qiki.com.au/api/update_app_version",
                                    params: ["app_version" : appVersion,
                                             "api_key" : UserDefaults.token?.apiKey ?? "",
                                             "device_uuid": deviceUUID,
                                             "is_temrinal_app" : 0],
                                    method: .post)
        WebService.shared.request(request: apiRequest) { (result: Result<UpdateAppVersionResponse, Error>) in
            switch result {
                case .failure(let err):
                    completion(.failure(err))
                case .success(let resp):
                    completion(.success(resp))
            }
        }
    }
}
