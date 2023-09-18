//
//  HistoryOrdersViewController.swift
//  Qiki KDS
//
//  Created by Nirmit Dagly on 2/12/2022.
//

import UIKit
import AlignedCollectionViewFlowLayout

class HistoryOrdersViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var navBar: UINavigationBar!
    
    @IBOutlet weak var btnBack: UIBarButtonItem!
    
    @IBOutlet weak var pastOrderView: UICollectionView!
    
    @IBOutlet weak var lblNoDocketSections: UILabel!
    
    var orders = [Order]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let layout = AlignedCollectionViewFlowLayout()
        layout.horizontalAlignment = .justified
        layout.verticalAlignment = .top
        layout.estimatedItemSize = CGSize(width: 320, height: 500)
        layout.itemSize = UICollectionViewFlowLayout.automaticSize
        layout.sectionInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10
        pastOrderView.collectionViewLayout = layout
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if UserDefaults.selectedDocketSections != nil && UserDefaults.selectedDocketSections!.count > 0 {
            lblNoDocketSections.isHidden = true
            if Helper.isNetworkReachable() {
                getCompletedOrders()
            }
            else {
                Logs.writeLog(onDate: Helper.getCurrentDateAndTime(), andDescription: "Device is not connected to internet.")
                Helper.presentInternetError(viewController: self)
            }
        }
        else {
            lblNoDocketSections.text = "You need to setup docket sections first.\n\nYou can select desired sections from:\n 'Settings -> Docket Sections'"
            lblNoDocketSections.isHidden = false
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        
    }
    
    @IBAction func btnBack_Clicked(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnActiveOrder_Clicked(_ sender: UIButton) {
        var superview = sender.superview
        while let view = superview, !(view is ActiveOrderCell) {
            superview = view.superview
        }
        guard let cell = superview as? ActiveOrderCell else {
            print("button is not contained in a table view cell")
            return
        }
        guard let indexPath = pastOrderView.indexPath(for: cell) else {
            print("failed to get index path for cell containing button")
            return
        }
        
        print(indexPath.row)
        
        var sectionOfProducts = [String]()
        for i in 0 ..< self.orders[indexPath.row].products.count {
            let dockets = self.orders[indexPath.row].products[i].docketType
            for j in 0 ..< dockets.count {
                if sectionOfProducts.contains(where: {$0 == dockets[j]}) {
                    //Don't add docket section again
                }
                else {
                    sectionOfProducts.append(dockets[j])
                }
            }
        }
        
        self.markOrderAsActive(forOrderNo: self.orders[indexPath.row].orderNo, andSequenceNo: self.orders[indexPath.row].sequenceNo, withProductSections: sectionOfProducts)
    }
    
    //MARK: TableView Delegate and Data Source Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if orders[tableView.tag].products.count > 0 {
            return orders[tableView.tag].products.count
        }
        else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProductCell", for: indexPath) as! ProductCell
        cell.lblProduct.attributedText = productsAndDetails(product: orders[tableView.tag].products[indexPath.row])
        cell.imgCheckmark.isHidden = true
        cell.imgCheckmarkWidthConstraint.constant = 0
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    
    //MARK: Collectionview Data Source and Delegate Methods
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if orders.count > 0 {
            return orders.count
        }
        else {
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ActiveOrderCell", for: indexPath) as! ActiveOrderCell
        
        cell.lblOrderType.text = orders[indexPath.row].deliveryType.rawValue
        
        switch orders[indexPath.row].deliveryType {
            case .pickup:
                let customerName = orders[indexPath.row].customerName.replacingOccurrences(of: " Customer", with: "")
                if customerName == "Guest" {
                    cell.lblOrderMethod.text = ""
                }
                else {
                    cell.lblOrderMethod.text = "\(customerName)"
                }
                
                if orders[indexPath.row].deliveryType == DeliveryType.pickup {
                    if orders[indexPath.row].orderOrigin != DeviceIdentification.online.rawValue {
                        cell.lblOrderType.text = cell.lblOrderType.text! + ": ASAP"
                    }
                    else {
                        let pickuptime = orders[indexPath.row].pickupTime?.toDate(by: "h:mm a") ?? ""
                        cell.lblOrderType.text = cell.lblOrderType.text! + ": \(pickuptime)"
                    }
                }
            case .dineIn:
                cell.lblOrderMethod.text = "Table #: " + orders[indexPath.row].tableNo!
                
                if orders[indexPath.row].tabNumber != nil && orders[indexPath.row].tabNumber != 1 {
                    cell.lblOrderMethod.text = cell.lblOrderMethod.text! + "-" + "\(orders[indexPath.row].tabNumber!)"
                }
                
                if orders[indexPath.row].tabName != nil && orders[indexPath.row].tabName != "" {
                    cell.lblOrderMethod.text = cell.lblOrderMethod.text! + "-" + "\(orders[indexPath.row].tabName!)"
                }
            case .delivery:
                cell.lblOrderMethod.text = ""
        }
        
        cell.lblOrderNumber.text = "\(Helper.generateOrderNumberWithPrefix(orderNo: orders[indexPath.row].terminalOrderNo, orderFrom: orders[indexPath.row].orderOrigin))"
        
        cell.btnActiveOrder.layer.cornerRadius = 7
        cell.btnActiveOrder.layer.borderWidth = 1
        cell.btnActiveOrder.layer.borderColor = #colorLiteral(red: 0.3254901961, green: 0.3607843137, blue: 0.8156862745, alpha: 0.3674473036).cgColor
        
        cell.lblTimer.isHidden = true
        cell.lblTimerHeightConstraint.constant = 0
        
        cell.btnMarkPriority.isHidden = true
        cell.btnMarkPriorityHeightConstraint.constant = 0
        
        cell.tblProducts.delegate = self
        cell.tblProducts.dataSource = self
        cell.tblProducts.rowHeight = UITableView.automaticDimension
        cell.tblProducts.estimatedRowHeight = 50
        
        cell.tblProducts.tag = indexPath.row
        cell.tblProducts.reloadData()
        
        if cell.tblProducts.contentSize.height <= 50 {
            cell.tblProductsHeightConstraint.constant = 60
        }
        else if cell.tblProducts.contentSize.height > 50 && cell.tblProducts.contentSize.height <= 100 {
            cell.tblProductsHeightConstraint.constant = 110
        }
        else {
            cell.tblProductsHeightConstraint.constant = cell.tblProducts.contentSize.height
        }
        cell.tblProducts.setNeedsLayout()
        
        cell.layer.cornerRadius = 7
        cell.layer.borderWidth = 1
        cell.layer.borderColor = #colorLiteral(red: 0.3254901961, green: 0.3607843137, blue: 0.8156862745, alpha: 0.3674473036).cgColor

        cell.contentView.layoutIfNeeded()
        return cell
    }
    
    //MARK: This function will fecth the completed orders of the current date.
    func getCompletedOrders() {
        OrderServices.shared.getHistoryOrders(orderStatus: "History") { result in
            switch result {
                case .failure(let error):
                    print("Failed to get history orders...")
                    Logs.writeLog(onDate: Helper.getCurrentDateAndTime(), andDescription: "\(error)")
                    
                    Helper.loadingSpinner(isLoading: false, isUserInteractionEnabled: true, withMessage: "")
                    Helper.presentAlert(viewController: self, title: "Something Went Wrong (Error code: \(Helper.errorForAPI(APIErrorCode.getOrders_History)))", message: error.localizedDescription)
                case .success(let resp):
                    if resp.orders.count > 0 {
                        self.orders = resp.orders
                        for i in 0 ..< self.orders.count {
                            if self.orders[i].deletedProducts != nil && self.orders[i].deletedProducts!.count > 0 {
                                for j in 0 ..< self.orders[i].deletedProducts!.count {
                                    self.orders[i].deletedProducts![j].isDeleted = 1
                                }
                                self.orders[i].products = self.orders[i].products + self.orders[i].deletedProducts!
                            }
                        }
                            
//                        if UserDefaults.selectedDocketSections != nil && UserDefaults.selectedDocketSections!.contains("Terminal") {
//                                //Don't remove any products from order, as the Section is selected as 'Terminal'. Hence, all items will be displayed here...
//                        }
//                        else {
                            self.filterOrdersToDisplay()
//                        }
                    }
                    self.pastOrderView.reloadData()
            }
        }
    }
    
    //MARK: Filter Orders based on selected sections to display
    func filterOrdersToDisplay() {
        for i in 0 ..< self.orders.count {
            var productsOfOrder = self.orders[i].products
            productsOfOrder.forEach { product in
                for i in 0 ..< product.docketType.count {
                    if selectedSections.contains(where: {$0 == product.docketType[i]}) {
                        break
                    }
                    else if i == product.docketType.count - 1 {
                        productsOfOrder.removeAll(where: {$0 == product})
                    }
                    else {
                            //Keep the loop running...
                    }
                }
            }
            
            if productsOfOrder.count > 0 {
                self.orders[i].products = productsOfOrder
            }
            else {
                self.orders[i].products = [Product]()
            }
        }
        
        for j in 0 ..< self.orders.count {
            if self.orders[j].products.count > 0 {
                var removeDeliveredProducts = [Product]()
                
                for m in 0 ..< self.orders[j].products.count {
                    if self.orders[j].products[m].isDelivered != nil && self.orders[j].products[m].isDelivered != 1 {
                        removeDeliveredProducts.append(self.orders[j].products[m])
                    }
                }
                
                if removeDeliveredProducts.count == self.orders[j].products.count {
                    //self.orders[i].products = [Product]()
                    
                    let tempOrder = self.orders[j]
                    self.orders.remove(at: j)
                    self.orders.append(tempOrder)
                }
            }
            else {
                break
            }
        }
        
        orders.removeAll(where: {$0.products.count == 0})
    }
    
    //MARK: To mark order as completed.
    func markOrderAsActive(forOrderNo orderNo: Int, andSequenceNo seqNo: Int, withProductSections sections: [String]) {
        OrderServices.shared.markOrderAsActive(forOrderNumber: orderNo, andSequenceNo: seqNo, withProductSections: sections) { result in
            switch result {
                case .failure(let error):
                    print("Failed to mark order \(orderNo) as active...")
                    Logs.writeLog(onDate: Helper.getCurrentDateAndTime(), andDescription: "\(error)")
                    
                    Helper.presentAlert(viewController: self, title: "Something Went Wrong (Error code: \(Helper.errorForAPI(APIErrorCode.markAsActive)))", message: error.localizedDescription)
                    
                case .success(_):
                    print("Order successfully marked as active...")
                    Logs.writeLog(onDate: Helper.getCurrentDateAndTime(), andDescription: "Order No: \(orderNo) has been marked as active successfully...")
                    
                    self.orders.removeAll(where: {$0.orderNo == orderNo && $0.sequenceNo == seqNo})
                    self.pastOrderView.reloadData()
            }
        }
    }
    
    //MARK: This function will create a product string with dietary requirements to be displayed on screen.
    func productsAndDetails(product: Product) -> NSMutableAttributedString {
        let orderDetails = NSMutableAttributedString.init()
        let productName = product.name
        let dietryReq = product.dietary
        let isDeleted = product.isDeleted
        
        let updatedProductName = NSMutableAttributedString.init()
        
        let productWithOptions = productName.components(separatedBy: "-")
        let productNameWithQuantity = NSMutableAttributedString.init(string: "\(product.qty) X \(productWithOptions[0])\n")
        
        if isDeleted == 1 {
            productNameWithQuantity.addAttributes([NSAttributedString.Key.strikethroughStyle: NSUnderlineStyle.thick.rawValue,
                                                   NSAttributedString.Key.strikethroughColor: UIColor.darkGray],
                                                  range: NSMakeRange(0, productNameWithQuantity.length))
        }
        
        let productAttributes = NSMutableAttributedString.init()
        if product.attributes != nil && product.attributes!.count > 0 {
            for j in 0 ..< product.attributes!.count {
                let attribute = NSMutableAttributedString.init(string: "   - \(product.attributes![j].name)\n")
                productAttributes.append(attribute)
            }
        }
        
        if isDeleted == 1 {
            productAttributes.addAttributes([NSAttributedString.Key.strikethroughStyle: NSUnderlineStyle.thick.rawValue,
                                             NSAttributedString.Key.strikethroughColor: UIColor.darkGray],
                                            range: NSMakeRange(0, productAttributes.length))
        }
        
        let dietaryReq = NSMutableAttributedString.init()
        if dietryReq != "" {
            let dietary = NSMutableAttributedString.init(string: "Dietary Requirements: ")
            let requirement = NSMutableAttributedString.init(string: "\(dietryReq)\n")
            
            if isDeleted == 1 {
                requirement.addAttributes([NSAttributedString.Key.strikethroughStyle: NSUnderlineStyle.thick.rawValue,
                                           NSAttributedString.Key.strikethroughColor: UIColor.darkGray],
                                          range: NSMakeRange(0, requirement.length))
            }
            dietaryReq.append(dietary)
            dietaryReq.append(requirement)
        }
        
        updatedProductName.append(productNameWithQuantity)
        updatedProductName.append(productAttributes)
        updatedProductName.append(dietaryReq)
        orderDetails.append(updatedProductName)
        
        return orderDetails
    }
    
    func heightForLabel(text: NSMutableAttributedString, font:UIFont, width:CGFloat) -> UILabel {
        // pass string, font, LableWidth
        let label: UILabel = UILabel(frame: CGRect(x: 10, y: 0, width: width, height: CGFloat.greatestFiniteMagnitude))
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.font = font
        label.attributedText = text
        label.sizeToFit()
        label.frame = CGRect(x: 10, y: 0, width: width, height: label.frame.height)
        return label
    }
}
