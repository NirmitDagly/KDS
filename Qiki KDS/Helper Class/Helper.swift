//
//  Helper.swift
//  Qiki Cusine
//
//  Created by Michael Inati on 8/2/21.
//

import UIKit
import Foundation
import Alamofire
import NVActivityIndicatorView
import AVFoundation
import FillableLoaders
import SystemConfiguration
import WebKit

class Helper {
    class func getAppVersionNumber() -> String {
        let versionNumber = Bundle.main.infoDictionary?[Constants.InfoPlist.versionNumber] as? String
        let buildNumber = Bundle.main.infoDictionary?[Constants.InfoPlist.buildNumber] as? String
        return versionNumber! + ":" + buildNumber!
    }
    
    class func presentAlert(viewController: UIViewController, title: String, message: String) {
        //        let alert: UIAlertController = UIAlertController.init(title: title, message: message, preferredStyle: .alert)
        //
        //        let btnOk: UIAlertAction = UIAlertAction.init(title: "Ok", style: .default, handler: nil)
        //        alert.addAction(btnOk)
        //        viewController.present(alert, animated: true, completion: nil)
        
        let vc = sb.instantiateViewController(withIdentifier: "BasicPopupViewController") as! BasicPopupViewController
        vc.popupTitle = title
        vc.popupMessage = message
        vc.modalPresentationStyle = .overCurrentContext
        viewController.present(vc, animated: false)
    }
    
    class func presentInternetError(viewController: UIViewController) {
        let alert: UIAlertController = UIAlertController.init(title: "Device Offline", message: "Please reconnect to the internet and try again", preferredStyle: .alert)
        
        let btnOk: UIAlertAction = UIAlertAction.init(title: "Ok", style: .default, handler: nil)
        alert.addAction(btnOk)
        viewController.present(alert, animated: true, completion: nil)
    }
    
    class func loadingSpinner(isLoading: Bool, isUserInteractionEnabled: Bool, withMessage message: String) {
        spinnerActive = isLoading
        let window = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
        var loader: FillableLoader = FillableLoader()
        let spinner = NVActivityIndicatorView(frame: .zero, type: .circleStrokeSpin, color: UIColor.qikiColor, padding: 0)
        let loadingView = UIView(frame: loader.frame)
        
        let messageLabel = UILabel.init(frame: CGRect.init(x: loader.frame.origin.x, y: loader.frame.origin.y, width: 500, height: 200))
        messageLabel.text = message
        messageLabel.font = UIFont.init().customFont(withWeight: .demibold, withSize: 18)
        messageLabel.numberOfLines = 2
        messageLabel.textColor = .black
        messageLabel.textAlignment = .center
        messageLabel.tag = 101
        
        for subview in window!.subviews {
            if subview.tag == 100 {
                subview.removeFromSuperview()
            }
        }
        
        loadingView.addSubview(spinner)
        if message != "" {
            loadingView.addSubview(messageLabel)
        }
        window!.addSubview(loadingView)
        
        
        
        
        loadingView.tag = 100
        
        loadingView.layer.cornerRadius = 60
        loadingView.backgroundColor = #colorLiteral(red: 0.5480879545, green: 0.5448333025, blue: 0.5505920649, alpha: 0.3553896266)
        
        spinner.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            spinner.widthAnchor.constraint(equalToConstant: 119),
            spinner.heightAnchor.constraint(equalToConstant: 119),
            spinner.centerYAnchor.constraint(equalTo: window!.centerYAnchor),
            spinner.centerXAnchor.constraint(equalTo: window!.centerXAnchor),
        ])
        
        if message != "" {
            messageLabel.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                messageLabel.widthAnchor.constraint(equalToConstant: 500),
                messageLabel.heightAnchor.constraint(equalToConstant: 200),
                messageLabel.topAnchor.constraint(equalTo: spinner.topAnchor, constant: 50),
                messageLabel.centerXAnchor.constraint(equalTo: window!.centerXAnchor)
            ])
        }
        
        loadingView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            loadingView.widthAnchor.constraint(equalToConstant: 120),
            loadingView.heightAnchor.constraint(equalToConstant: 120),
            loadingView.centerYAnchor.constraint(equalTo: window!.centerYAnchor),
            loadingView.centerXAnchor.constraint(equalTo: window!.centerXAnchor),
        ])
        
        if isLoading == true {
            spinner.startAnimating()
            loader = PlainLoader.showLoader(with: qikiLogoPath(), on: window!.subviews.first)
            loadingView.addSubview(loader)
            window!.isUserInteractionEnabled = isUserInteractionEnabled
        }
        else {
            for subview in window!.subviews {
                if subview.tag == 100 {
                    loader.removeLoader(true)
                    subview.removeFromSuperview()
                }
            }
            spinner.stopAnimating()
            window!.isUserInteractionEnabled = true
        }
    }
    
    class func errorForAPI(_ apiName: APIErrorCode) -> Int {
        switch apiName {
            case .noInternetConnection:
                return 1000
            case .logout:
                return 999
            case .login:
                return 1001
            case .deviceRegister:
                return 1002
            case .getOrders_Active:
                return 1003
            case .getOrders_History:
                return 1004
            case .getOrders_Active_Background:
                return 1005
            case .getOrders_History_Background:
                return 1006
            case .getDocketSection:
                return 1007
            case .uploadLogFile:
                return 1008
            case .getStoreDetails:
                return 1009
            case .updateVersionNumber:
                return 1010
            case .markAsCompleted:
                return 1011
            case .markAsActive:
                return 1012
            case .markAsUrgent:
                return 1013
            case .markIndividualItemDelivered:
                return 1014
        }
    }
    
    //MARK: Below function is written to check what sort of error has occured when the internet is reachable.
    //Recheck for implementation of below function...
    class func getErrorDetails(error: AFError) -> String {
        var errorReason = ""
        let underlyingError = error.underlyingError
        if let urlError = underlyingError as? URLError {
            switch urlError.code {
            case .networkConnectionLost:
                errorReason = "Not connected"
            case .cannotConnectToHost:
                errorReason = "Not connected"
            case .timedOut:
                errorReason = "Timed out error"
            case .notConnectedToInternet:
                errorReason = "Not connected"
            default:
                errorReason = ""
            }
        }
        return errorReason
    }
    
    class func getCurrentDateAndTime() -> String {
        let dateFormatter = DateFormatter.init()
        dateFormatter.dateFormat = "dd/MM/yyyy hh:mm:ss a"
        
        let date = Date()
        let currentDate = dateFormatter.string(from: date)
        return currentDate
    }
    
    class func getCurrentDateOnly() -> String {
        let dateFormatter = DateFormatter.init()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        
        let date = Date()
        let currentDate = dateFormatter.string(from: date)
        return currentDate
    }
    
    class func getCurrentTimeOnly() -> String {
        let dateFormatter = DateFormatter.init()
        dateFormatter.dateFormat = "hh:mm:ss a"
        
        let date = Date()
        let currentTime = dateFormatter.string(from: date)
        return currentTime
    }
    
    class func isNetworkReachable() -> Bool {
        if (NetworkReachability.shared.isReachable == true) || (NetworkReachability.shared.isConnectedViaWiFi == true) || (NetworkReachability.shared.isConnectedViaCellular == true) {
            isDeviceOffline = 0
            return true
        }
        else {
            isDeviceOffline = 1
            return false
        }
    }
    
    class func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    //Add / Remove child view from parent
    class func removeChildFromParent(_ viewController: UIViewController) {
        if viewController.children.count > 0 {
            let viewControllers: [UIViewController] = viewController.children
            for vc in viewControllers {
                vc.willMove(toParent: nil)
                vc.view.removeFromSuperview()
                vc.removeFromParent()
            }
        }
    }
    
    class func removeAlertFromParent(_ viewController: UIViewController) {
        if UIApplication.shared.topViewController()!.isKind(of: UIAlertController.self) {
            UIApplication.shared.topViewController()!.dismiss(animated: true, completion: nil)
        }
    }
        
    class func isValidEmail(forEmailAddress email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    class func isValidPhone(forPhoneNumber value: String) -> Bool {
        if value.count > 10 || value.count < 10 {
            return false
        }
        else {
            return true
        }
    }
    
    class func qikiLogoPath() -> CGPath {
        //// Color Declarations
        let fillColor = UIColor(red: 0.265, green: 0.301, blue: 0.559, alpha: 1.000)
        
        //// Group 2
        //// Bezier Drawing - For letter 'Q'
        let bezierPath = UIBezierPath()
        bezierPath.move(to: CGPoint(x: 96.94, y: 10.67))
        bezierPath.addCurve(to: CGPoint(x: 92.1, y: 8.22), controlPoint1: CGPoint(x: 96.17, y: 9.19), controlPoint2: CGPoint(x: 94.52, y: 8.22))
        bezierPath.addCurve(to: CGPoint(x: 85.54, y: 10.67), controlPoint1: CGPoint(x: 89.68, y: 8.22), controlPoint2: CGPoint(x: 87.32, y: 9.19))
        bezierPath.addCurve(to: CGPoint(x: 79, y: 23.52), controlPoint1: CGPoint(x: 83.16, y: 12.59), controlPoint2: CGPoint(x: 81.99, y: 14.71))
        bezierPath.addCurve(to: CGPoint(x: 76.79, y: 36.38), controlPoint1: CGPoint(x: 76, y: 32.33), controlPoint2: CGPoint(x: 75.72, y: 34.45))
        bezierPath.addCurve(to: CGPoint(x: 81.68, y: 38.82), controlPoint1: CGPoint(x: 77.55, y: 37.86), controlPoint2: CGPoint(x: 79.26, y: 38.82))
        bezierPath.addCurve(to: CGPoint(x: 84.9, y: 37.98), controlPoint1: CGPoint(x: 82.77, y: 38.82), controlPoint2: CGPoint(x: 83.87, y: 38.56))
        bezierPath.addLine(to: CGPoint(x: 82.28, y: 34.06))
        bezierPath.addLine(to: CGPoint(x: 88.6, y: 29.37))
        bezierPath.addLine(to: CGPoint(x: 90.81, y: 32.78))
        bezierPath.addCurve(to: CGPoint(x: 94.79, y: 23.52), controlPoint1: CGPoint(x: 92.19, y: 30.79), controlPoint2: CGPoint(x: 93.21, y: 28.15))
        bezierPath.addCurve(to: CGPoint(x: 96.94, y: 10.67), controlPoint1: CGPoint(x: 97.79, y: 14.71), controlPoint2: CGPoint(x: 98, y: 12.59))
        bezierPath.close()
        bezierPath.move(to: CGPoint(x: 91.63, y: 48.33))
        bezierPath.addLine(to: CGPoint(x: 88.99, y: 44.28))
        bezierPath.addCurve(to: CGPoint(x: 78.97, y: 46.79), controlPoint1: CGPoint(x: 85.88, y: 45.96), controlPoint2: CGPoint(x: 82.54, y: 46.79))
        bezierPath.addCurve(to: CGPoint(x: 68.39, y: 41.78), controlPoint1: CGPoint(x: 73.81, y: 46.79), controlPoint2: CGPoint(x: 70.48, y: 44.99))
        bezierPath.addCurve(to: CGPoint(x: 70.14, y: 23.52), controlPoint1: CGPoint(x: 65.38, y: 37.15), controlPoint2: CGPoint(x: 67.45, y: 31.43))
        bezierPath.addCurve(to: CGPoint(x: 80.82, y: 5.27), controlPoint1: CGPoint(x: 72.84, y: 15.62), controlPoint2: CGPoint(x: 74.66, y: 9.89))
        bezierPath.addCurve(to: CGPoint(x: 94.82, y: 0.25), controlPoint1: CGPoint(x: 85.1, y: 2.05), controlPoint2: CGPoint(x: 89.66, y: 0.25))
        bezierPath.addCurve(to: CGPoint(x: 105.34, y: 5.27), controlPoint1: CGPoint(x: 99.98, y: 0.25), controlPoint2: CGPoint(x: 103.25, y: 2.05))
        bezierPath.addCurve(to: CGPoint(x: 103.64, y: 23.52), controlPoint1: CGPoint(x: 108.35, y: 9.89), controlPoint2: CGPoint(x: 106.34, y: 15.62))
        bezierPath.addCurve(to: CGPoint(x: 95.33, y: 39.72), controlPoint1: CGPoint(x: 101.3, y: 30.4), controlPoint2: CGPoint(x: 99.64, y: 35.48))
        bezierPath.addLine(to: CGPoint(x: 97.88, y: 43.64))
        bezierPath.addLine(to: CGPoint(x: 91.63, y: 48.33))
        bezierPath.close()
        fillColor.setFill()
        bezierPath.fill()
        
        //// Rectangle Drawing - For first line
        bezierPath.move(to: CGPoint(x: 43.87, y: 6.44))
        bezierPath.addLine(to: CGPoint(x: 59.81, y: 6.44))
        bezierPath.addCurve(to: CGPoint(x: 63.08, y: 6.52), controlPoint1: CGPoint(x: 62.55, y: 6.44), controlPoint2: CGPoint(x: 62.83, y: 6.44))
        bezierPath.addLine(to: CGPoint(x: 63.13, y: 6.54))
        bezierPath.addCurve(to: CGPoint(x: 63.91, y: 7.65), controlPoint1: CGPoint(x: 63.6, y: 6.71), controlPoint2: CGPoint(x: 63.91, y: 7.15))
        bezierPath.addCurve(to: CGPoint(x: 63.91, y: 7.72), controlPoint1: CGPoint(x: 63.91, y: 7.72), controlPoint2: CGPoint(x: 63.91, y: 7.72))
        bezierPath.addLine(to: CGPoint(x: 63.91, y: 7.72))
        bezierPath.addLine(to: CGPoint(x: 63.91, y: 7.72))
        bezierPath.addLine(to: CGPoint(x: 63.91, y: 7.78))
        bezierPath.addCurve(to: CGPoint(x: 63.13, y: 8.9), controlPoint1: CGPoint(x: 63.91, y: 8.28), controlPoint2: CGPoint(x: 63.6, y: 8.73))
        bezierPath.addCurve(to: CGPoint(x: 62, y: 8.99), controlPoint1: CGPoint(x: 62.83, y: 8.99), controlPoint2: CGPoint(x: 62.55, y: 8.99))
        bezierPath.addLine(to: CGPoint(x: 46.31, y: 8.99))
        bezierPath.addCurve(to: CGPoint(x: 43.04, y: 8.91), controlPoint1: CGPoint(x: 43.56, y: 8.99), controlPoint2: CGPoint(x: 43.29, y: 8.99))
        bezierPath.addLine(to: CGPoint(x: 42.99, y: 8.9))
        bezierPath.addCurve(to: CGPoint(x: 42.21, y: 7.78), controlPoint1: CGPoint(x: 42.52, y: 8.73), controlPoint2: CGPoint(x: 42.21, y: 8.28))
        bezierPath.addCurve(to: CGPoint(x: 42.21, y: 7.72), controlPoint1: CGPoint(x: 42.21, y: 7.72), controlPoint2: CGPoint(x: 42.21, y: 7.72))
        bezierPath.addLine(to: CGPoint(x: 42.21, y: 7.72))
        bezierPath.addLine(to: CGPoint(x: 42.21, y: 7.72))
        bezierPath.addLine(to: CGPoint(x: 42.21, y: 7.65))
        bezierPath.addCurve(to: CGPoint(x: 42.99, y: 6.54), controlPoint1: CGPoint(x: 42.21, y: 7.15), controlPoint2: CGPoint(x: 42.52, y: 6.71))
        bezierPath.addCurve(to: CGPoint(x: 44.12, y: 6.44), controlPoint1: CGPoint(x: 43.29, y: 6.44), controlPoint2: CGPoint(x: 43.56, y: 6.44))
        bezierPath.addLine(to: CGPoint(x: 46.31, y: 6.44))
        bezierPath.addLine(to: CGPoint(x: 43.87, y: 6.44))
        bezierPath.close()
        fillColor.setFill()
        bezierPath.fill()
        
        
        //// Bezier 8 Drawing - For second line
        bezierPath.move(to: CGPoint(x: 56.24, y: 27.47))
        bezierPath.addLine(to: CGPoint(x: 23.79, y: 27.47))
        bezierPath.addCurve(to: CGPoint(x: 22.85, y: 26.08), controlPoint1: CGPoint(x: 23.27, y: 27.47), controlPoint2: CGPoint(x: 22.85, y: 26.85))
        bezierPath.addCurve(to: CGPoint(x: 23.79, y: 24.69), controlPoint1: CGPoint(x: 22.85, y: 25.31), controlPoint2: CGPoint(x: 23.27, y: 24.69))
        bezierPath.addLine(to: CGPoint(x: 56.24, y: 24.69))
        bezierPath.addCurve(to: CGPoint(x: 57.18, y: 26.08), controlPoint1: CGPoint(x: 56.76, y: 24.69), controlPoint2: CGPoint(x: 57.18, y: 25.31))
        bezierPath.addCurve(to: CGPoint(x: 56.24, y: 27.47), controlPoint1: CGPoint(x: 57.18, y: 26.85), controlPoint2: CGPoint(x: 56.76, y: 27.47))
        bezierPath.close()
        fillColor.setFill()
        bezierPath.fill()
        
        
        //// Bezier 9 Drawing - For third line
        bezierPath.move(to: CGPoint(x: 48.25, y: 45.81))
        bezierPath.addLine(to: CGPoint(x: 5.83, y: 45.81))
        bezierPath.addCurve(to: CGPoint(x: 5, y: 44.42), controlPoint1: CGPoint(x: 5.37, y: 45.81), controlPoint2: CGPoint(x: 5, y: 45.18))
        bezierPath.addCurve(to: CGPoint(x: 5.83, y: 43.02), controlPoint1: CGPoint(x: 5, y: 43.65), controlPoint2: CGPoint(x: 5.37, y: 43.02))
        bezierPath.addLine(to: CGPoint(x: 48.25, y: 43.02))
        bezierPath.addCurve(to: CGPoint(x: 49.07, y: 44.42), controlPoint1: CGPoint(x: 48.7, y: 43.02), controlPoint2: CGPoint(x: 49.07, y: 43.65))
        bezierPath.addCurve(to: CGPoint(x: 48.25, y: 45.81), controlPoint1: CGPoint(x: 49.07, y: 45.18), controlPoint2: CGPoint(x: 48.7, y: 45.81))
        bezierPath.close()
        fillColor.setFill()
        bezierPath.fill()
        
        return bezierPath.cgPath
    }
    
    //MARK: Generate POS REF ID
    class func getPOSRefID() -> String {
        return "\(UserDefaults.deviceID)" + "-" + Date().toString(format: "HH-mm-ss")
    }
        
    //MARK: Send Log file to server every hour and generate a new file once it has uploaded successfully
    class func scheduleTimerToUploadLogFile() {
        if logFileUploadTimer == nil {
            logFileUploadTimer = Timer.scheduledTimer(timeInterval: 60 * 30, target: self, selector: #selector(sendLogsAfterHour), userInfo: nil, repeats: true)
        }
    }
    
    @objc class func sendLogsAfterHour() {
        uploadLogFileToServer(from: "")
    }
    
    class func uploadLogFileToServer(from: String) {
        if Helper.isNetworkReachable() {
            LogService.shared.sendLogFile { result in
                switch result {
                    case .failure(let error):
                        Logs.writeLog(onDate: Helper.getCurrentDateAndTime(), andDescription: "The file couldn't be uploaded after an hour because of an error: \(error).")
                        
                    case .success(_):
                        if from == "push" {
                            Logs.writeLog(onDate: Helper.getCurrentDateAndTime(), andDescription: "The file uploaded successfully because a silent push notification requested.")
                        }
                        else if from == "fileSize" {
                            Logs.writeLog(onDate: Helper.getCurrentDateAndTime(), andDescription: "The log file uploaded successfully because a file size was more than 5 MB.")
                        }
                        else {
                            Logs.writeLog(onDate: Helper.getCurrentDateAndTime(), andDescription: "The file uploaded successfully after an hour.")
                        }
                }
            }
        }
        else {
            Logs.writeLog(onDate: Helper.getCurrentDateAndTime(), andDescription: "Device is not connected to internet.")
        }
    }
    
    //MARK: To logout from app after an hour of closing time, call below function
    @objc class func compareTimeToLogoutApp() {
        let currentDate = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy hh:mm a"
        formatter.timeZone = .current
        formatter.locale = .current
        let currentDateTime = formatter.string(from: currentDate)
        
        var closingDateTime = ""
        if UserDefaults.storeDetails != nil {
            let closingHour = UserDefaults.storeDetails!.closingHours!
            
            var separatedTime = closingHour.split(separator: " ")
            let time = separatedTime[0].split(separator: ":")
            var newClosingHours = String(Int(time[0])! + 1)
            
            if newClosingHours.count == 1 {
                newClosingHours = "0" + newClosingHours
            }
            
            if newClosingHours == "13" {
                newClosingHours = "01"
            }
            
            let dateFormatter = DateFormatter()
            dateFormatter.locale = .current
            dateFormatter.timeZone = .current
            dateFormatter.dateFormat = "dd/MM/yyyy"
            dateFormatter.amSymbol = "AM"
            dateFormatter.pmSymbol = "PM"
            
            if time[0] == "11" {
                if separatedTime[1] == "AM" {
                    separatedTime[1] = "PM"
                    newClosingHours = newClosingHours + ":" + time[1] + " " + separatedTime[1]
                    print(newClosingHours)
                }
                else {
                    separatedTime[1] = "AM"
                    newClosingHours = newClosingHours + ":" + time[1] + " " + separatedTime[1]
                    print(newClosingHours)
                }
            }
            else {
                newClosingHours = newClosingHours + ":" + time[1] + " " + separatedTime[1]
            }
            
            closingDateTime = dateFormatter.string(from: Date()) + " " + newClosingHours.lowercased()
            print(closingDateTime)
        }
        
        if currentDateTime == closingDateTime {
            UserDefaults.userLoggedOutAfterHours = true
            logoutUser(from: "after hours")
        }
    }
    
    class func startLogoutTimer() {
        if appLogoutTimer == nil {
            appLogoutTimer = Timer.scheduledTimer(timeInterval: 60, target: self, selector: #selector(compareTimeToLogoutApp), userInfo: nil, repeats: true)
        }
    }
    
    class func logoutUser(from: String) {
        if logFileUploadTimer != nil {
            logFileUploadTimer?.invalidate()
            logFileUploadTimer = nil
        }
        
        if appLogoutTimer != nil {
            appLogoutTimer?.invalidate()
            appLogoutTimer = nil
        }
        
        if logFileSizeCheckTimer != nil {
            logFileSizeCheckTimer?.invalidate()
            logFileSizeCheckTimer = nil
        }
        
        if idleTimerAfterClosingHours != nil {
            idleTimerAfterClosingHours?.invalidate()
            idleTimerAfterClosingHours = nil
        }
        
        if closingHourTimer != nil {
            closingHourTimer?.invalidate()
            closingHourTimer = nil
        }
        
        sessionActive = false
        
        UserDefaults.lastLogoutDate = Date().toString(format: "dd-MM-yyyy")
        UserDefaults.clearAll()
        
        if from == "push" {
            Logs.writeLog(onDate: Helper.getCurrentDateAndTime(), andDescription: "The user logged out successfully because a silent push notification requested.")
        }
        else if from == "after hours" {
            Logs.writeLog(onDate: Helper.getCurrentDateAndTime(), andDescription: "The user logged out successfully when the system has detected no activity after hours.")
        }
        else {
            Logs.writeLog(onDate: Helper.getCurrentDateAndTime(), andDescription: "The user logged out successfully.")
        }
        moveToLoginScreen()
    }
    
    class func moveToLoginScreen() {
        if let navigationController = UIApplication.shared.windows[0].rootViewController as? UINavigationController {
            //Do something
            for vc in navigationController.viewControllers as Array {
                if vc.isKind(of: LoginViewController.self) {
                    navigationController.popToViewController(vc, animated: true)
                    break
                }
            }
        }
    }
    
    class func checkBatteryLevel() {
        UIDevice.current.isBatteryMonitoringEnabled = true
        
        let batteryLevel =  UIDevice.current.batteryLevel
        let state = UIDevice.current.batteryState
        
        if state != .charging {
            if batteryLevel == 0.2 && batteryAlertPlayed == false {
                AudioServicesPlayAlertSound(SystemSoundID(1005))
                batteryAlertPlayed = true
            }
            else if batteryLevel < 0.2 && batteryLevel > 0.1{
                batteryAlertPlayed = false
            }
            else if batteryLevel > 0.2 {
                batteryAlertPlayed = false
            }
            else if batteryLevel == 0.1 && batteryAlertPlayed == false {
                AudioServicesPlayAlertSound(SystemSoundID(1005))
                batteryAlertPlayed = true
            }
            else if batteryLevel < 0.1 && batteryLevel > 0.05 {
                batteryAlertPlayed = false
            }
            else if batteryLevel > 0.1 && batteryLevel < 0.2 {
                batteryAlertPlayed = false
            }
            else if batteryLevel <= 0.05 {
                if !UIApplication.shared.topViewController()!.isKind(of: BasicPopupViewController.self) {
                    Helper.presentAlert(viewController: UIApplication.shared.topViewController()!, title: "Alert", message: "IPad Battery Life is critically low, turning off may cause issues to qiki settings and business operation, plug in to resume.")
                }
                AudioServicesPlayAlertSound(SystemSoundID(1005))
            }
        }
    }
    
    //MARK: Prepare timestamp and products to create an order object with the available details
    class func calculateCurrentTime() -> Int {
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy H:mm:ss"
        let current_date_time = dateFormatter.string(from: date)
        print("before add time-->",current_date_time)
        
        let current_add_date_time = dateFormatter.date(from: current_date_time)
        return Int(current_add_date_time!.timeIntervalSince1970)
    }
    
    class func calculateFiveMinutesFromCurrentTime() -> Int {
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy H:mm:ss"
        let current_date_time = dateFormatter.string(from: date)
        print("before add time-->",current_date_time)
        
        //adding 5 miniuts
        let addminutes = date.addingTimeInterval(5*60)
        dateFormatter.dateFormat = "dd/MM/yyyy H:mm:ss"
        let after_add_time = dateFormatter.string(from: addminutes)
        print("after add time-->",after_add_time)
        
        let after_add_date_time = dateFormatter.date(from: after_add_time)
        return Int(after_add_date_time!.timeIntervalSince1970)
    }
    
    //MARK: Compare the dates to find the date is ascending or not
    class func compareDates(date1: String, date2: String) -> DateOrder {
        let dateFormatter = DateFormatter.init()
        dateFormatter.dateFormat = "dd/MM/yyyy hh:mm:ss a"
        
        let lastOrderDate = dateFormatter.date(from: date1)
        let currentDate = dateFormatter.date(from: date2)
        
        if lastOrderDate != nil && currentDate != nil {
            let df = DateFormatter.init()
            df.dateFormat = "DD/MM/yyyy"
            
            let dateOfOrder = df.string(from: lastOrderDate!)
            let finalDate = df.date(from: dateOfOrder)
            
            let currentDateTime = df.string(from: currentDate!)
            let finalCurrentDate = df.date(from: currentDateTime)
            
            switch finalDate!.compare(finalCurrentDate!) {
            case .orderedSame:
                return DateOrder.same
            case .orderedAscending:
                return DateOrder.ascending
            case .orderedDescending:
                return DateOrder.descending
            }
        }
        else {
            return DateOrder.same
        }
    }
    
    //MARK: Initialize the Log File Size Check Timers
    class func initializeLogSizeCheckTimers() {
        if logFileSizeCheckTimer == nil {
            logFileSizeCheckTimer = Timer.scheduledTimer(timeInterval: 2 * 60, target: self, selector: #selector(checkFileSizeForLogFile), userInfo: nil, repeats: true)
        }
    }
    
    @objc class func checkFileSizeForLogFile() {
        let file = LogFileNames.logs.rawValue + ".txt" //this is the file. we will write to and read from it
        var fileURL = URL.init(string: "")
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            fileURL = dir.appendingPathComponent(file)
        }
        
        if fileURL != nil {
            let sizeOfFile = fileURL!.fileSizeString
            let fileSizeComponents = sizeOfFile.components(separatedBy: " ")
            
            if fileSizeComponents.count > 0 && Double(fileSizeComponents[0])! > 5 && fileSizeComponents[1] == "MB" {
                self.uploadLogFileToServer(from: "fileSize")
            }
            else {
                Logs.writeLog(onDate: Helper.getCurrentDateAndTime(), andDescription: "Avoiding file to upload on server as it is less than 5 MB.")
            }
        }
    }
    
    //MARK: Following function will be used to identify the requests
    class func generateOperationIdentifier(for operation: String) -> String {
        var currentDateTime = Helper.getCurrentDateAndTime()
        currentDateTime = currentDateTime.replacingOccurrences(of: "/", with: "")
        currentDateTime = currentDateTime.replacingOccurrences(of: ":", with: "")
        currentDateTime = currentDateTime.replacingOccurrences(of: " ", with: "")
        return operation + currentDateTime + String(deviceID)
    }
    
    //MARK: Show alert after 30 mins of closing hour (If app is open and not logged out). If user clicks 'Ok', allow them to use the app for 30 mins and show the alert again. If no body responds to the alert within 30 mins, dismiss the popup and logout User from the application.
    class func resetIdleTimerAfterClosingHours() {
        if let idleTimerAfterClosingHours = idleTimerAfterClosingHours {
            idleTimerAfterClosingHours.invalidate()
        }
        
        idleTimerAfterClosingHours = Timer.scheduledTimer(timeInterval: timeoutInMinutes, target: self, selector: #selector(checkTimeAfterClosingHours), userInfo: nil, repeats: true)
    }
    
    @objc class func idleTimerAfterClosingHourExceeded() {
        if isClosingAlertPresent == false {
            let topController = UIApplication.shared.topViewController()
            closingAlert = UIAlertController.init(title: "ALERT", message: "System has detected that you are using POS after closing hours. \n\nDo you want to continue?", preferredStyle: .alert)
            
            let btnOk = UIAlertAction.init(title: "Continue", style: .default) { _ in
                if closingHourTimer != nil {
                    closingHourTimer?.invalidate()
                    closingHourTimer = nil
                }
                Logs.writeLog(onDate: Helper.getCurrentDateAndTime(), andDescription: "Someone is still using the app. Hence, avoiding force logout...")
                Helper.resetIdleTimerAfterClosingHours()
                closingAlert.dismiss(animated: true)
                
                isClosingAlertPresent = false
            }
            
            let btnNo = UIAlertAction.init(title: "Logout", style: .destructive) { _ in
                if closingHourTimer != nil {
                    closingHourTimer?.invalidate()
                    closingHourTimer = nil
                }
                closingAlert.dismiss(animated: true)
                Logs.writeLog(onDate: Helper.getCurrentDateAndTime(), andDescription: "App has not detected any event after closing hours (though it was logged in). Hence, logging it out now...")
                Helper.logoutUser(from: "after hours")
                isClosingAlertPresent = false
            }
            
            closingAlert.addAction(btnOk)
            closingAlert.addAction(btnNo)
            topController?.present(closingAlert, animated: true)
            
            isClosingAlertPresent = true
        }
        Helper.startClosingHourCheckTimer()
    }
    
    class func startClosingHourCheckTimer() {
        if closingHourTimer == nil {
            closingHourTimer = Timer.scheduledTimer(timeInterval: timeoutInMinutes, target: self, selector: #selector(checkTimeAfterClosingHours), userInfo: nil, repeats: false)
        }
        else {
            checkTimeAfterClosingHours()
        }
    }
    
    @objc class func checkTimeAfterClosingHours() {
        let currentDate = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy hh:mm a"
        formatter.timeZone = .current
        formatter.locale = .current
        let currentDateTime = formatter.string(from: currentDate)
            
        Logs.writeLog(onDate: Helper.getCurrentDateAndTime(), andDescription: "Calculated current time is: \(currentDateTime)")
        
        var closingDateTime = ""
        if UserDefaults.storeDetails != nil {
            let closingHour = UserDefaults.storeDetails!.closingHours!
            
            var separatedTime = closingHour.split(separator: " ")
            let time = separatedTime[0].split(separator: ":")
            var newClosingHours = String(Int(time[0])! + 1)
            
            if newClosingHours.count == 1 {
                newClosingHours = "0" + newClosingHours
            }
            
            if newClosingHours == "13" {
                newClosingHours = "01"
            }
            
            let dateFormatter = DateFormatter()
            dateFormatter.locale = .current
            dateFormatter.timeZone = .current
            dateFormatter.dateFormat = "dd/MM/yyyy"
            dateFormatter.amSymbol = "AM"
            dateFormatter.pmSymbol = "PM"
            
            if time[0] == "11" {
                if separatedTime[1] == "AM" {
                    separatedTime[1] = "PM"
                    newClosingHours = newClosingHours + ":" + time[1] + " " + separatedTime[1]
                    print(newClosingHours)
                    
                    closingDateTime = dateFormatter.string(from: Date()) + " " + newClosingHours.lowercased()
                }
                else {
                    separatedTime[1] = "AM"
                    newClosingHours = newClosingHours + ":" + time[1] + " " + separatedTime[1]
                    print(newClosingHours)
                    
                    let yesterdaysDate = closingHour.convertToNextDate(date: dateFormatter.string(from: Date()))
                    closingDateTime = yesterdaysDate + " " + newClosingHours.lowercased()
                }
            }
            else {
                newClosingHours = newClosingHours + ":" + time[1] + " " + separatedTime[1]
                closingDateTime = dateFormatter.string(from: Date()) + " " + newClosingHours.lowercased()
            }
            
            Logs.writeLog(onDate: Helper.getCurrentDateAndTime(), andDescription: "Calculated closing time is: \(closingDateTime)")
            
            print(closingDateTime)
        }
        
        Logs.writeLog(onDate: Helper.getCurrentDateAndTime(), andDescription: "Calculated time difference between current time and closing time is: \(Int(formatter.date(from: currentDateTime)!.timeIntervalSince1970 - formatter.date(from: closingDateTime)!.timeIntervalSince1970) / 60) minutes.")
        
        if (Int(formatter.date(from: currentDateTime)!.timeIntervalSince1970 - formatter.date(from: closingDateTime)!.timeIntervalSince1970) / 60) >= 3 || (Int(formatter.date(from: currentDateTime)!.timeIntervalSince1970 - formatter.date(from: closingDateTime)!.timeIntervalSince1970) / 60) < 0 {
            if isClosingAlertPresent == true {
                if closingHourTimer != nil {
                    closingHourTimer?.invalidate()
                    closingHourTimer = nil
                }
                
                removeAlertFromParent(closingAlert)
                isClosingAlertPresent = false
                logoutUser(from: "after hours")
            }
            else {
                idleTimerAfterClosingHourExceeded()
            }
        }
        else {
            idleTimerAfterClosingHourExceeded()
        }
    }
    
    //MARK: Check for business hours. If current time is after business hours, then show the after hours closing alert.
    class func checkForBusinessHours() {
        let currentDate = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        formatter.timeZone = .current
        formatter.locale = .current
        let currentDateTime = formatter.string(from: currentDate)
        
        var openingDateTime = ""
        
        var closingDateTime = ""
        if UserDefaults.storeDetails != nil {
            let closingHour = UserDefaults.storeDetails!.closingHours!
            let openingHour = UserDefaults.storeDetails!.openingHours!
            openingDateTime = currentDateTime + " " + openingHour.lowercased()
            
            var separatedTime = closingHour.split(separator: " ")
            let time = separatedTime[0].split(separator: ":")
            var newClosingHours = String(Int(time[0])! + 1)
        
            if newClosingHours.count == 1 {
                newClosingHours = "0" + newClosingHours
            }
            
            if newClosingHours == "13" {
                newClosingHours = "01"
            }
            
            let dateFormatter = DateFormatter()
            dateFormatter.locale = .current
            dateFormatter.timeZone = .current
            dateFormatter.dateFormat = "dd/MM/yyyy"
            dateFormatter.amSymbol = "AM"
            dateFormatter.pmSymbol = "PM"
            
            if time[0] == "11" {
                if separatedTime[1] == "AM" {
                    separatedTime[1] = "PM"
                    newClosingHours = newClosingHours + ":" + time[1] + " " + separatedTime[1]
                    print(newClosingHours)
                    
                    closingDateTime = dateFormatter.string(from: Date()) + " " + newClosingHours.lowercased()
                }
                else {
                    separatedTime[1] = "AM"
                    newClosingHours = newClosingHours + ":" + time[1] + " " + separatedTime[1]
                    print(newClosingHours)
                    
                    let nextDate = closingHour.convertToNextDate(date: dateFormatter.string(from: Date()))
                    closingDateTime = nextDate + " " + newClosingHours.lowercased()
                }
            }
            else {
                if newClosingHours == "12" && separatedTime[1] == "AM" {
                    let nextDate = closingHour.convertToNextDate(date: dateFormatter.string(from: Date()))
                    closingDateTime = nextDate + " " + newClosingHours + ":" + time[1] + " " + separatedTime[1].lowercased()
                }
                else {
                    newClosingHours = newClosingHours + ":" + time[1] + " " + separatedTime[1]
                    closingDateTime = dateFormatter.string(from: Date()) + " " + newClosingHours.lowercased()
                }
            }
            print(closingDateTime)
        }
        
        let isWorkingOutSideBusinessHours = closingDateTime.checkTime(currentDate: openingDateTime, nextDate: closingDateTime)
        
        if isWorkingOutSideBusinessHours == true {
            Helper.resetIdleTimerAfterClosingHours()
        }
    }
    
    //MARK: Generate the unique identifier for order
    class func generateUniqueOrderIdentifier() -> String {
        var orderIdentifier = ""
        
        var currentDateTime = Helper.getCurrentDateAndTime()
        currentDateTime = currentDateTime.replacingOccurrences(of: "/", with: "")
        currentDateTime = currentDateTime.replacingOccurrences(of: ":", with: "")
        currentDateTime = currentDateTime.replacingOccurrences(of: " ", with: "")
        orderIdentifier = currentDateTime + String(UserDefaults.deviceID)
        return orderIdentifier
    }
    
    //MARK: Separate products from multiple docket sections
    class func separateProductsForPrintingBasedOnSections(products: [Product]) -> [Product] {
        var separatedProductsBasedOnSection = [Product]()
        for i in 0 ..< products.count {
            let productsAtIndex = products[i]
            for j in 0 ..< productsAtIndex.docketType.count {
                if separatedProductsBasedOnSection.contains(where: {$0.addedProductID! == productsAtIndex.addedProductID! && $0.docketType.first == productsAtIndex.docketType[j]}) {
                    //Don't add product again as it is already present in the array...
                }
                else {
                    var product = productsAtIndex
                    product.docketType = [productsAtIndex.docketType[j]]
                    separatedProductsBasedOnSection.append(product)
                }
            }
        }
        
        if separatedProductsBasedOnSection.count > 0 {
            separatedProductsBasedOnSection.forEach { product in
                for i in 0 ..< product.docketType.count {
                    if selectedSections.contains(where: {$0 == product.docketType[i]}) {
                        break
                    }
                    else if i == product.docketType.count - 1 {
                        separatedProductsBasedOnSection.removeAll(where: {$0 == product})
                    }
                    else {
                        //Keep the loop running...
                    }
                }
            }

            //separatedProductsBasedOnSection.removeAll(where: {$0.docketType != selectedSections})
        }
        
        return separatedProductsBasedOnSection
    }
    
    //MARK: Wrap text based on character limit to display on screen / to print on docket
    class func wrapTextAndDisplay(textData: String) -> String {
        var wrappedText = ""
        var table = textData.split(separator: " ")

        let limit = 20
        var tempString = ""

        var finalResult: [String] = []

        for i in 0 ..< table.count {
            for item in table {
                if tempString.count + item.count < limit {
                    tempString += item + " "
                    if finalResult.isEmpty {
                        finalResult.append(tempString)
                    }
                    else {
                        finalResult[i] = tempString
                    }
                    table.removeAll(where: {$0 == item})
                    
                    if table.count == 0 {
                        break
                    }
                }
                else {
                    tempString = "\n"
                    finalResult.append("")
                    break
                }
            }
        }
        
        if finalResult.count > 0 {
            for j in 0 ..< finalResult.count {
                wrappedText = wrappedText + finalResult[j]
            }
        }
        
        return wrappedText
    }
    
    //MARK: Generate Order Numbers
    class func generateOrderNumbers(orderNo: Int) -> Int {
        var newOrderNumber = 0
        
        let noOfDigits = String(orderNo).count
        
        if noOfDigits == 1 {
            newOrderNumber = Int(String(format: "%03d", orderNo))!
        }
        else if noOfDigits == 2 {
            newOrderNumber = Int(String(format: "%02d", orderNo))!
        }
        else if noOfDigits == 3 {
            newOrderNumber = Int(String(format: "%01d", orderNo))!
        }
        else {
            newOrderNumber = orderNo
        }
        return newOrderNumber
    }
    
    class func generateOrderNumberWithPrefix(orderNo: Int, orderFrom: Int) -> String {
        var newOrderNumber = ""
        let noOfDigits = String(orderNo).count
        if noOfDigits == 1 {
            newOrderNumber = "000" + String(orderNo)
        }
        else if noOfDigits == 2 {
            newOrderNumber = "00" + String(orderNo)
        }
        else if noOfDigits == 3 {
            newOrderNumber = "0" + String(orderNo)
        }
        else {
            newOrderNumber = String(orderNo)
        }
    
        if orderFrom == DeviceIdentification.online.rawValue {
            newOrderNumber = "QO" + newOrderNumber
        }
        else {
            newOrderNumber = "QP" + newOrderNumber
        }
        
        return newOrderNumber
    }
}
