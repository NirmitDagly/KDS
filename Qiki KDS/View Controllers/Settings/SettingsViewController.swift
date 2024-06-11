//
//  SettingsViewController.swift
//  Qiki KDS
//
//  Created by Nirmit Dagly on 30/11/2022.
//

import UIKit
import Foundation
import NDT7

class SettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var navBar: UINavigationBar!
    
    @IBOutlet weak var btnBack: UIBarButtonItem!
    
    @IBOutlet weak var tblSettings: UITableView!
    
    var ndt7Test: NDT7Test?
    var downloadTestRunning: Bool = false
    var uploadTestRunning: Bool = false
    var downloadSpeed: Double?
    var uploadSpeed: Double?
    var enableAppData = true
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        
    }
    
    @IBAction func btnBack_Clicked(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK: TableView Delegate And Datasource Methods
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            return 3
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "POS Options"
        }
        else if section == 1 {
            return "Information"
        }
        else {
            return "Other"
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SettingOptions", for: indexPath)
        
        if indexPath.section == 0 {
            let imgView = cell.viewWithTag(10) as! UIImageView
            imgView.image = UIImage.init(systemName: "doc.circle.fill")
            
            let lblOption = cell.viewWithTag(11) as! UILabel
            lblOption.text = "Docket Options"
        }
        else if indexPath.section == 1 {
            if indexPath.row == 0 {
                let imgView = cell.viewWithTag(10) as! UIImageView
                imgView.image = UIImage.init(systemName: "at")
                
                let lblOption = cell.viewWithTag(11) as! UILabel
                lblOption.text = "Contact Us"
            }
            else if indexPath.row == 1 {
                let imgView = cell.viewWithTag(10) as! UIImageView
                imgView.image = UIImage.init(systemName: "lock.shield.fill")
                
                let lblOption = cell.viewWithTag(11) as! UILabel
                lblOption.text = "Privacy Policy"
            }
            else {
                let imgView = cell.viewWithTag(10) as! UIImageView
                imgView.image = UIImage.init(systemName: "doc.text.fill")
                
                let lblOption = cell.viewWithTag(11) as! UILabel
                lblOption.text = "Terms and conditions"
            }
        }
        else {
            if indexPath.row == 0 {
                let imgView = cell.viewWithTag(10) as! UIImageView
                imgView.image = UIImage.init(systemName: "arrow.up.arrow.down.circle.fill")
                
                let lblOption = cell.viewWithTag(11) as! UILabel
                lblOption.text = "Speed Test"
            }
            else if indexPath.row == 1 {
                let imgView = cell.viewWithTag(10) as! UIImageView
                imgView.image = UIImage.init(systemName: "arrow.up.doc.fill")
                
                let lblOption = cell.viewWithTag(11) as! UILabel
                lblOption.text = "Send Logs"
            }
            else {
                let imgView = cell.viewWithTag(10) as! UIImageView
                imgView.image = UIImage.init(systemName: "arrow.right.circle.fill")
                
                let lblOption = cell.viewWithTag(11) as! UILabel
                lblOption.text = "Logout"
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                print("Docket option pressed...")
                let docketSectionViewController: DocketSectionsViewController = sb.instantiateViewController(withIdentifier: "DocketSectionsViewController") as! DocketSectionsViewController
                navigationController?.pushViewController(docketSectionViewController, animated: true)
            }
        }
        else if indexPath.section == 1 {
            if indexPath.row == 0 {
                Helper.presentAlert(viewController: self, title: "Contact Us", message: "For 24 hour assistance call:\n 1300 642 633.")
            }
            else if indexPath.row == 1 {
                if Helper.isNetworkReachable() {
                    let vc = sb.instantiateViewController(identifier: "WebViewController") as WebViewController
                    vc.siteToShow = "privacy"
                    navigationController?.pushViewController(vc, animated: true)
                }
                else {
                    Logs.writeLog(onDate: Helper.getCurrentDateAndTime(), andDescription: "Device is not connected to internet.")
                    Helper.presentInternetError(viewController: self)
                }
            }
            else {
                if Helper.isNetworkReachable() {
                    let vc = sb.instantiateViewController(identifier: "WebViewController") as WebViewController
                    vc.siteToShow = "terms"
                    navigationController?.pushViewController(vc, animated: true)
                }
                else {
                    Logs.writeLog(onDate: Helper.getCurrentDateAndTime(), andDescription: "Device is not connected to internet.")
                    Helper.presentInternetError(viewController: self)
                }
            }
        }
        else {
            if indexPath.row == 0 {
                startTest()
            }
            else if indexPath.row == 1 {
                sendLogs()
            }
            else {
                logOutUser()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 2 {
            return 50
        }
        else {
            return 10
        }
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if section == 2 {
            let lblAppVersion: UILabel = UILabel.init(frame: CGRect.init(x: 0, y: 15, width: self.view.frame.width, height: 40))
            
            lblAppVersion.text = appVersion
            lblAppVersion.textColor = .lightGray
            lblAppVersion.textAlignment = .center
            
            return lblAppVersion
        }
        else {
            let lblAppVersion: UILabel = UILabel.init()
            return lblAppVersion
        }
    }
    
    //MARK: Internet Speed Test
    func startTest() {
        Helper.loadingSpinner(isLoading: true, isUserInteractionEnabled: true, withMessage: "Speed Test is in progress...")
        
        let settings = NDT7Settings()
        ndt7Test = NDT7Test(settings: settings)
        ndt7Test?.delegate = self
        statusUpdate(downloadTestRunning: true, uploadTestRunning: true)
        ndt7Test?.startTest(download: true, upload: true) { [weak self] (error) in
            guard let strongSelf = self else { return }
            
            DispatchQueue.main.async {
                if let error = error {
                    print("Error during speed test: \(error)...")
                    Helper.loadingSpinner(isLoading: false, isUserInteractionEnabled: true, withMessage: "")
                    Logs.writeLog(onDate: Helper.getCurrentDateAndTime(), andDescription: "Error during internet speed test: \(error)")
                }
                else {
                    strongSelf.statusUpdate(downloadTestRunning: false, uploadTestRunning: false)
                    Helper.loadingSpinner(isLoading: false, isUserInteractionEnabled: true, withMessage: "")
                    Helper.presentAlert(viewController: self!, title: "ALERT", message: "Internet speed test has been finished and the results has been logged. \n\nIf you have been asked to share the results, click on 'Send Logs' button.")
                }
            }
        }
    }
    
    func cancelTest() {
        ndt7Test?.cancel()
        statusUpdate(downloadTestRunning: false, uploadTestRunning: false)
        Helper.presentAlert(viewController: self, title: "ALERT", message: "There is an error occurred while testing internet speed. Please try again.")
    }

    func statusUpdate(downloadTestRunning: Bool?, uploadTestRunning: Bool?) {
        if let downloadTestRunning = downloadTestRunning {
            self.downloadTestRunning = downloadTestRunning
        }
        
        if let uploadTestRunning = uploadTestRunning {
            self.uploadTestRunning = uploadTestRunning
        }
    }
    
    //MARK: Send logs to server
    func sendLogs() {
        if Helper.isNetworkReachable() {
            Helper.loadingSpinner(isLoading: true, isUserInteractionEnabled: false, withMessage: "")
            LogService.shared.sendLogFile { result in
                switch result {
                    case .failure(let error):
                        Helper.loadingSpinner(isLoading: false, isUserInteractionEnabled: true, withMessage: "")
                        Helper.presentAlert(viewController: self, title: "Something Went Wrong (Error code: \(Helper.errorForAPI(APIErrorCode.uploadLogFile)))", message: error.localizedDescription)

                    case .success(_):
                        Helper.loadingSpinner(isLoading: false, isUserInteractionEnabled: true, withMessage: "")
                        Helper.presentAlert(viewController: self, title: "Success", message: "Log file sent!")
                }
            }
        }
        else {
            sessionActive = false
            Logs.writeLog(onDate: Helper.getCurrentDateAndTime(), andDescription: "Device is not connected to internet.")
            Helper.presentInternetError(viewController: self)
        }
    }
    
    //MARK: Logout User
    func logOutUser() {
        Helper.logoutUser(from: "")
    }
}

extension SettingsViewController: NDT7TestInteraction {
    
    func test(kind: NDT7TestConstants.Kind, running: Bool) {
        switch kind {
        case .download:
            downloadTestRunning = running
        case .upload:
            uploadTestRunning = running
            statusUpdate(downloadTestRunning: nil, uploadTestRunning: running)
        }
    }

    func measurement(origin: NDT7TestConstants.Origin, kind: NDT7TestConstants.Kind, measurement: NDT7Measurement) {
        if let server = ndt7Test?.settings.currentServer {
            print(server.machine)
            if let serverCountry = server.location?.country, let serverCity = server.location?.city
            {
                Logs.writeLog(onDate: Helper.getCurrentDateAndTime(), andDescription: "To measure the internet speed, we're using server: \(server.machine) which is located in: \(serverCity), \(serverCountry)")
            }
        }

        if origin == .client, enableAppData,
            let elapsedTime = measurement.appInfo?.elapsedTime,
            let numBytes = measurement.appInfo?.numBytes,
            elapsedTime >= 1000000 {
            let seconds = elapsedTime / 1000000
            let mbit = numBytes / 125000
            let rounded = Double(Float64(mbit)/Float64(seconds)).rounded(toPlaces: 1)
            switch kind {
            case .download:
                downloadSpeed = rounded
                DispatchQueue.main.async {
                    Logs.writeLog(onDate: Helper.getCurrentDateAndTime(), andDescription: "Download speed is: \(rounded) Mbit/s")
                }
            case .upload:
                uploadSpeed = rounded
                DispatchQueue.main.async {
                    Logs.writeLog(onDate: Helper.getCurrentDateAndTime(), andDescription: "Upload speed is: \(rounded) Mbit/s")
                }
            }
        }
        else if origin == .server,
            let elapsedTime = measurement.tcpInfo?.elapsedTime,
            elapsedTime >= 1000000 {
            let seconds = elapsedTime / 1000000
            switch kind {
            case .download:
                if let numBytes = measurement.tcpInfo?.bytesSent {
                    let mbit = numBytes / 125000
                    let rounded = Double(Float64(mbit)/Float64(seconds)).rounded(toPlaces: 1)
                    downloadSpeed = rounded
                    DispatchQueue.main.async {
                        Logs.writeLog(onDate: Helper.getCurrentDateAndTime(), andDescription: "Download speed is: \(rounded) Mbit/s")
                    }
                }
            case .upload:
                if let numBytes = measurement.tcpInfo?.bytesReceived {
                    let mbit = numBytes / 125000
                    let rounded = Double(Float64(mbit)/Float64(seconds)).rounded(toPlaces: 1)
                    uploadSpeed = rounded
                    DispatchQueue.main.async {
                        Logs.writeLog(onDate: Helper.getCurrentDateAndTime(), andDescription: "Upload speed is: \(rounded) Mbit/s")
                    }
                }
            }
        }
    }

    func error(kind: NDT7TestConstants.Kind, error: NSError) {
        cancelTest()
    }

    func errorAlert(title: String, message: String) {
        DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self else { return }
            let alert = UIAlertController(title: title, message: "\(message)", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            strongSelf.present(alert, animated: true)
        }
    }
    
    func decimalArray(from firstInt: Double, to secondInt: Double) -> [Double] {
        var firstInt = firstInt
        var array: [Double] = []
        if firstInt == secondInt {
            array.insert(firstInt, at: 0)
        }
        else if firstInt > secondInt {
            let decimals = (firstInt - secondInt) / 10
            while firstInt >= secondInt {
                array.append(firstInt.rounded(toPlaces: 1))
                firstInt -= decimals
            }
        }
        else if secondInt > firstInt {
            let decimals = (secondInt - firstInt) / 10
            while secondInt >= firstInt {
                array.append(firstInt.rounded(toPlaces: 1))
                firstInt += decimals
            }
        }
        return array
    }
}
