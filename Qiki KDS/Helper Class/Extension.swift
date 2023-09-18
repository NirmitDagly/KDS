//
//  Extension.swift
//  Qiki KDS
//
//  Created by Nirmit Dagly on 29/11/2022.
//

import Foundation
import UIKit
import Alamofire

extension UIApplication {
    func topViewController() -> UIViewController? {
        var topViewController: UIViewController? = nil
        if #available(iOS 13, *) {
            for scene in connectedScenes {
                if let windowScene = scene as? UIWindowScene {
                    for window in windowScene.windows {
                        if window.isKeyWindow {
                            topViewController = window.rootViewController
                        }
                    }
                }
            }
        }
        else {
            topViewController = keyWindow?.rootViewController
        }
        while true {
            if let presented = topViewController?.presentedViewController {
                topViewController = presented
            }
            else if let navController = topViewController as? UINavigationController {
                topViewController = navController.topViewController
            }
            else if let tabBarController = topViewController as? UITabBarController {
                topViewController = tabBarController.selectedViewController
            }
            else {
                // Handle any other third party container in `else if` if required
                break
            }
        }
        return topViewController
    }
    
    static var appVersion: String {
        let versionNumber = Bundle.main.infoDictionary?[Constants.InfoPlist.versionNumber] as? String
        let buildNumber = Bundle.main.infoDictionary?[Constants.InfoPlist.buildNumber] as? String
        
        let formattedBuildNumber = buildNumber.map {
            return "(\($0))"
        }
        
        return [versionNumber, formattedBuildNumber].compactMap { $0 }.joined(separator: " ")
    }
}

extension Double {
    func rounded(toPlaces places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}

extension CGFloat {
    init(string: String) {
        let number = NumberFormatter().number(from: string)
        self.init(number?.floatValue ?? 0.00)
    }
}

extension Data {
    var hexString: String {
        let hexString = map {
            String(format: "%02.2hhx", $0)}.joined()
        return hexString
    }
}

extension NSNotification.Name {
    static let applicationDidTimoutNotification = NSNotification.Name("AppTimout")
    static let orientationChanged = UIDevice.orientationDidChangeNotification
}

extension UIColor {
    static let qikiColor = UIColor(named: "QikiColor")!
    static let qikiColorSelected = UIColor(named: "QikiColorSelected")!
    static let qikiColorDisabled = UIColor(named: "QikiColorDisabled")!
    static let qikiGreen = UIColor(named: "QikiGreen")!
    static let qikiGreenSelected = UIColor(named: "QikiGreenSelected")!
    static let qikiYellow = UIColor(named: "QikiYellow")!
    static let qikiYellowSelected = UIColor(named: "QikiYellowSelected")!
    static let qikiRed = UIColor(named: "QikiRed")!
    static let qikiRedSelected = UIColor(named: "QikiRedSelected")!
}

extension CGColor {
    static let qikiColor: CGColor = UIColor(named: "QikiColor")!.cgColor
    static let qikiColorSelected: CGColor = UIColor(named: "QikiColorSelected")!.cgColor
    static let qikiColorDisabled: CGColor = UIColor(named: "QikiColorDisabled")!.cgColor
    static let qikiGreen: CGColor = UIColor(named: "QikiGreen")!.cgColor
    static let qikiGreenSelected: CGColor = UIColor(named: "QikiGreenSelected")!.cgColor
    static let qikiYellow: CGColor = UIColor(named: "QikiYellow")!.cgColor
    static let qikiYellowSelected: CGColor = UIColor(named: "QikiYellowSelected")!.cgColor
    static let qikiRed: CGColor = UIColor(named: "QikiRed")!.cgColor
    static let qikiRedSelected: CGColor = UIColor(named: "QikiRedSelected")!.cgColor
}

extension Array where Element: Hashable {
    func difference(from other: [Element]) -> [Element] {
        let thisSet = Set(self)
        let otherSet = Set(other)
        return Array(thisSet.subtracting(otherSet))
    }
}

extension URLRequest {
  private func percentEscapeString(_ string: Any) -> String {
    var characterSet = CharacterSet.alphanumerics
    characterSet.insert(charactersIn: "-._* ")
    
      return (string as AnyObject)
      .addingPercentEncoding(withAllowedCharacters: characterSet)!
      .replacingOccurrences(of: " ", with: "+")
      .replacingOccurrences(of: " ", with: "+", options: [], range: nil)
  }
  
  mutating func encodeParameters(parameters: [String : Any]) {
    httpMethod = "POST"
    
    let parameterArray = parameters.map { (arg) -> String in
      let (key, value) = arg
      return "\(key)=\(self.percentEscapeString(value))"
    }
    
    httpBody = parameterArray.joined(separator: "&").data(using: String.Encoding.utf8)
  }
}

extension URL {
    var attributes: [FileAttributeKey : Any]? {
        do {
            return try FileManager.default.attributesOfItem(atPath: path)
        } catch let error as NSError {
            print("FileAttribute error: \(error)")
        }
        return nil
    }

    var fileSize: UInt64 {
        return attributes?[.size] as? UInt64 ?? UInt64(0)
    }

    var fileSizeString: String {
        return ByteCountFormatter.string(fromByteCount: Int64(fileSize), countStyle: .file)
    }

    var creationDate: Date? {
        return attributes?[.creationDate] as? Date
    }
}

extension UICollectionView {
    func scrollToNextItem() {
        let contentOffset = CGFloat(floor(self.contentOffset.x + self.bounds.size.width))
        self.moveToFrame(contentOffset: contentOffset)
    }
    
    func scrollToPreviousItem() {
        let contentOffset = CGFloat(floor(self.contentOffset.x - self.bounds.size.width))
        self.moveToFrame(contentOffset: contentOffset)
    }
    
    func moveToFrame(contentOffset : CGFloat) {
        self.setContentOffset(CGPoint(x: contentOffset, y: self.contentOffset.y), animated: true)
    }
}

extension String {
    func sliceByCharacter(from: Character, to: Character) -> String? {
        let fromIndex = self.index(self.firstIndex(of: from)!, offsetBy: 1)
        let toIndex = self.index(self.firstIndex(of: to)!, offsetBy: -1)
        return String(self[fromIndex...toIndex])
    }
    
    func sliceByString(from:String, to:String) -> String? {
        //From - startIndex
        var range = self.range(of: from)
        let subString = String(self[range!.upperBound...])
        
        //To - endIndex
        range = subString.range(of: to)
        return String(subString[..<range!.lowerBound])
    }
    
    func convertToNextDate(date: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        dateFormatter.locale = .current
        dateFormatter.timeZone = .current
        dateFormatter.amSymbol = "AM"
        dateFormatter.pmSymbol = "PM"
        dateFormatter.calendar = Calendar(identifier: .gregorian)
        
        let myDate = dateFormatter.date(from: date)!
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: myDate)
        return dateFormatter.string(from: tomorrow!)
    }
    
    func convertToYesterdaysDate(date: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        dateFormatter.locale = .current
        dateFormatter.timeZone = .current
        dateFormatter.amSymbol = "AM"
        dateFormatter.pmSymbol = "PM"
        dateFormatter.calendar = Calendar(identifier: .gregorian)
        
        let myDate = dateFormatter.date(from: date)!
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: myDate)
        return dateFormatter.string(from: yesterday!)
    }
    
    func UTCToLocal(date:String, fromFormat: String, toFormat: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = fromFormat
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")

        let dt = dateFormatter.date(from: date)
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.dateFormat = toFormat

        return dateFormatter.string(from: dt!)
    }
    
    func compareTime(closingHours: String) -> Bool {
        let formatter = DateFormatter()
        formatter.locale = .current
        formatter.dateFormat = "hh:mm a"
        formatter.amSymbol = "AM"
        formatter.pmSymbol = "PM"
        let timeString = formatter.string(from: Date())

        let firstTime = formatter.date(from: closingHours)
        let secondTime = formatter.date(from: timeString)

        if firstTime?.compare(secondTime!) == .orderedAscending {
            return false
        }
        else if firstTime?.compare(secondTime!) == .orderedSame {
            return true
        }
        else {
            return true
        }
    }
    
    func checkTime(currentDate: String, nextDate: String) -> Bool {
        let dateFormatter: DateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy hh:mm a"
        dateFormatter.timeZone = .current
        dateFormatter.locale = Locale(identifier: "en_AU")
        dateFormatter.timeZone = TimeZone(abbreviation: "Australia/Sydney")

        let date = Date()
        let date1: Date = dateFormatter.date(from: currentDate)!
        let date2: Date = dateFormatter.date(from: nextDate)!

        let currentTime = 60*Calendar.current.component(.hour, from: date) + Calendar.current.component(.minute, from: date) + (Calendar.current.component(.second, from: date)/60) // in minutes
        let time1 = 60*Calendar.current.component(.hour, from: date1) + Calendar.current.component(.minute, from: date1) + (Calendar.current.component(.second, from: date1)/60) // in minutes
        let time2 =  60*Calendar.current.component(.hour, from: date2) + Calendar.current.component(.minute, from: date2) + (Calendar.current.component(.second, from: date2)/60) // in minutes

        print(currentTime)
        print(time1)
        print(time2)
        
        let df: DateFormatter = DateFormatter()
        df.dateFormat = "dd/MM/yyyy"
        dateFormatter.timeZone = .current
        dateFormatter.locale = Locale(identifier: "en_AU")
        dateFormatter.timeZone = TimeZone(abbreviation: "Australia/Sydney")

        let currentDateOnly = Date()
        let currentDateWithFormat = df.string(from: currentDateOnly)
        let currentDateOnly1 = df.date(from: currentDateWithFormat)!
        
        let currentDateToModify = currentDate.split(separator: " ")
        let date1Only = df.date(from: String(currentDateToModify[0]))!
        
        let nextDatetoModify = nextDate.split(separator: " ")
        let date2Only = df.date(from: String(nextDatetoModify[0]))!
        
        print(currentDateOnly1)
        print(date1Only)
        print(date2Only)
        
        if (date2Only.compare(currentDateOnly1) == .orderedDescending && currentTime >= time1 && (time2 <= (currentTime + 1))) || (currentDateOnly1.compare(date2Only) == .orderedSame && currentTime >= time1 && ((currentTime + 1) <= time2)) {
            Logs.writeLog(onDate: Helper.getCurrentDateAndTime(), andDescription: "Venue is operating in business hours...")
            print("Venue is operating in business hours...")
            return false
        }
        else {
            Logs.writeLog(onDate: Helper.getCurrentDateAndTime(), andDescription: "Venue is operating outside business hours...")
            print("Venue is operating outside business hours...")
            return true
        }
    }
}


extension Date {
    func toString(includeTime: Bool = false) -> String {
        var format = ""
        if (includeTime) {
            format = "dd/MM/yyyy hh:mm a"
        } else {
            format = "dd/MM/yyyy"
        }
        return toString(format: format)
    }
    
    func toString(format: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self)
    }
    
    func compare(date1: Date, date2: Date) -> DateOrder {
        switch date1.compare(date2) {
        case .orderedSame:
            return DateOrder.same
        case .orderedAscending:
            return DateOrder.ascending
        case .orderedDescending:
            return DateOrder.descending
        }
    }
    
    func timeDifference(lhs: Date, rhs: Date) -> TimeInterval {
        return lhs.timeIntervalSinceReferenceDate - rhs.timeIntervalSinceReferenceDate
    }
}

extension UIFont {
    func customFont(withWeight weight: FontWeight, withSize size: CGFloat) -> UIFont {
        switch weight {
            case .regular:
                return UIFont(name: "AvenirNext-Regular", size: size)!
            case .medium:
                return UIFont(name: "AvenirNext-Medium", size: size)!
            case .demibold:
                return UIFont(name: "AvenirNext-DemiBold", size: size)!
            case .bold:
                return UIFont(name: "AvenirNext-Bold", size: size)!
            case .heavy:
                return UIFont(name: "AvenirNext-Heavy", size: size)!
        }
    }
}

extension Int {
    func toDate(by format: String = "dd/MM/yyyy") -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        dateFormatter.locale = Locale(identifier: "en_AU")
        dateFormatter.timeZone = TimeZone(abbreviation: "Australia/Sydney")
        dateFormatter.amSymbol = "AM"
        dateFormatter.pmSymbol = "PM"
        dateFormatter.calendar = Calendar(identifier: .gregorian)
        let date = Date(timeIntervalSince1970: TimeInterval(self))
        return dateFormatter.string(from: date)
    }

}
