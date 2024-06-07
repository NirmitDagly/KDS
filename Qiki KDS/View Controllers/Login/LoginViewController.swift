//
//  LoginViewController.swift
//  Qiki KDS
//
//  Created by Nirmit Dagly on 29/11/2022.
//

import Foundation
import UIKit
import Alamofire
import SDWebImage

class LoginViewController: UIViewController, UITextFieldDelegate, UIScrollViewDelegate {
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var imgLogo: UIImageView!
    
    @IBOutlet weak var lblUserName: UILabel!
    @IBOutlet weak var txtUserName: UITextField!
    @IBOutlet weak var userNameDividerView: UIView!
    
    @IBOutlet weak var lblPassword: UILabel!
    @IBOutlet weak var txtPassword: UITextField!
    @IBOutlet weak var btnShowHidePassword: UIButton!
    @IBOutlet weak var passwordDividerView: UIView!
    
    @IBOutlet weak var loginDetailsView: UIView!
    @IBOutlet weak var loginDetailsImageView: UIImageView!
    @IBOutlet weak var btnLoginDetails: UIButton!
    
    @IBOutlet weak var btnSignIn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if UIDevice.current.orientation == .portrait || UIDevice.current.orientation == .portraitUpsideDown {
            UIDevice.current.setValue(UIInterfaceOrientation.landscapeLeft.rawValue, forKey: "orientation")
            AppUtility.lockOrientation(.landscape)
        }
        
//        txtUserName.text = "hospitality"
//        txtPassword.text = "rasmuslerdorf"
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        
        btnSignIn.layer.borderColor = UIColor.qikiColor.cgColor
        btnSignIn.layer.borderWidth = 2
        btnSignIn.layer.cornerRadius = 7
        
        if UserDefaults.isLoggedIn == true && UserDefaults.userName != nil {
            registerDevice(userName: UserDefaults.userName!)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.isNavigationBarHidden = true
        
        if UserDefaults.isLoggedIn {
            isLoggedinFirstTime = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                
            }
        }
        
        if UserDefaults.rememberLoginDetails == true && UserDefaults.token != nil && UserDefaults.token!.username != "" && UserDefaults.password != "" {
            txtUserName.text = UserDefaults.token!.username
            txtPassword.text = UserDefaults.password
            loginDetailsImageView.image = UIImage.init(systemName: "checkmark.circle.fill")!
        }
        else {
            txtUserName.text = ""
            txtPassword.text = ""
            
            loginDetailsImageView.image = UIImage.init(systemName: "circle")!
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollView.contentOffset.x = 0
    }
    
    @objc func adjustForKeyboard(notification: Notification) {
        guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        
        let keyboardScreenEndFrame = keyboardValue.cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)
        
        if notification.name == UIResponder.keyboardWillHideNotification {
            scrollView.contentInset = .zero
        }
        else {
            scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height - view.safeAreaInsets.bottom, right: 0)
        }
        
        scrollView.scrollIndicatorInsets = scrollView.contentInset
    }
    
        //MARK: Text Field Delegate Methods
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == txtUserName {
            textField.resignFirstResponder()
            txtPassword.becomeFirstResponder()
        }
        else if textField == txtPassword {
            textField.resignFirstResponder()
        }
        return true
    }
    
    @IBAction func btnShowHidePassword_Clicked(_ sender: Any) {
        if btnShowHidePassword.image(for: .normal) == UIImage.init(named: "QikiEyeClosed")! {
            btnShowHidePassword.setImage(UIImage.init(named: "QikiEyeOpen")!, for: .normal)
            txtPassword.isSecureTextEntry = true
        }
        else {
            btnShowHidePassword.setImage(UIImage.init(named: "QikiEyeClosed")!, for: .normal)
            txtPassword.isSecureTextEntry = false
        }
    }
    
    @IBAction func btnLoginDetails_Clicked(_ sender: Any) {
        if loginDetailsImageView.image == UIImage.init(systemName: "circle")! {
            loginDetailsImageView.image = UIImage.init(systemName: "checkmark.circle.fill")!
            UserDefaults.rememberLoginDetails = true
        }
        else {
            loginDetailsImageView.image = UIImage.init(systemName: "circle")!
            UserDefaults.rememberLoginDetails = false
        }
    }
    
    @IBAction func btnSignIn_Clicked(_ sender: Any) {
        loginPressed()
    }
    
    func loginPressed() {
        if txtUserName.text == "" && txtPassword.text == "" {
            Helper.presentAlert(viewController: self, title: "Something Went Wrong", message: requiredFieldMessage + "\n User Name \n Password")
        }
        else if txtUserName.text == "" {
            Helper.presentAlert(viewController: self, title: "Something Went Wrong", message: requiredFieldMessage + "\n User Name")
        }
        else if txtPassword.text == "" {
            Helper.presentAlert(viewController: self, title: "Something Went Wrong", message: requiredFieldMessage + "\n Password")
        }
        else {
            if Helper.isNetworkReachable() {
                let updatedAppVersionNumber = Helper.getAppVersionNumber()
                Helper.loadingSpinner(isLoading: true, isUserInteractionEnabled: false, withMessage: "Logging In...")
                LoginService.shared.login(username: txtUserName.text!, password: txtPassword.text!, appVersion: updatedAppVersionNumber, completion: {
                    result in
                    switch result {
                        case .failure(let error):
                            Helper.loadingSpinner(isLoading: false, isUserInteractionEnabled: false, withMessage: "")
                            Logs.writeLog(onDate: Helper.getCurrentDateAndTime(), andDescription: error.localizedDescription)
                            Helper.presentAlert(viewController: self, title: "Something Went Wrong (Error code: \(Helper.errorForAPI(APIErrorCode.login)))", message: error.localizedDescription)
                        case .success(_):
                            self.loginSuccess()
                    }
                })
            }
            else {
                Logs.writeLog(onDate: Helper.getCurrentDateAndTime(), andDescription: "Device is not connected to internet.")
                Helper.presentInternetError(viewController: self)
            }
        }
    }
    
    func loginSuccess() {
        UserDefaults.userName = txtUserName.text
        UserDefaults.password = txtPassword.text
        
        posID = UserDefaults.token?.username ?? "Admin"
        if UserDefaults.lastLogoutDate != nil {
            if UserDefaults.lastLogoutDate != Date().toString(format: "dd-MM-yyyy") {
                isLoggedinFirstTime = true
            }
            else {
                isLoggedinFirstTime = false
            }
        }
        else {
            isLoggedinFirstTime = false
        }
        
        registerDevice(userName: self.txtUserName.text!)
    }
    
    func registerDevice(userName: String) {
        if Helper.isNetworkReachable() {
            Helper.loadingSpinner(isLoading: true, isUserInteractionEnabled: false, withMessage: "Syncing Data...")
            CommonService.shared.registerDevice(username: userName, deviceToken: UserDefaults.deviceTokenString) { result in
                switch result {
                    case .failure(let error):
                        print("Failed to register device: \(error)")
                        Logs.writeLog(onDate: Helper.getCurrentDateAndTime(), andDescription: "Failed to register device because: \(error).")
                        
                        Helper.loadingSpinner(isLoading: false, isUserInteractionEnabled: true, withMessage: "")
                        Helper.presentAlert(viewController: self, title: "Something Went Wrong (Error code: \(Helper.errorForAPI(APIErrorCode.deviceRegister)))", message: error.localizedDescription)
                        
                        UserDefaults.isDeviceTokenRegistered = false
                    case .success(let resp):
                        UserDefaults.isDeviceTokenRegistered = true
                        UserDefaults.deviceID = resp.deviceID
                        deviceID = resp.deviceID
                        posID = (UserDefaults.token?.username ?? "Admin") + String(UserDefaults.deviceID)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                            self.getStoreDetails()
                        }
                }
            }
        }
        else {
            Logs.writeLog(onDate: Helper.getCurrentDateAndTime(), andDescription: "Device is not connected to internet.")
            Helper.loadingSpinner(isLoading: false, isUserInteractionEnabled: false, withMessage: "")
            Helper.presentInternetError(viewController: self)
        }
    }
    
    func getStoreDetails() {
        if Helper.isNetworkReachable() {
            CommonService.shared.getStoreDetails {result in
                switch result {
                case .failure(let error):
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        print("Failed to get store details...")
                        Logs.writeLog(onDate: Helper.getCurrentDateAndTime(), andDescription: "\(error)")

                        Helper.loadingSpinner(isLoading: false, isUserInteractionEnabled: true, withMessage: "")
                        Helper.presentAlert(viewController: self, title: "Something Went Wrong (Error code: \(Helper.errorForAPI(APIErrorCode.getStoreDetails)))", message: error.localizedDescription)
                    }
                case .success(let resp):
                    Logs.writeLog(onDate: Helper.getCurrentDateAndTime(), andDescription: "Received response is:\n Store Details: \(String(describing: resp.storeDetails)) \n IsMainTerminal: \(String(describing: resp.isMainTerminal))\n Device ID: \(resp.deviceID ?? 0)\n")
                    Helper.loadingSpinner(isLoading: false, isUserInteractionEnabled: true, withMessage: "")

                    if resp.success == 1 {
                        Helper.scheduleTimerToUploadLogFile()

                        if resp.storeDetails != nil {
                            UserDefaults.storeDetails = resp.storeDetails
                            Helper.startLogoutTimer()
                            Helper.checkForBusinessHours()
                        }

                        if resp.isMainTerminal != nil {
                            UserDefaults.isMainTerminal = resp.isMainTerminal! == 1 ? true : false
                        }

                        if resp.deviceID != nil {
                            UserDefaults.deviceID = resp.deviceID!
                            deviceID = resp.deviceID!
                        }
                        
                        self.getDocketSections()
                    }
                    else if resp.success == 2 && resp.isMainTerminal != nil && resp.isMainTerminal! == 0 {
                        Helper.presentAlert(viewController: self, title: "ALERT", message: "The system has detected that you are running different application version than main POS terminal. Make sure the application version is same on every device(s). \n\nYou can check version of application by clicking on Settings (5th Tab) and Scroll down to bottom.")
                    }
                }
            }
        }
        else {
            Helper.loadingSpinner(isLoading: false, isUserInteractionEnabled: true, withMessage: "")
            Logs.writeLog(onDate: Helper.getCurrentDateAndTime(), andDescription: "Device is not connected to internet.")
            Helper.presentInternetError(viewController: self)
        }
    }
    
    func getDocketSections() {
        if Helper.isNetworkReachable() {
            CommonService.shared.getDocketSections {result in
                switch result {
                    case .failure(let error):
                        print("Failed to get docket sections...")
                        Logs.writeLog(onDate: Helper.getCurrentDateAndTime(), andDescription: "\(error)")
                            
                        Helper.loadingSpinner(isLoading: false, isUserInteractionEnabled: true, withMessage: "")
                        Helper.presentAlert(viewController: self, title: "Something Went Wrong (Error code: \(Helper.errorForAPI(APIErrorCode.getDocketSection)))", message: error.localizedDescription)
                    case .success(let resp):
                        for i in 0 ..< resp.dockets.count {
                            docketSections.append(resp.dockets[i].docket)
                        }
                        
                        if UserDefaults.selectedDocketSections != nil && UserDefaults.selectedDocketSections!.count > 0 {
                            for i in 0 ..< UserDefaults.selectedDocketSections!.count {
                                if !docketSections.contains(UserDefaults.selectedDocketSections![i]) {
                                    UserDefaults.selectedDocketSections!.remove(at: i)
                                }
                            }
                            
                            if UserDefaults.selectedDocketSections!.count > 0 {
                                selectedSections = UserDefaults.selectedDocketSections!
                            }
                            else {
                                selectedSections = [String]()
                            }
                        }

                        let ordersViewController: ActiveOrdersViewController = sb.instantiateViewController(withIdentifier: "ActiveOrdersViewController") as! ActiveOrdersViewController
                        self.navigationController?.pushViewController(ordersViewController, animated: true)
                }
            }
        }
        else {
            Helper.loadingSpinner(isLoading: false, isUserInteractionEnabled: true, withMessage: "")
            Logs.writeLog(onDate: Helper.getCurrentDateAndTime(), andDescription: "Device is not connected to internet.")
            Helper.presentInternetError(viewController: self)
        }
    }
}
