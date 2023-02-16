//
//  DocketSectionsViewController.swift
//  Qiki KDS
//
//  Created by Nirmit Dagly on 30/11/2022.
//

import UIKit

class DocketSectionsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var navBar: UINavigationBar!
    
    @IBOutlet weak var navItem: UINavigationItem!
    
    @IBOutlet weak var btnBack: UIBarButtonItem!
    
    @IBOutlet weak var tblDockets: UITableView!
    
    @IBOutlet weak var lblNoDocketSections: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if docketSections.count == 0 {
            tblDockets.isHidden = true
            lblNoDocketSections.isHidden = false
        }
        else {
            tblDockets.isHidden = false
            lblNoDocketSections.isHidden = true
        }
    }
    
    @IBAction func btnBack_Clicked(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK: Tableview Delegate And Datasource Methods
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if docketSections.count > 0 {
            return docketSections.count
        }
        else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DocketSection", for: indexPath)
        
        let lblSectionName = cell.viewWithTag(10) as! UILabel
        lblSectionName.text = docketSections[indexPath.row]
        
        if selectedSections.count > 0 {
            if selectedSections.contains(where: {$0 == docketSections[indexPath.row]}) {
                cell.accessoryType = .checkmark
            }
            else {
                cell.accessoryType = .none
            }
        }
        else {
            cell.accessoryType = .none
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if selectedSections.contains(where: {$0 == docketSections[indexPath.row]}) {
            selectedSections.removeAll(where: {$0 == docketSections[indexPath.row]})
        }
        else {
            selectedSections.append(docketSections[indexPath.row])
        }
        UserDefaults.selectedDocketSections = selectedSections
        tblDockets.reloadData()
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        selectedSections.removeAll(where: {$0 == docketSections[indexPath.row]})
        UserDefaults.selectedDocketSections = selectedSections
        tblDockets.reloadData()
    }
}
