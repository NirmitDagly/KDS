//
//  AppDelegate.swift
//  Qiki KDS
//
//  Created by Nirmit Dagly on 29/11/2022.
//

import Foundation
import UIKit
import UserNotifications
import IQKeyboardManagerSwift
import SDWebImage

class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    
    var deviceTokenString: String = ""
    let userDefaults = UserDefaults.standard
    var navigationController: UINavigationController = UINavigationController()
//    var homeViewController: HomeViewController = HomeViewController()
    var window: UIWindow?
    
    var orientationLock = UIInterfaceOrientationMask.all
    
    struct AppUtility {
        static func lockOrientation(_ orientation: UIInterfaceOrientationMask) {
            if let delegate = UIApplication.shared.delegate as? AppDelegate {
                delegate.orientationLock = orientation
            }
        }
        
        static func lockOrientation(_ orientation: UIInterfaceOrientationMask, andRotateTo rotateOrientation:UIInterfaceOrientation) {
            self.lockOrientation(orientation)
            UIDevice.current.setValue(rotateOrientation.rawValue, forKey: "orientation")
        }
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        print("Device UUID is: \(deviceUUID)")
        print("Device Token String is: \(UserDefaults.deviceTokenString)")
        
        if UIDevice.current.userInterfaceIdiom == .phone {
            sb = iphoneSb
        }

        //Override point for customization after application launch.
        UIApplication.shared.isIdleTimerDisabled = true
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) {
            (granted, error) in
            guard granted else {
                UserDefaults.deviceTokenString = ""
                return
            }
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
        IQKeyboardManager.shared.enable = true
        
        UIBarButtonItem.appearance().setTitleTextAttributes([NSAttributedString.Key.font: UIFont.init().customFont(withWeight: .medium, withSize: 18)], for: UIControl.State.normal)

        UIBarButtonItem.appearance().setTitleTextAttributes([NSAttributedString.Key.font: UIFont.init().customFont(withWeight: .medium, withSize: 18)], for: UIControl.State.selected)
        
        self.window = UIWindow(frame: UIScreen.main.bounds)
        let loginController = sb.instantiateViewController(identifier: "LoginViewController") as! LoginViewController
        navigationController = UINavigationController.init(rootViewController: loginController)
        self.window?.rootViewController = navigationController
        self.window?.makeKeyAndVisible()
        
        return true
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        var orientation2: UIInterfaceOrientation = .landscapeRight
        if UserDefaults.isLandscapeLeft == true {
            orientation = .landscapeLeft
            orientation2 = .landscapeLeft
        }
        else {
            orientation = .landscapeRight
            orientation2 = .landscapeRight
        }
        
        AppDelegate.AppUtility.lockOrientation(orientation, andRotateTo: orientation2)
        
        let current = UNUserNotificationCenter.current()
        current.getNotificationSettings(completionHandler: { (settings) in
            if settings.authorizationStatus == .notDetermined {
                // Notification permission has not been asked yet, go for it!
            }
            else if settings.authorizationStatus == .denied {
                // Notification permission was previously denied, go to settings & privacy to re-enable
            }
            else if settings.authorizationStatus == .authorized {
                //User has granted permission to receive push notification but we still have to assoicate device token on back end
                if UserDefaults.isDeviceTokenRegistered == false && UserDefaults.isLoggedIn == true {
                    DispatchQueue.main.async {
                        UIApplication.shared.registerForRemoteNotifications()
                    }
                }
            }
        })
        application.applicationIconBadgeNumber = 0
        
//        if UserDefaults.isLoggedIn == true {
//            if dbHelper != nil {
//                let currentAppAndBuildVersion = dbHelper!.readVersionAndBuildNumber()
//                if versionNumber! + " (" + buildNumber! + ")" == currentAppAndBuildVersion {
//                    //Current app version and build numbers are same... hence the database is already migrated to the newest version...
//                }
//                else {
//                    dbHelper!.updateDataIntoUser(username: UserDefaults.token!.username, apiKey: UserDefaults.token!.apiKey, qikiSite: UserDefaults.token!.qikiSite, appVersion: versionNumber!, buildVersion: buildNumber!)
//                    dbHelper!.migrateData(forVersionNumber: versionNumber!, andBuildNumber: buildNumber!)
//                }
//                Helper.deleteYesterdaysOrders()
//            }
//        }
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
    }
        
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        deviceTokenString = deviceToken.hexString
        UserDefaults.deviceTokenString = deviceTokenString
        print(deviceTokenString)
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("I am not available in simulator :( \(error)")
    }
    
    //For iOS10 use these methods and  pay attention how we can get userInfo
    // Foreground push notifications handler
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        print(userInfo)
    }
    
    // Background and closed push notifications handler
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping() -> Void)  {
        print(response)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        print(userInfo)
    }
}
