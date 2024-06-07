//
//  Enums.swift
//  Qiki Cusine
//
//  Created by Nirmit Dagly on 25/11/21.
//

import Foundation
import AVFoundation
import SQLite3
import WebKit
import SystemConfiguration

enum APIErrorCode {
    case noInternetConnection
    case logout
    case login
    case deviceRegister
    case getOrders_Active
    case getOrders_History
    case getOrders_Active_Background
    case getOrders_History_Background
    case getDocketSection
    case uploadLogFile
    case getStoreDetails
    case updateVersionNumber
    case markAsCompleted
    case markAsActive
    case markAsUrgent
    case markIndividualItemDelivered
}

enum Constants {
    enum InfoPlist {
        static let versionNumber = "CFBundleShortVersionString"
        static let buildNumber = "CFBundleVersion"
    }
    
    enum PushAction {
        static let logout = "logout_user"
        static let sendLogs = "send_logs"
        static let updateStoreDetails = "update_store_details"
        static let updateMainTerminalUUID = "update_main_terminal_uuid"
    }
    
    enum OperationIdentifier {
        static let getKDSActiveOrders = "GKAO"
        static let getKDSHistoryOrders = "GKHO"
        static let markKDSOrderAsDelivered = "MOAD"
        static let markItemAsDelivered = "MIAD"
        static let markOrderAsActive = "MOAA"
        static let markOrderAsUrgent = "MOAU"
    }
}

enum DeviceIdentification: Int {
    case online = 1
    case iPad = 2
    case iPhone = 3
    case android = 4
    case DDS = 5
}

enum RequestStatus: Int {
    case isSent = 1
    case isSuccessful = 2
    case isUnSuccessful = 3
}

enum FileUploadStatus: Int {
    case fileUploadNotNeeded = 6 //File upload not needed when order save request is successful on the server
    case waitingForRequestToFail = 1
    case writeOrderToFile = 2
    case uploadFileRequestInitiated = 3 //When this status is set, we're initiating order upload process through file to the server
    case fileUploaded = 4
    case failedToUpload = 5
}

enum DateOrder: Int {
    case same = 1
    case ascending = 2
    case descending = 3
}

enum LogFileNames: String {
    case logs = "Log"
    case printLog = "PrintLogs"
}

enum FontWeight {
    case regular
    case medium
    case demibold
    case bold
    case heavy
}
