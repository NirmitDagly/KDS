//
//  ActiveOrdersViewController.swift
//  Qiki KDS
//
//  Created by Nirmit Dagly on 16/12/2022.
//
//Perform commit and push

import UIKit
import AlignedCollectionViewFlowLayout

class ActiveOrderCell: UICollectionViewCell {
    
    @IBOutlet var orderOverView: UIView!
    
    @IBOutlet var lblOrderType: UILabel!
    
    @IBOutlet var lblOrderMethod: UILabel!
    
    @IBOutlet var lblOrderNumber: UILabel!
    
    @IBOutlet var btnActiveOrder: UIButton!
    
    @IBOutlet var lblTimer: UILabel!
    
    @IBOutlet var lblTimerHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet var btnMarkPriority: UIButton!
    
    @IBOutlet var btnMarkPriorityHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet var tblProducts: UITableView!
    
    @IBOutlet var tblProductsHeightConstraint: NSLayoutConstraint!
}

class ProductCell: UITableViewCell {
    @IBOutlet var imgCheckmark: UIImageView!
    @IBOutlet var lblProduct: UILabel!
    @IBOutlet var imgCheckmarkWidthConstraint: NSLayoutConstraint!
}

class SummaryCell: UITableViewCell {
    @IBOutlet weak var lblNotification: UIImageView!
    @IBOutlet weak var lblProductSummary: UILabel!
    @IBOutlet var imgNotificationWidthConstraint: NSLayoutConstraint!
}

class ActiveOrdersViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate  {
    
    @IBOutlet weak var navBar: UINavigationBar!
    
    @IBOutlet weak var btnProductSummary: UIBarButtonItem!
    
    @IBOutlet weak var btnSettings: UIBarButtonItem!
    
    @IBOutlet weak var btnPastOrders: UIBarButtonItem!
   
    @IBOutlet weak var activeOrderView: UICollectionView!
    
    @IBOutlet weak var activeOrderViewLeadingConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var lblNoDocketSections: UILabel!
    
    @IBOutlet weak var tblProductSummary: UITableView!
    
    var orders = [Order]()
    
    var tableOnTimer: Timer?
    
    var productSummary = [[String: Any]]()
    
    var displayProducts = [Product]()

    override func viewDidLoad() {
        super.viewDidLoad()

        tblProductSummary.layer.cornerRadius = 5
        tblProductSummary.layer.borderWidth = 1
        tblProductSummary.layer.borderColor = .qikiColorDisabled
        
        tblProductSummary.rowHeight = UITableView.automaticDimension
        tblProductSummary.estimatedRowHeight = 80
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if UserDefaults.selectedDocketSections != nil && UserDefaults.selectedDocketSections!.count > 0 {
            let layout = AlignedCollectionViewFlowLayout()
            layout.horizontalAlignment = .justified
            layout.verticalAlignment = .top
            layout.estimatedItemSize = CGSize(width: 320, height: 500)
            layout.itemSize = UICollectionViewFlowLayout.automaticSize
            layout.sectionInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
            layout.minimumLineSpacing = 10
            layout.minimumInteritemSpacing = 10
            activeOrderView.collectionViewLayout = layout

            activeOrderView.isHidden = false
            lblNoDocketSections.isHidden = true
            if Helper.isNetworkReachable() {
                getActiveOrders()
            }
            else {
                Logs.writeLog(onDate: Helper.getCurrentDateAndTime(), andDescription: "Device is not connected to internet.")
                Helper.presentInternetError(viewController: self)
            }
        }
        else {
            activeOrderView.isHidden = true
            
            lblNoDocketSections.text = "You need to setup docket sections first.\n\nYou can select desired sections from:\n 'Settings -> Docket Sections'"
            lblNoDocketSections.isHidden = false
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        invalidateTimer()
    }
    
    @IBAction func btnProductSummary_Clicked(_ sender: Any) {
        if tblProductSummary.isHidden == true {
            self.tblProductSummary.isHidden = false
            activeOrderViewLeadingConstraint.constant = 320
        }
        else {
            self.tblProductSummary.isHidden = true
            activeOrderViewLeadingConstraint.constant = 0
        }
    }
    
    @IBAction func btnSettings_Clicked(_ sender: Any) {
        let settingsViewController: SettingsViewController = sb.instantiateViewController(withIdentifier: "SettingsViewController") as! SettingsViewController
        self.navigationController?.pushViewController(settingsViewController, animated: true)
    }
    
    @IBAction func btnPastOrders_Clicked(_ sender: Any) {
        let historyOrdersViewController: HistoryOrdersViewController = sb.instantiateViewController(withIdentifier: "HistoryOrdersViewController") as! HistoryOrdersViewController
        self.navigationController?.pushViewController(historyOrdersViewController, animated: true)
    }
    
    @IBAction func btnActiveOrder_Clicked(_ sender: UIButton) {
        var superview = sender.superview
        while let view = superview, !(view is ActiveOrderCell) {
            superview = view.superview
        }
        guard let cell = superview as? ActiveOrderCell else {
            print("button is not contained in a collection view cell")
            return
        }
        guard let indexPath = activeOrderView.indexPath(for: cell) else {
            print("failed to get index path for cell containing button")
            return
        }
        
        if Helper.isNetworkReachable() {
            if self.orders[indexPath.row].products.count > 0 {
                let allProducts = self.orders[indexPath.row].products
                
                var addedProductIDs = [Int]()
                for i in 0 ..< allProducts.count {
                    addedProductIDs.append(allProducts[i].addedProductID!)
                }
                
                self.markOrderAsCompleted(forOrderNo: self.orders[indexPath.row].orderNo, andSequenceNo: self.orders[indexPath.row].sequenceNo, andAddedProductIDs: addedProductIDs)
            }
        }
        else {
            Logs.writeLog(onDate: Helper.getCurrentDateAndTime(), andDescription: "Device is not connected to internet.")
        }
    }
    
    @IBAction func btnMarkPriority_Clicked(_ sender: UIButton) {
        var superview = sender.superview
        while let view = superview, !(view is ActiveOrderCell) {
            superview = view.superview
        }
        guard let cell = superview as? ActiveOrderCell else {
            print("button is not contained in a collection view cell")
            return
        }
        guard let indexPath = activeOrderView.indexPath(for: cell) else {
            print("failed to get index path for cell containing button")
            return
        }
        
        orders[indexPath.row].isUrgent = 1
        let order = orders[indexPath.row]
        if Helper.isNetworkReachable() {
            markOrderAsUrgent(forOrderNo: order.orderNo, andSequenceNo: order.sequenceNo)
        }
        else {
            Logs.writeLog(onDate: Helper.getCurrentDateAndTime(), andDescription: "Device is not connected to internet.")
            Helper.presentInternetError(viewController: self)
        }
        
        orders.remove(at: indexPath.row)
        orders.insert(order, at: 0)

        activeOrderView.reloadData()
    }

    //MARK: TableView Delegate and Data Source Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == tblProductSummary {
            if productSummary.count > 0 {
                return productSummary.count
            }
            else {
                return 0
            }
        }
        else {
            if orders[tableView.tag].products.count > 0 {
                return orders[tableView.tag].products.count
            }
            else {
                return 0
            }
        }
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView == tblProductSummary {
            return 80
        }
        else {
            return 100
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == tblProductSummary {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SummaryCell", for: indexPath) as! SummaryCell
            let productSummaryDetails = formattedProductSummary(forProductSummary: productSummary[indexPath.row])
            
            cell.lblProductSummary.text = (productSummaryDetails["productName"] as! String)

            if productSummaryDetails["hasDietary"] as! Bool == false {
                cell.lblNotification.isHidden = true
                cell.imgNotificationWidthConstraint.constant = 0
            }
            else {
                cell.lblNotification.isHidden = false
                cell.imgNotificationWidthConstraint.constant = 25
            }
            
            let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(showDietary))
            tapGesture.delegate = self
            tapGesture.numberOfTapsRequired = 1
            tapGesture.numberOfTouchesRequired = 1
            cell.lblNotification.addGestureRecognizer(tapGesture)
            
            cell.lblNotification.tag = indexPath.row
            
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ProductCell", for: indexPath) as! ProductCell
            cell.lblProduct.attributedText = productsAndDetails(product: orders[tableView.tag].products[indexPath.row])
            
            if orders[tableView.tag].products[indexPath.row].isDeleted == 1 {
                cell.imgCheckmark.isHidden = true
            }
            else {
                if orders[tableView.tag].products[indexPath.row].isDelivered ?? 0 == 1 {
                    cell.imgCheckmark.image = UIImage.init(systemName: "checkmark.circle.fill")
                }
                else {
                    cell.imgCheckmark.image = UIImage.init(systemName: "checkmark.circle")
                }
                cell.imgCheckmark.isHidden = false
            }

            cell.contentView.sizeToFit()
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView != tblProductSummary {
            print(orders[tableView.tag].products[indexPath.row].name)
            
            if orders[tableView.tag].products[indexPath.row].isDelivered ?? 0 == 1 {
                orders[tableView.tag].products[indexPath.row].isDelivered = 0
                if Helper.isNetworkReachable() {
                    markIndividualItemAsDelivered(forOrderNo: orders[tableView.tag].orderNo, andSequenceNo: orders[tableView.tag].sequenceNo, andAddedProductID: orders[tableView.tag].products[indexPath.row].addedProductID!, andSection: orders[tableView.tag].products[indexPath.row].docketType[0], andIsDelivered: 0)
                }
                else {
                    Helper.presentInternetError(viewController: self)
                }
            }
            else {
                orders[tableView.tag].products[indexPath.row].isDelivered = 1
                if Helper.isNetworkReachable() {
                    markIndividualItemAsDelivered(forOrderNo: orders[tableView.tag].orderNo, andSequenceNo: orders[tableView.tag].sequenceNo, andAddedProductID: orders[tableView.tag].products[indexPath.row].addedProductID!, andSection: orders[tableView.tag].products[indexPath.row].docketType[0], andIsDelivered: 1)
                }
                else {
                    Helper.presentInternetError(viewController: self)
                }
            }
        }
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
            case .dineIn:
                cell.lblOrderMethod.text = "Table #: " + orders[indexPath.row].tableNo!
                
                if orders[indexPath.row].tabNumber != nil && orders[indexPath.row].tabNumber != 1 {
                    cell.lblOrderMethod.text = cell.lblOrderMethod.text! + "-" + "\(orders[indexPath.row].tabNumber!)"
                }
                
                if orders[indexPath.row].tabName != nil && orders[indexPath.row].tabName != ""  {
                    cell.lblOrderMethod.text = cell.lblOrderMethod.text! + "-" + "\(orders[indexPath.row].tabName!)"
                }
            case .delivery:
                cell.lblOrderMethod.text = ""
        }
        
        cell.lblOrderNumber.text = "\(Helper.generateOrderNumberWithPrefix(orderNo: orders[indexPath.row].terminalOrderNo, orderFrom: orders[indexPath.row].orderOrigin))"
        
        cell.btnActiveOrder.setTitle("Mark Delivered", for: .normal)
        cell.btnActiveOrder.layer.cornerRadius = 7
        cell.btnActiveOrder.layer.borderWidth = 1
        cell.btnActiveOrder.layer.borderColor = #colorLiteral(red: 0.3254901961, green: 0.3607843137, blue: 0.8156862745, alpha: 0.3674473036).cgColor
        
        if orders[indexPath.row].dateAdded != nil {
            cell.lblTimerHeightConstraint.constant = 30
        }
        else {
            cell.lblTimer.isHidden = true
            cell.lblTimerHeightConstraint.constant = 0
        }
        
        cell.btnMarkPriority.setTitle("Mark Urgent", for: .normal)
        cell.btnMarkPriorityHeightConstraint.constant = 40
        
        cell.btnMarkPriority.layer.cornerRadius = 7
        cell.btnMarkPriority.layer.borderWidth = 1
        cell.btnMarkPriority.layer.borderColor = #colorLiteral(red: 0.3254901961, green: 0.3607843137, blue: 0.8156862745, alpha: 0.3674473036).cgColor
        
        cell.tblProducts.delegate = self
        cell.tblProducts.dataSource = self

        cell.tblProducts.tag = indexPath.row
        cell.tblProducts.reloadData()
        cell.tblProducts.layoutIfNeeded()

        if cell.tblProducts.contentSize.height <= 50 {
            cell.tblProducts.frame.size.height = 60
            cell.tblProductsHeightConstraint.constant = 60
        }
        else if cell.tblProducts.contentSize.height > 50 && cell.tblProducts.contentSize.height <= 100 {
            cell.tblProducts.frame.size.height = 110
            cell.tblProductsHeightConstraint.constant = 110
        }
        else {
            cell.tblProducts.frame.size.height = cell.tblProducts.contentSize.height
            cell.tblProductsHeightConstraint.constant = cell.tblProducts.contentSize.height
        }
        cell.tblProducts.setNeedsLayout()
            
        cell.layer.cornerRadius = 7
        cell.layer.borderWidth = 1
        cell.layer.borderColor = #colorLiteral(red: 0.3254901961, green: 0.3607843137, blue: 0.8156862745, alpha: 0.3674473036).cgColor
        
        cell.contentView.layoutIfNeeded()
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let cell = cell as? ActiveOrderCell {
            let timeDetails = updateTimeForTables(forOrder: orders[indexPath.row])
            cell.lblTimer.text = (timeDetails["timeToDisplay"] as! String)
            cell.lblTimer.isHidden = false
            
            if timeDetails["isExceededTime"] as! Bool == true && (orders[indexPath.row].isUrgent == 0) {
                cell.orderOverView.backgroundColor = .red
                cell.lblOrderType.textColor = .white
                cell.lblOrderMethod.textColor = .white
                cell.lblOrderNumber.textColor = .white
                cell.lblTimer.textColor = .white
                
                cell.btnMarkPriority.isHidden = false
            }
            else if orders[indexPath.row].isUrgent == 1 {
                cell.orderOverView.backgroundColor = .red
                cell.lblOrderType.textColor = .white
                cell.lblOrderMethod.textColor = .white
                cell.lblOrderNumber.textColor = .white
                cell.lblTimer.textColor = .white
                
                cell.btnMarkPriority.isHidden = true
            }
            else {
                cell.orderOverView.backgroundColor = .qikiGreen
                cell.lblOrderType.textColor = .black
                cell.lblOrderMethod.textColor = .black
                cell.lblOrderNumber.textColor = .black
                cell.lblTimer.textColor = .black
                
                cell.btnMarkPriority.isHidden = false
            }
        }
    }

    //MARK: This function will create a product string with dietary requirements to be displayed on screen.
    func productsAndDetails(product: Product) -> NSMutableAttributedString {
        let orderDetails = NSMutableAttributedString.init()
        
//        for i in 0 ..< product.count {
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
//        }
        
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
    
    //MARK: Combine Product to display on the card
    func combineProductForOrderDisplay() {
        for i in 0 ..< orders.count {
            var combinedProductsToDisplay = [Product]()
            for k in 0 ..< orders[i].products.count {
                let productName = orders[i].products[k].name
                let qty = orders[i].products[k].qty
                let dietary = orders[i].products[k].dietary
                
                if combinedProductsToDisplay.contains(where: {$0.name == productName && $0.dietary == dietary}) {
                    for j in 0 ..< combinedProductsToDisplay.count {
                        if combinedProductsToDisplay[j].name == productName && combinedProductsToDisplay[j].dietary == dietary
                        {
                            combinedProductsToDisplay[j].qty = combinedProductsToDisplay[j].qty + qty
                            break
                        }
                    }
                }
                else {
                    combinedProductsToDisplay.append(orders[i].products[k])
                }
            }
            self.orders[i].products = combinedProductsToDisplay
        }
    }
    
    //MARK: Combine Products to display the product summary
    func combineProductsForSummaryDisplay() -> [[String: Any]] {
        productSummary = [[String: Any]]()
        
        for i in 0 ..< orders.count {
            for k in 0 ..< orders[i].products.count {
                if i == 0 && k == 0 {
                    let productName = orders[i].products[k].name
                    let qty = orders[i].products[k].qty
                    let dietary = orders[i].products[k].dietary
                    let isDeleted = orders[i].products[k].isDeleted
                    
                    if isDeleted == 0 {
                        let summary: [String: Any] = ["productName": productName, "qty": qty, "dietary": dietary]
                        productSummary.append(summary)
                    }
                }
                else {
                    let productName = orders[i].products[k].name
                    let qty = orders[i].products[k].qty
                    let dietary = orders[i].products[k].dietary
                    let isDeleted = orders[i].products[k].isDeleted
                    
                    if isDeleted == 0 {
                        if productSummary.contains(where: {($0["productName"] as! String == productName) && ($0["dietary"] as! String == dietary)}) {
                            for j in 0 ..< productSummary.count {
                                if productSummary[j]["productName"] as! String == productName && productSummary[j]["dietary"] as! String == dietary {
                                    productSummary[j]["qty"] = productSummary[j]["qty"] as! Int + qty
                                    break
                                }
                            }
                        }
                        else {
                            let summary: [String: Any] = ["productName": productName, "qty": qty, "dietary": dietary]
                            productSummary.append(summary)
                        }
                    }
                }
            }
        }
        productSummary = productSummary.sorted(by: {$0["qty"] as! Int > $1["qty"] as! Int})
        return productSummary
    }
    
    //MARK: Format products summary to display on the screen
    func formattedProductSummary(forProductSummary productSummary: [String: Any]) -> [String: Any] {
        var formattedSummary = [String: Any]()
        
        let productName = (productSummary["productName"] as! String).components(separatedBy: "-")
        var formattedName = "\(productSummary["qty"] as! Int) X \(productName[0])\n"
        if productName.count > 1 {
            for i in 1 ..< productName.count {
                formattedName = formattedName + "   - \(productName[i])\n"
            }
        }
        
        let hasDietary = (productSummary["dietary"] as! String) != "" ? true : false
        formattedSummary = ["productName": formattedName, "hasDietary": hasDietary]
        
        return formattedSummary
    }
    
    //MARK: Show Dietary Requirement for the product from product summary menu
    @objc func showDietary(_ sender: UITapGestureRecognizer) {
        guard let view = sender.view else {return}
        let indexPath = IndexPath(row:view.tag, section: 0)
        Helper.presentAlert(viewController: self, title: "Dietary Requirements:", message: "\(productSummary[indexPath.row]["dietary"] as! String)")
    }
    
    //MARK: Following functions will be used to schedule timer to display table active time and destory them.
    func scheduleTimerToUpdateCollectionView() {
        if tableOnTimer == nil {
            tableOnTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateOrderView), userInfo: nil, repeats: true)
        }
    }
    
    func invalidateTimer() {
        activeOrdersTimer?.invalidate()
        activeOrdersTimer = nil
        
        tableOnTimer?.invalidate()
        tableOnTimer = nil
    }

    //MARK: Update Timer for only visible cells on the layout
    func updateTimeForTables(forOrder order: Order) -> [String: Any] {
        var timeDetail = [String: Any]()
        if order.dateAdded != "" {
            var timeToDisplay = "00:00:00"
            var isExceeededTime = false
            
            var hoursToDisplay = ""
            var minutesToDisplay = ""
            var secondsToDisplay = ""

            let dateFormat = DateFormatter()
            dateFormat.dateFormat = "yyyy-MM-dd HH:mm:ss"
            let referenceDateTime = dateFormat.date(from: order.dateAdded!)!
            
            let df = DateFormatter()
            df.dateFormat = "dd/MM/yyyy hh:mm:ss a"
            
            let convertedDate = df.string(from: referenceDateTime)
            let convertedDateTime = df.date(from: convertedDate)
            
            let presentDate = dateFormat.string(from: Date())
            let currentDateTime = dateFormat.date(from: presentDate)
            let diffComponents = Calendar.current.dateComponents([.hour, .minute, .second], from: convertedDateTime!, to: currentDateTime!)
            
            let hours = diffComponents.hour
            let minutes = diffComponents.minute
            let seconds = diffComponents.second
            
            if hours! < 10 {
                hoursToDisplay = "0\(String(hours!))"
            }
            else {
                hoursToDisplay = String(hours!)
            }
            
            if minutes! < 10 {
                minutesToDisplay = "0\(String(minutes!))"
            }
            else {
                minutesToDisplay = String(minutes!)
            }
            
            if seconds! < 10 {
                secondsToDisplay = "0\(String(seconds!))"
            }
            else {
                secondsToDisplay = String(seconds!)
            }
            
            timeToDisplay = "\(hoursToDisplay):\(minutesToDisplay):\(secondsToDisplay)"
            
            switch order.deliveryType {
                case .pickup:
                    if currentDateTime!.timeIntervalSince(convertedDateTime!) > (3 * 60) {
                        isExceeededTime = true
                    }
                case .delivery:
                    if currentDateTime!.timeIntervalSince(convertedDateTime!) > (3 * 60) {
                        isExceeededTime = true
                    }
                case .dineIn:
                    if currentDateTime!.timeIntervalSince(convertedDateTime!) > (20 * 60) {
                        isExceeededTime = true
                    }
            }
            
            timeDetail = ["timeToDisplay": timeToDisplay, "isExceededTime": isExceeededTime]
        }
        
        return timeDetail
    }
    
    //MARK: Update Order View every second
    @objc func updateOrderView() {
        if orders.count > 0 {
            activeOrderView.reloadData()
        }
    }
    
    //MARK: Schedule timer to call the active order in background
    func scheduleTimerToGetActiveOrders() {
        if activeOrdersTimer == nil {
            activeOrdersTimer = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(getActiveOrders), userInfo: nil, repeats: true)
        }
    }
        
    //MARK: This function will fecth the completed orders of the current date.
    @objc func getActiveOrders() {
        invalidateTimer()
        print("Fetching active orders...")
        
        OrderServices.shared.getActiveOrders(orderStatus: "Active") { result in
            switch result {
                case .failure(let error):
                    print("Failed to get active orders\(error)...")
                    Logs.writeLog(onDate: Helper.getCurrentDateAndTime(), andDescription: "\(error)")
                        
                    Helper.loadingSpinner(isLoading: false, isUserInteractionEnabled: true, withMessage: "")
                    Helper.presentAlert(viewController: self, title: "Something Went Wrong (Error code: \(Helper.errorForAPI(APIErrorCode.getOrders_Active)))", message: error.localizedDescription)

                    self.scheduleTimerToGetActiveOrders()
                case .success(let resp):
                    if resp.orders.count > 0 {
                        self.orders = resp.orders
                        self.orders.sort(by: {$0.isUrgent > $1.isUrgent})
                        
                        for i in 0 ..< self.orders.count {
                            if self.orders[i].deletedProducts != nil && self.orders[i].deletedProducts!.count > 0 {
                                for j in 0 ..< self.orders[i].deletedProducts!.count {
                                    self.orders[i].deletedProducts![j].isDeleted = 1
                                }
                                self.orders[i].products = self.orders[i].products + self.orders[i].deletedProducts!
                            }
                        }
                        
//                        if UserDefaults.selectedDocketSections != nil && UserDefaults.selectedDocketSections!.contains("Terminal") {
//                            //Don't remove any products from order, as the Section is selected as 'Terminal'. Hence, all items will be displayed here...
//                        }
//                        else {
                            self.filterOrdersToDisplay()
//                        }
                        self.productSummary = self.combineProductsForSummaryDisplay()

                        self.btnProductSummary.isEnabled = true
                        self.btnProductSummary.tintColor = .white
                    }
                    else {
                        self.orders = [Order]()
                        self.productSummary = [[String: Any]]()
                        
                        self.btnProductSummary.isEnabled = false
                        self.btnProductSummary.tintColor = .clear
                        
                        self.tblProductSummary.isHidden = true
                        self.activeOrderViewLeadingConstraint.constant = 0
                    }
                    
                    self.scheduleTimerToGetActiveOrders()
                    self.scheduleTimerToUpdateCollectionView()

                    self.activeOrderView.reloadData()
                    self.tblProductSummary.reloadData()
            }
        }
    }
        
    //MARK: Filter Orders based on selected sections to display
    func filterOrdersToDisplay() {
        for i in 0 ..< self.orders.count {
            var productsOfOrder = self.orders[i].products
            print(productsOfOrder)

            productsOfOrder.forEach { product in
                print(product.name)

                for j in 0 ..< product.docketType.count {
                    if selectedSections.contains(where: {$0 == product.docketType[j]}) {
                        break
                    }
                    else if j == product.docketType.count - 1 {
                        productsOfOrder.removeAll(where: {$0 == product})
                    }
                    else {
                        //Keep the loop running...
                    }
                }
            }
            
            if productsOfOrder.count > 0 {
                var shouldDeleteAllProducts = false
                
                for j in 0 ..< productsOfOrder.count {
                    if productsOfOrder[j].isDeleted == 0 {
                        shouldDeleteAllProducts = false
                        break
                    }
                    else {
                        shouldDeleteAllProducts = true
                    }
                }
                
                if shouldDeleteAllProducts == false {
                    self.orders[i].products = productsOfOrder
                }
                else {
                    self.orders[i].products = [Product]()
                }
            }
            else {
                self.orders[i].products = [Product]()
            }
        }
        
//        for j in 0 ..< self.orders.count {
//            if self.orders[j].products.count > 0 {
//                var removeDeliveredProducts = [Product]()
//
//                for m in 0 ..< self.orders[j].products.count {
//                    if self.orders[j].products[m].isDelivered != nil && self.orders[j].products[m].isDelivered == 1 {
//                        removeDeliveredProducts.append(self.orders[j].products[m])
//                    }
//                }
//
//                if removeDeliveredProducts.count == self.orders[j].products.count {
//                        //self.orders[i].products = [Product]()
//
//                    let tempOrder = self.orders[j]
//                    self.orders.remove(at: j)
//                    self.orders.append(tempOrder)
//                }
//            }
//            else {
//                break
//            }
//        }
        
        orders.removeAll(where: {$0.products.count == 0})
    }
    
    //MARK: To mark order as completed.
    func markOrderAsCompleted(forOrderNo orderNo: Int, andSequenceNo seqNo: Int, andAddedProductIDs addedProductIDs: [Int]) {
        invalidateTimer()
        
        OrderServices.shared.markOrderAsCompleted(forOrderNumber: orderNo, andSequenceNo: seqNo, forAddedProductIDs: addedProductIDs) { result in
            switch result {
                case .failure(let error):
                    print("Failed to mark order \(orderNo) as completed...")
                    Logs.writeLog(onDate: Helper.getCurrentDateAndTime(), andDescription: "\(error)")
                        
                    Helper.presentAlert(viewController: self, title: "Something Went Wrong (Error code: \(Helper.errorForAPI(APIErrorCode.markAsCompleted)))", message: error.localizedDescription)
                    self.scheduleTimerToGetActiveOrders()
                case .success(_):
                    print("Order successfully marked as completed...")
                    Logs.writeLog(onDate: Helper.getCurrentDateAndTime(), andDescription: "Order No: \(orderNo) has been marked as completed successfully...")
                    
                    self.orders.removeAll(where: {$0.orderNo == orderNo && $0.sequenceNo == seqNo})
                    self.activeOrderView.reloadData()
                    
                    self.productSummary = self.combineProductsForSummaryDisplay()
                    self.tblProductSummary.reloadData()
                    self.scheduleTimerToGetActiveOrders()
            }
        }
    }
    
    //MARK: To mark order as urgent.
    func markOrderAsUrgent(forOrderNo orderNo: Int, andSequenceNo seqNo: Int) {
        OrderServices.shared.markOrderAsUrgent(forOrderNumber: orderNo, andSequenceNo: seqNo) { result in
            switch result {
                case .failure(let error):
                    print("Failed to mark order \(orderNo) as urgent...")
                    Logs.writeLog(onDate: Helper.getCurrentDateAndTime(), andDescription: "\(error)")
                        
                    Helper.presentAlert(viewController: self, title: "Something Went Wrong (Error code: \(Helper.errorForAPI(APIErrorCode.markAsUrgent)))", message: error.localizedDescription)
                case .success(_):
                    print("Order successfully marked as urgent...")
                    Logs.writeLog(onDate: Helper.getCurrentDateAndTime(), andDescription: "Order No: \(orderNo) has been marked as urgent successfully...")
            }
        }
    }
    
    //MARK: To mark individual item as delivered.
    func markIndividualItemAsDelivered(forOrderNo orderNo: Int, andSequenceNo seqNo: Int, andAddedProductID addedProductID: Int, andSection section: String, andIsDelivered isDelivered: Int) {
        OrderServices.shared.markItemAsDelivered(forOrderNumber: orderNo, andSequenceNo: seqNo, forAddedProductID: addedProductID, andHasSection: section, andIsDelivered: isDelivered) { result in
            switch result {
                case .failure(let error):
                    print("Failed to mark item id: \(addedProductID) for Order: \(orderNo) as delivered...")
                    Logs.writeLog(onDate: Helper.getCurrentDateAndTime(), andDescription: "\(error)")
                        
                    Helper.presentAlert(viewController: self, title: "Something Went Wrong (Error code: \(Helper.errorForAPI(APIErrorCode.markIndividualItemDelivered)))", message: error.localizedDescription)
                case .success(_):
                    print("Item marked delivered / not delivered successfully...")
                    Logs.writeLog(onDate: Helper.getCurrentDateAndTime(), andDescription: "Item ID: \(addedProductID) for Order No: \(orderNo) has been marked \(isDelivered) successfully...")
            }
        }
    }
}
