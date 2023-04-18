//
//  LogService.swift
//  Qiki KDS
//
//  Created by Nirmit Dagly on 30/12/2022.
//

import Foundation

struct LogService {
    static let shared = LogService()
    var baseURL: String {UserDefaults.token?.qikiSite ?? ""}

    //MARK: The following function will be called to upload the log file on server.
    func sendLogFile(completion: @escaping (Result<GeneralResponse, Error>) -> ()) {
        let file = LogFileNames.logs.rawValue + ".txt" //this is the file. we will write to and read from it
        var fileURL = URL.init(string: "")
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            fileURL = dir.appendingPathComponent(file)
        }
        
        let apiRequest = ApiRequest.init(url: "\(baseURL)/ios_logs",
                                         params: ["device_uuid": deviceUUID,
                                                  "device_name": deviceName],
                                         method: .post)
        WebService.shared.requestToUploadFile(filePath: fileURL!, request: apiRequest) { (result: Result<GeneralResponse, Error>) in
            switch result {
            case .failure(let error):
                print(error.localizedDescription)
                Logs.writeLog(onDate: Helper.getCurrentDateAndTime(), andDescription: "\(error)")
                completion(.failure(error))
            case .success(let resp):
                //First of all, delete the uploaded file and create a new one at Documents directory...
                let textLog = TextLog()
                if textLog.checkIfFileExists(fileName: LogFileNames.logs.rawValue) == true {
                    textLog.deleteFile()
                    textLog.createFile(fileName: LogFileNames.logs.rawValue)
                    Logs.writeLog(onDate: Helper.getCurrentDateAndTime(), andDescription: "New log file created for app with version: \(appVersion) and device UUID: \(deviceUUID) and device name: \(deviceName).")
                }
                else {
                    print("Log file does not exists at location...")
                }
                completion(.success(resp))
            }
        }

    }
}
