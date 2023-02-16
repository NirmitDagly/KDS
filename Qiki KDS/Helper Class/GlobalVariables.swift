//
//  GlobalVariables.swift
//  Qiki Cusine
//
//  Created by Nirmit Dagly on 25/11/21.
//

import Foundation
import UIKit

var sb = UIStoryboard.init(name: "Main", bundle: nil)

let iphoneSb = UIStoryboard.init(name: "iPhoneMain", bundle: nil)

let appVersion: String = "QIKI - Docket Display System \(UIApplication.appVersion)"

let deviceUUID = UIDevice.current.identifierForVendor!.uuidString.lowercased() as String

var deviceID = 0

var posID = (UserDefaults.token?.username ?? "Admin") + String(UserDefaults.deviceID)

let deviceName = UIDevice.current.name

let deviceModel = UIDevice.current.model

let deviceSystemVersion = UIDevice.current.systemVersion

var baseURL = UserDefaults.token?.qikiSite ?? ""

let alertTitle: String = "Qiki - Docket Display System"

let alertErrorMessage: String = "An error occured, please try again."

let alertSettingsMessage: String = "Settings updated successfully."

let requiredFieldMessage: String = "Please enter the following: "

let alertLoading: String = "Please wait..."

//var pushToHome: Bool = false

var sessionActive = false

var segmentToPushTo: String = "Active"

var newIncomingOrders: Int = 0

var incomingOrdersRecieved = false

var clearDocket = false

var loggedInAs: String = "Admin"

//User Defaults
let userDefaults = UserDefaults.standard

var spinnerActive: Bool = false

var logFileUploadTimer: Timer?

var noInternetAlert = UIAlertController()

var appLogoutTimer: Timer?

var isLoggedinFirstTime = true

var popupResponseValue = 0.00

var isShowingPrompt = false

var batteryAlertPlayed = false

var orientation: UIInterfaceOrientationMask = .landscapeRight

var logFileSizeCheckTimer: Timer?

let versionNumber = Bundle.main.infoDictionary?[Constants.InfoPlist.versionNumber] as? String

let buildNumber = Bundle.main.infoDictionary?[Constants.InfoPlist.buildNumber] as? String

let timeoutInMinutes: TimeInterval = 30 * 60

var idleTimerAfterClosingHours: Timer?

var closingHourTimer: Timer?

var closingAlert = UIAlertController()

var isClosingAlertPresent = false

var isDeviceOffline = 0

//Docket Sections List
var docketSections = [String]()

var selectedSections = [String]()

var activeOrdersTimer: Timer?
