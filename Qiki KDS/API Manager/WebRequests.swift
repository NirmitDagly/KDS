//
//  WebRequests.swift
//  Qiki KDS
//
//  Created by Nirmit Dagly on 29/11/2022.
//

import Foundation
import Alamofire

struct WebService {
    
    static let shared = WebService()
    var apiKey: String { UserDefaults.token?.apiKey ?? "" }
    
    // MARK: - Private functions
    //Create Request method for all APIs
    func request<T: ApiResponse>(request: ApiRequest, completion: @escaping (Result<T, Error>) -> ()) {
        AF.request(request.url, method: request.method, parameters: request.params, headers: ["Authorization": "Basic " + apiKey], requestModifier: {$0.timeoutInterval = 300}).validate(statusCode: 200..<300).responseData { respData in
            if let error = respData.error {
                Logs.writeLog(onDate: Helper.getCurrentDateAndTime(), andDescription: error.failureReason ?? "Error Code: \(error.responseCode ?? 0), and request failed \(respData)...")
                completion(.failure(error))
                return
            }
            do {
                let response = try JSONDecoder().decode(T.self, from: respData.data ?? Data())
                response.success == 1 ? completion(.success(response)) : completion(.failure(NetworkError.notSuccessful(response.message)))
            } catch {
                Logs.writeLog(onDate: Helper.getCurrentDateAndTime(), andDescription: "Error Code: \(respData.error?.responseCode ?? 0), and \(respData)")
                print("Failed to decode data to json!!")
                completion(.failure(error))
            }
        }
    }
    
    func requestToUploadFile<T: ApiResponse>(filePath: URL, request: ApiRequest, completion: @escaping (Result<T, Error>) -> ()) {
        AF.upload(multipartFormData: { multipart in
            multipart.append(filePath, withName: "logFile", fileName: "logFile", mimeType: "text/plain")
        }, to: request.url, method: request.method, headers:["Authorization": "Basic " + apiKey], requestModifier: {$0.timeoutInterval = 600}).validate(statusCode: 200..<300).responseData { respData in
            if let error = respData.error {
                Logs.writeLog(onDate: Helper.getCurrentDateAndTime(), andDescription: error.failureReason ?? "Error Code: \(error.responseCode ?? 0), and request failed \(respData)...")
                completion(.failure(error))
                return
            }
            do {
                let response = try JSONDecoder().decode(T.self, from: respData.data ?? Data())
                response.success == 1 ? completion(.success(response)) : completion(.failure(NetworkError.notSuccessful(response.message)))
            } catch {
                Logs.writeLog(onDate: Helper.getCurrentDateAndTime(), andDescription: "Error Code: \(respData.error?.responseCode ?? 0), and \(respData)")
                print("Failed to decode data to json!!")
                completion(.failure(error))
            }
        }
    }
    
    func requestWithJSON<T: ApiResponse>(request: ApiRequest, completion: @escaping(Result<T, Error>) -> ()) {
        let urlToSend = NSURL(string: request.url)!
        var requestToSend = URLRequest.init(url: urlToSend as URL)

        requestToSend.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        requestToSend.httpMethod = request.method.rawValue
        do {
            requestToSend.httpBody = try JSONSerialization.data(withJSONObject: request.params, options: .prettyPrinted) // pass dictionary to nsdata object and set it as request body
        } catch let error {
                print(error.localizedDescription)
        }
        requestToSend.addValue("Basic " + apiKey, forHTTPHeaderField: "Authorization")
        requestToSend.addValue("application/json", forHTTPHeaderField: "Content-Type")
        requestToSend.timeoutInterval = 300
        
        AF.request(requestToSend as URLRequestConvertible).validate(statusCode: 200..<300).responseDecodable(of: T.self) {
            respData in
            if let error = respData.error {
                Logs.writeLog(onDate: Helper.getCurrentDateAndTime(), andDescription: error.failureReason ?? "request failed \(respData)...")
                completion(.failure(error))
                return
            }
            do {
                let response = try JSONDecoder().decode(T.self, from: respData.data ?? Data())
                if response.success == 1 {
                    completion(.success(response))
                }
                else if response.success == 0 {
                    print(response.message)
                    Logs.writeLog(onDate: Helper.getCurrentDateAndTime(), andDescription: "The error code is: \(respData.error?.responseCode ?? 0) for the API: \(request.url) and Error Description: \(response.message)")
                    completion(.failure(NetworkError.notSuccessful(response.message)))
                }
            } catch {
                Logs.writeLog(onDate: Helper.getCurrentDateAndTime(), andDescription: "The error code is: \(respData.error?.responseCode ?? 0) for the API: \(request.url) and Error Description: \(String(describing: respData.error))")
                print("Failed to decode data to json!!")
                completion(.failure(error))
            }
        }
    }
}
