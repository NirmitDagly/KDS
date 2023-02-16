//
//  BasicPopupViewController.swift
//  Qiki Cusine
//
//  Created by Michael Inati on 15/3/2022.
//

import Foundation
import UIKit

class BasicPopupViewController: UIViewController {
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblMessage: UILabel!
    @IBOutlet weak var btnOk: UIButton!
    
    var popupTitle = ""
    var popupMessage = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        lblTitle.text = popupTitle
        lblMessage.text = popupMessage
        btnOk.layer.borderWidth = 2
        btnOk.layer.borderColor = .qikiColor
    }
    
    override func viewDidAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidTimeOut), name: .applicationDidTimoutNotification, object: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: .applicationDidTimoutNotification, object: nil)
    }
    
    @objc func applicationDidTimeOut() {
        self.dismiss(animated: false, completion: nil)
    }
    
    @IBAction func btnOkPressed(_ sender: Any) {
        self.dismiss(animated: false, completion: nil)
    }
    
    @IBAction func btnOkTouchDown(_ sender: Any) {
        btnOk.backgroundColor = .qikiColor
        btnOk.setTitleColor(.white, for: .normal)
    }
    
    @IBAction func btnOkTouchUpOutside(_ sender: Any) {
        btnOk.backgroundColor = .white
        btnOk.setTitleColor(.qikiColor, for: .normal)
    }
}
