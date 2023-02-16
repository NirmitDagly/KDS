//
//  WebViewController.swift
//  Qiki KDS
//
//  Created by Nirmit Dagly on 30/11/2022.
//

import UIKit
import WebKit
import NVActivityIndicatorView

/// This class will show the custom URLs on web page within the application. At this moment, it is showing Signup, Delivery Tracking, User guide, Terms & Condition and Privacy Policy.
class WebViewController: UIViewController, WKNavigationDelegate {
   
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var lblNavigationTitle: UINavigationItem!
    @IBOutlet weak var btnBack: UIBarButtonItem!
    
    @IBOutlet weak var webView: WKWebView!
    
    var siteToShow: String!
    var trackingUrl: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let url: URL!
        
        if siteToShow == "userguides" {
            lblNavigationTitle.title =  "User Guide"
            url = URL(string: "https://www.qiki.com.au/user-guide")!
        }
        else if siteToShow == "privacy" {
            lblNavigationTitle.title = "Privacy Policy"
            url = URL(string: "https://www.qiki.com.au/content/2-privacy-policy")!
        }
        else if siteToShow == "terms" {
            lblNavigationTitle.title = "Terms and Conditions"
            url = URL(string: "https://www.qiki.com.au/content/3-terms-and-conditions")!
        }
        else {
            url = URL(string: "")!
        }
        
        webView.isHidden = false
        webView.navigationDelegate = self
        webView.load(URLRequest(url: url))
        webView.allowsBackForwardNavigationGestures = true
        
        Helper.loadingSpinner(isLoading: true, isUserInteractionEnabled: true, withMessage: "")
    }
    
    @IBAction func btnBackPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
        Helper.loadingSpinner(isLoading: false, isUserInteractionEnabled: true, withMessage: "")
    }
    
    //WebView Delegate Methods
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        Helper.loadingSpinner(isLoading: false, isUserInteractionEnabled: true, withMessage: "")
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        Helper.loadingSpinner(isLoading: false, isUserInteractionEnabled: true, withMessage: "")
        Helper.presentAlert(viewController: self, title: "Something Went Wrong", message: error.localizedDescription)
    }
}
