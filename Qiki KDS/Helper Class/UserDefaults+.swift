//
//  UserDefaults+.swift
//  Qiki Cusine
//
//  Created by Miamedia Developer on 8/2/21.
//

import Foundation

extension UserDefaults {
    
    func save<T: Encodable>(customObject object: T, inKey key: String) {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(object) {
            self.set(encoded, forKey: key)
        }
    }
    
    func retrieve<T: Decodable>(object type: T.Type, fromKey key: String) -> T? {
        if let data = self.data(forKey: key) {
            let decoder = JSONDecoder()
            if let object = try? decoder.decode(type, from: data) {
                return object
            }
            else {
                //print("Couldnt decode object")
                return nil
            }
        }
        else {
            //print("Couldnt find key: \(key)")
            return nil
        }
    }
    
    private enum Keys {
        static let token = "token"
        static let isLoggedIn = "isLoggedIn"
        static let deviceTokenString = "deviceToken"
        static let isDeviceTokenRegistered = "false"
        static let isTimerRunning = "true"
        static let storeDetails = "StoreDetails"
        static let isMainTerminal = "isMainTerminal"
        static let appVersion = "appVersion"
        static let baseURL = "baseURL"
        static let lastLogoutDate = "LastLogoutDate"
        static let lastActiveOrder = "LastActiveOrder"
        static let rememberLoginDetails = "RememberLoginDetails"
        static let userName = "Username"
        static let password = "Password"
        static let isLandscapeLeft = "isLandscapeLeft"
        static let isPrimaryDevice = "isPrimaryDevice"
        static let deviceID = "DeviceID"
        static let lastOrderIdentifier = "LastOrderIdentifier"
        static let userLoggedOutAfterHours = "UserLoggedOutAfterHours"
        static let selectedDocketSections = "SelectedDocketSections"
        static let supportLinks = "SupportLinks"
    }
    
    // MARK: - Static values
    static var token: Token? {
        get {
            return UserDefaults.standard.retrieve(object: Token.self, fromKey: Keys.token)
        }
        set(newValue) {
            UserDefaults.standard.save(customObject: newValue, inKey: Keys.token)
        }
    }
    
    static var isLoggedIn: Bool {
        get {
            return UserDefaults.standard.bool(forKey: Keys.isLoggedIn)
        }
        set(newValue) {
            UserDefaults.standard.setValue(newValue, forKey: Keys.isLoggedIn)
        }
    }
    
    static var appVersion: String? {
        get {
            return UserDefaults.standard.string(forKey: Keys.appVersion) ?? ""
        }
        set(newValue) {
            UserDefaults.standard.setValue(newValue, forKey: Keys.appVersion)
        }
    }
    
    static var deviceTokenString: String {
        get {
            return UserDefaults.standard.string(forKey: Keys.deviceTokenString) ?? ""
        }
        set(newValue) {
            UserDefaults.standard.setValue(newValue, forKey: Keys.deviceTokenString)
        }
    }
    
    static var isDeviceTokenRegistered: Bool {
        get {
            return UserDefaults.standard.bool(forKey: Keys.isDeviceTokenRegistered)
        }
        set(newValue) {
            UserDefaults.standard.setValue(newValue, forKey: Keys.isDeviceTokenRegistered)
        }
    }
    
    static var isTimerRunning: Bool {
        get {
            return UserDefaults.standard.bool(forKey: Keys.isTimerRunning)
        }
        set(newValue) {
            UserDefaults.standard.setValue(newValue, forKey: Keys.isTimerRunning)
        }
    }
    
    static var storeDetails: StoreDetails? {
        get {
            UserDefaults.standard.retrieve(object: StoreDetails.self, fromKey: Keys.storeDetails)
        }
        set(newValue) {
            UserDefaults.standard.save(customObject: newValue, inKey: Keys.storeDetails)
        }
    }
    
    static var isMainTerminal: Bool {
        get {
            return UserDefaults.standard.bool(forKey: Keys.isMainTerminal)
        }
        set(newValue) {
            UserDefaults.standard.setValue(newValue, forKey: Keys.isMainTerminal)
        }
    }
    
    static var lastLogoutDate: String? {
        get {
            return UserDefaults.standard.string(forKey: Keys.lastLogoutDate) ?? ""
        }
        set(newValue) {
            UserDefaults.standard.setValue(newValue, forKey: Keys.lastLogoutDate)
        }
    }
    
    static var lastActiveOrder: Int {
        get {
            return UserDefaults.standard.integer(forKey: Keys.lastActiveOrder)
        }
        set(newValue) {
            UserDefaults.standard.set(newValue, forKey: Keys.lastActiveOrder)
        }
    }
    
    static var rememberLoginDetails: Bool {
        get {
            return UserDefaults.standard.bool(forKey: Keys.rememberLoginDetails)
        }
        set(newValue) {
            UserDefaults.standard.setValue(newValue, forKey: Keys.rememberLoginDetails)
        }
    }
    
    static var userName: String? {
        get {
            return UserDefaults.standard.string(forKey: Keys.userName) ?? ""
        }
        set(newValue) {
            UserDefaults.standard.setValue(newValue, forKey: Keys.userName)
        }
    }
    
    static var password: String? {
        get {
            return UserDefaults.standard.string(forKey: Keys.password) ?? ""
        }
        set(newValue) {
            UserDefaults.standard.setValue(newValue, forKey: Keys.password)
        }
    }
    
    static var isLandscapeLeft: Bool {
        get {
            return UserDefaults.standard.bool(forKey: Keys.isLandscapeLeft)
        }
        set(newValue) {
            UserDefaults.standard.setValue(newValue, forKey: Keys.isLandscapeLeft)
        }
    }
    
    static var isPrimaryDevice: Bool {
        get {
            return UserDefaults.standard.bool(forKey: Keys.isPrimaryDevice)
        }
        set(newValue) {
            UserDefaults.standard.setValue(newValue, forKey: Keys.isPrimaryDevice)
        }
    }
    
    static var deviceID: Int {
        get {
            return UserDefaults.standard.integer(forKey: Keys.deviceID)
        }
        set(newValue) {
            UserDefaults.standard.set(newValue, forKey: Keys.deviceID)
        }
    }
    
    static var lastOrderIdentifier: String? {
        get {
            return UserDefaults.standard.string(forKey: Keys.lastOrderIdentifier) ?? ""
        }
        set(newValue) {
            UserDefaults.standard.setValue(newValue, forKey: Keys.lastOrderIdentifier)
        }
    }
    
    static var userLoggedOutAfterHours: Bool {
        get {
            return UserDefaults.standard.bool(forKey: Keys.userLoggedOutAfterHours)
        }
        set(newValue) {
            UserDefaults.standard.setValue(newValue, forKey: Keys.userLoggedOutAfterHours)
        }
    }
    
    static var selectedDocketSections: [String]? {
        get {
            UserDefaults.standard.retrieve(object: [String].self, fromKey: Keys.selectedDocketSections)
        }
        set(newValue) {
            UserDefaults.standard.save(customObject: newValue, inKey: Keys.selectedDocketSections)
        }
    }
    
    static var supportLinks: SupportLinks? {
        get {
            return UserDefaults.standard.retrieve(object: SupportLinks.self, fromKey: Keys.supportLinks)
        }
        set(newValue) {
            UserDefaults.standard.save(customObject: newValue, inKey: Keys.supportLinks)
        }
    }

    // MARK:- Static functions
    static func clearAll() {
        UserDefaults.standard.removeObject(forKey: Keys.isLoggedIn)
        UserDefaults.standard.removeObject(forKey: Keys.isTimerRunning)
        UserDefaults.standard.removeObject(forKey: Keys.storeDetails)
        UserDefaults.standard.removeObject(forKey: Keys.deviceID)

        if UserDefaults.rememberLoginDetails == false {
            UserDefaults.standard.removeObject(forKey: Keys.token)
        }
        UserDefaults.standard.synchronize()
    }
}

extension UserDefaults: ObjectSavable {
    func setObject<Object>(_ object: Object, forKey: String) throws where Object: Encodable {
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(object)
            set(data, forKey: forKey)
        } catch {
            throw ObjectSavableError.unableToEncode
        }
    }
    
    func getObject<Object>(forKey: String, castTo type: Object.Type) throws -> Object where Object: Decodable {
        guard let data = data(forKey: forKey) else { throw ObjectSavableError.noValue }
        let decoder = JSONDecoder()
        do {
            let object = try decoder.decode(type, from: data)
            return object
        } catch {
            throw ObjectSavableError.unableToDecode
        }
    }
}


protocol ObjectSavable {
    func setObject<PrinterData>(_ object: PrinterData, forKey: String) throws where PrinterData: Encodable
    func getObject<PrinterData>(forKey: String, castTo type: PrinterData.Type) throws -> PrinterData where PrinterData: Decodable
}

enum ObjectSavableError: String, LocalizedError {
    case unableToEncode = "Unable to encode object into data"
    case noValue = "No data object found for the given key"
    case unableToDecode = "Unable to decode object into given type"
    
    var errorDescription: String? {
        rawValue
    }
}
