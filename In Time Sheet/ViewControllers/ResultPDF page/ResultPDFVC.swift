//
//  ResultPDFVC.swift
//  In Time Sheet
//
//  Created by apple on 21/03/19.
//  Copyright © 2019 Sonu Singh. All rights reserved.
//

import UIKit
import MessageUI
import PDFGenerator
import StoreKit

var pdfD = NSURL()
var pdff = Data()

class ResultPDFVC: UIViewController, MFMailComposeViewControllerDelegate, PdfPasswordDelegate/*, SKProductsRequestDelegate, SKPaymentTransactionObserver*/ {
    
    var dictNewSheet: [String:AnyObject] = [String:AnyObject]()
    var aryNewTypes: [[String:String]] = [[String:String]]()
    var aryNewTempTypes: [String] = [String]()
    var new = false
    var img = UIImage()
    var strPass = String()
    private static var previousPassword: String? = nil

    /*
    private var IAP_FULL = ""
    private var p: SKProduct? = nil
    */
    
    // Outlets
    @IBOutlet weak var scrollVW: UIScrollView!
    @IBOutlet weak var heightConstraintsTableVW: NSLayoutConstraint!
    @IBOutlet weak var viewPDF: UIView!
    @IBOutlet weak var tableVW: UITableView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblBillableTime: UILabel!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var lblTimeIn: UILabel!
    @IBOutlet weak var lblTimeOut: UILabel!
    @IBOutlet weak var lblStaffName: UILabel!
    @IBOutlet weak var imageVWSign: UIImageView!
    @IBOutlet weak var lblSignDated: UILabel!
    @IBOutlet weak var lblSignLocation: UILabel!
    
    @IBOutlet weak var buttonBack: UIButton!
    @IBOutlet weak var buttonBackConstraint: NSLayoutConstraint!
    
    private var isFullVersion = false
    var options: [Subscription]?

    // MARK: - Object Lifecycle
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()

        print(self.dictNewSheet)
        self.tableVW.delegate = self
        self.tableVW.dataSource = self
        
        // Check small screen
        if self.view.frame.width < 360 {
            self.buttonBack.setTitle("Back", for: .normal)
            self.buttonBackConstraint.constant = 80
        }
        
        let otherData: String = self.dictNewSheet["sheetOtherData"] as? String ?? String()
        let aryOtherData: [String] = otherData.components(separatedBy: ",")
        
        let isAddUserInfo = UserDefaults.standard.bool(forKey: "isAddUserInfo")
        if isAddUserInfo {
            let name = UserDefaults.standard.object(forKey: "Name") as? String ?? ""
            let phone = UserDefaults.standard.object(forKey: "Phone") as? String ?? ""
            let email = UserDefaults.standard.object(forKey: "Email") as? String ?? ""
            let company = UserDefaults.standard.object(forKey: "Company") as? String ?? ""
            
            self.aryNewTempTypes.append("Company")
            self.aryNewTypes.append(["Company":company])
            
            self.aryNewTempTypes.append("Name")
            self.aryNewTypes.append(["Name":name])
            
            self.aryNewTempTypes.append("Phone")
            self.aryNewTypes.append(["Phone":phone])

            self.aryNewTempTypes.append("Email")
            self.aryNewTypes.append(["Email":email])
        }
        
        for item in aryOtherData {
            let aryNew: [String] = item.components(separatedBy: ":")
            if aryNew[0] != "" {
                self.aryNewTypes.append([aryNew[0]:aryNew[1]])
                self.aryNewTempTypes.append(aryNew[0])
            }
        }
        self.tableVW.reloadData()
        
        self.lblName.text = "Reference Number: " + (self.dictNewSheet["sheetName"] as? String ?? "")
        self.lblBillableTime.text = "Total billable time: \(self.dictNewSheet["sheetTotalBillableTime"] as? String ?? "")"
        
        let sheetCreateDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .none
        dateFormatter.locale = Locale(identifier: "en_US")
        
        self.lblDate.text = "Date: \(dateFormatter.string(from: sheetCreateDate))"
        self.lblTimeIn.text = "Start time: \(self.dictNewSheet["sheetTimeIn"] ?? "" as AnyObject)"
        self.lblTimeOut.text = "End time: \(self.dictNewSheet["sheetTimeOut"] ?? "" as AnyObject)"
        self.lblStaffName.text = "Staff name: \(self.dictNewSheet["sheetStaffName"] ?? "" as AnyObject)"
        self.imageVWSign.image = self.img
        self.lblSignDated.text = "Date: \(self.dictNewSheet["sheetSignDate"] ?? "" as AnyObject)"
        if "\(self.dictNewSheet["sheetLocation"] ?? "" as AnyObject)" != "" {
            self.lblSignLocation.text = "Location: \(self.dictNewSheet["sheetLocation"] ?? "" as AnyObject)"
        }
        else {
            self.lblSignLocation.text = ""
        }
        
        self.heightConstraintsTableVW.constant = CGFloat(self.aryNewTempTypes.count * 30)
        
        //////////////////////
        let hasTimeIn = ((self.dictNewSheet["sheetTimeIn"] as? String) != nil)
        let hasTimeOut = ((self.dictNewSheet["sheetTimeOut"] as? String) != nil)
        let hasStaffSignature = ((self.dictNewSheet["sheetStaffSign"] as? String) != nil)
        let hasStaffName = ((self.dictNewSheet["sheetStaffName"] as? String) != nil)
        let hasTotalBillableTime = ((self.dictNewSheet["sheetTotalBillableTime"] as? String) != nil)
        
        if !hasTimeIn {
            lblTimeIn.isHidden = true
        }
        if !hasTimeOut {
            lblTimeOut.isHidden = true
        }
        if !hasStaffSignature {
            imageVWSign.superview?.isHidden = true
            lblSignDated.isHidden = true
        }
        if !hasStaffName {
            lblStaffName.isHidden = true
        }
        if !hasTotalBillableTime {
            lblBillableTime.isHidden = true
        }
        /////////////////////
        
        if /*SubscriptionService.shared.currentSessionId != nil,*/
            SubscriptionService.shared.hasReceiptData {
            isFullVersion = true
        }
        else {
            isFullVersion = false
        }
        
        options = SubscriptionService.shared.options
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleOptionsLoaded(notification:)),
                                               name: SubscriptionService.optionsLoadedNotification,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handlePurchaseSuccessfull(notification:)),
                                               name: SubscriptionService.purchaseSuccessfulNotification,
                                               object: nil)
        

    }
    
    override func viewDidAppear(_ animated: Bool) {
   
    }
    
    // Pdf Password Delegate
    func savePassword(pass: String) {
        ResultPDFVC.previousPassword = pass
        let page1 = PDFPage.view(self.scrollVW)
        let pages = [page1]
        
        let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let outputFileURL = documentDirectory.appendingPathComponent("InTimeSheet.pdf")
        print("URL:", outputFileURL)
        let dst = NSTemporaryDirectory().appending("InTimeSheet.pdf")
        do {
//            try PDFGenerator.generate(pages, to: dst, password: pass)
            // or use PDFPassword model
            try PDFGenerator.generate(pages, to: dst, password: PDFPassword(pass as String))
            // or use PDFPassword model and set user/owner password
            try PDFGenerator.generate(pages, to: outputFileURL, password: PDFPassword(user: pass as String, owner: "abcdef"))
            
            
            let documentsPath1 = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
            let filePath1 = "\(documentsPath1)/InTimeSheet"+".pdf"
            let url = NSURL(fileURLWithPath: filePath1)
            let data = NSData (contentsOf: url as URL)
            
            if data != nil
            {
                pdfD = url
                pdff = data! as Data
                print("File path loaded.")
                self.displayShareSheet(shareContent: url ?? NSURL())
            }
            
//            let mailComposeViewController = configuredMailComposeViewController()
//            if MFMailComposeViewController.canSendMail()
//            {
//                self.present(mailComposeViewController, animated: true, completion: nil)
//            }
//            else {
//                self.showSendMailErrorAlert()
//            }
            
        } catch let error {
            print(error)
        }
    }
    // Button Actions
    @IBAction func clickedBack(_ sender: Any) {
        if self.new == true {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "DialogSaveTimeSheet") as! DialogSaveTimeSheet
            vc.delegate = self
            vc.modalPresentationStyle = .overCurrentContext
            self.navigationController?.present(vc, animated: false, completion: nil)
        }
        else {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func clickedPrint(_ sender: UIButton) {
        // Check total number of saved sheets
        var askIAP = false
        let dataModel = DataModel()
        var total = dataModel.getSheetData().count
        if new {
            total += 1
        }
        
        if (total >= 11){
            // Check purchased
            askIAP = !isFullVersion
        }
        
        if (askIAP){
            showInAppPurchase()
        }
        else {
            // Save pdf then print it
            let page1 = PDFPage.view(self.scrollVW)
            let pages = [page1]
            
            let dst = NSTemporaryDirectory().appending("InTimeSheet.pdf")
            do {
                try PDFGenerator.generate(pages, to: dst, password: PDFPassword(""))
                let printController = UIPrintInteractionController.shared
                let printInfo = UIPrintInfo(dictionary:nil)
                
                printInfo.outputType = UIPrintInfo.OutputType.general
                printInfo.jobName = "print Job"
                printController.printInfo = printInfo
                printController.printingItem = dst
                printController.present(from: sender.frame, in: sender.superview!, animated: true, completionHandler: nil)
            } catch let error {
                print(error)
            }
        }
    }
    
    @IBAction func clickedShare(_ sender: Any) {
        // Check total number of saved sheets
        var askIAP = false
        let dataModel = DataModel()
        var total = dataModel.getSheetData().count
        if new {
            total += 1
        }
        
        if (total >= 11){
            // Check purchased
            askIAP = !isFullVersion
        }
        
        if (askIAP){
            showInAppPurchase()
        }
        else {
            var isAddPassword = true
            if let isAddPassword__ = UserDefaults.standard.object(forKey: "isAddPassword") as? Bool {
                isAddPassword = isAddPassword__
            }
        
            if isAddPassword {
                let isSamePassword = UserDefaults.standard.bool(forKey: "isSamePassword")
                if !isSamePassword || (ResultPDFVC.previousPassword == nil){
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "DialogPdfPassword") as! DialogPdfPassword
                    vc.delegate = self
                    vc.modalPresentationStyle = .overCurrentContext
                    self.navigationController?.present(vc, animated: false, completion: nil)
                }
                else {
                    savePassword(pass: ResultPDFVC.previousPassword!)
                }
            }
            else {
                savePassword(pass: "")
                ResultPDFVC.previousPassword = nil // Must set nil here
            }
        }
    }
    
    private func showInAppPurchase(){
        let alertController = UIAlertController(title: "Upgrade", message: "You've used 10 complimentary documents. Upgrade now & use unlimited timesheets. Only $1.99/month", preferredStyle: .alert)
        let settingsAction = UIAlertAction(title: "Upgrade", style: .default) { (_) -> Void in
            // Call in app purchase
            guard self.options != nil, !self.options!.isEmpty, let option = self.options?[0] else { return }
            SubscriptionService.shared.purchase(subscription: option)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        alertController.addAction(cancelAction)
        alertController.addAction(settingsAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    // Create PDF
    func generatePDF() {
       
        let page1 = PDFPage.view(self.scrollVW)
        let pages = [page1]
        
        let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let outputFileURL = documentDirectory.appendingPathComponent("InTimeSheet.pdf")
        print("URL:", outputFileURL)
        let dst = NSTemporaryDirectory().appending("InTimeSheet.pdf")
        do {
            try PDFGenerator.generate(pages, to: dst, password: "123456")
            // or use PDFPassword model
            try PDFGenerator.generate(pages, to: dst, password: PDFPassword("123456"))
            // or use PDFPassword model and set user/owner password
            try PDFGenerator.generate(pages, to: outputFileURL, password: PDFPassword(user: "123456", owner: "abcdef"))
            
        } catch let error {
            print(error)
        }
    }

    // Email
    func getDirectoryPath() -> String {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    func configuredMailComposeViewController() -> MFMailComposeViewController {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self
        
        mailComposerVC.setToRecipients([""])
        mailComposerVC.setSubject("InTimeSheet")
        mailComposerVC.setMessageBody("", isHTML: false)
        
        _ = Bundle.main.path(forResource: "InTimeSheet", ofType: "pdf")
        
        let documentsPath1 = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let filePath1 = "\(documentsPath1)/InTimeSheet"+".pdf"
        let url = NSURL(fileURLWithPath: filePath1)
        let data = NSData (contentsOf: url as URL)
        
        if data != nil
        {
            print("File path loaded.")
            
            print("File data loaded.")
            
            mailComposerVC.addAttachmentData(data! as Data, mimeType: "application/pdf", fileName: "InTimeSheet.pdf")
        }
        
        return mailComposerVC
    }
    
    func showSendMailErrorAlert() {
        self.showAlert(title: "Your device could not send e-mail. Please check e-mail configuration and try again.")
        
    }
    func mailComposeController(_ controller: MFMailComposeViewController,
                               didFinishWith result: MFMailComposeResult, error: Error?) {
        // Check the result or perform other tasks.
//        self.showActionAlert2(title: "Email Sent!", message: "Mail hase been sent.")
//        self.saveTimeSheet()
        // Dismiss the mail compose view controller.
        controller.dismiss(animated: true, completion: nil)
    }
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?)
    {
        self.dismiss(animated: true, completion: nil)
    }
    func showActionAlert2(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action: UIAlertAction!) in
            //    print("Handle Ok logic here")
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    
    // MARK:- IAP
    
    @objc func handleOptionsLoaded(notification: Notification) {
        DispatchQueue.main.async { [weak self] in
            self?.options = SubscriptionService.shared.options
        }
    }
    
    @objc func handlePurchaseSuccessfull(notification: Notification) {
        DispatchQueue.main.async { [weak self] in
            self?.isFullVersion = true
        }
    }
    
}

extension ResultPDFVC: SaveAlertDelegate {
    
    func saveTimeSheet() {
        // Check total number of saved sheets
        var askIAP = false
        let dataModel = DataModel()
        let total = dataModel.getSheetData().count
        if (total >= 10){
            // Check purchased
            askIAP = !isFullVersion
        }
        
        if (askIAP){
            showInAppPurchase()
        }
        else {
            let sheetCreateDate = Date()
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .short
            dateFormatter.timeStyle = .none
            dateFormatter.locale = Locale(identifier: "en_US")
            
            var myLocation = String()
            if UserDefaults.standard.bool(forKey: "isLocationEnabled") == true {
                myLocation = UserDefaults.standard.string(forKey: "myLocation") ?? ""
            }
            
            self.dictNewSheet["sheetCreateDate"] = "\(dateFormatter.string(from: sheetCreateDate))" as AnyObject
    //        print(self.dictNewSheet)
            
            DataModel.saveTimesheet(sheetName: self.dictNewSheet["sheetName"] as! String, sheetTempName: self.dictNewSheet["sheetTempName"] as? String ?? String(), sheetTimeIn: self.dictNewSheet["sheetTimeIn"] as? String, sheetTimeOut: self.dictNewSheet["sheetTimeOut"] as? String, sheetStaffSign: self.dictNewSheet["sheetStaffSign"] as? String, sheetStaffName: self.dictNewSheet["sheetStaffName"] as? String, sheetTotalBillableTime: self.dictNewSheet["sheetTotalBillableTime"] as? String, sheetSignDate: self.dictNewSheet["sheetSignDate"] as? String ?? String(), sheetCreateDate: "\(dateFormatter.string(from: sheetCreateDate))", sheetLocation: myLocation, sheetOtherData: self.dictNewSheet["sheetOtherData"] as? String ?? String())
            
            self.navigationController?.popToRootViewController(animated: true)
        }
    }
    
    func dontSaveTimeSheet() {
        self.navigationController?.popToRootViewController(animated: true)
    }
}
extension ResultPDFVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.aryNewTempTypes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "PDFTableCell") as! PDFTableCell
        
        let strTitle = self.aryNewTempTypes[indexPath.row]
        cell.lblTitle.text = "\(strTitle): \(self.aryNewTypes[indexPath.row]["\(self.aryNewTempTypes[indexPath.row])"] ?? "")"
        
        return cell
    }
    
    // Share Sheet
    func displayShareSheet(shareContent:NSURL) {
//        let activityViewController = UIActivityViewController(activityItems: [shareContent], applicationActivities: nil)
        let url = URL(string: "www.google.com")!
        let socialProvider = SocialActivityItem(pdfData: shareContent, url: url)
        let textProvider = TextActivityItem(textToShare: "Sharing on social media!")
        let activityViewController = UIActivityViewController(activityItems: [socialProvider, textProvider], applicationActivities: nil)
        
        present(activityViewController, animated: true, completion: {
            self.saveTimeSheet()
        })
    }
}

class SocialActivityItem: NSObject, UIActivityItemSource {
    var pdfData: NSURL?
    var url: URL?
    
    convenience init(pdfData: NSURL, url: URL) {
        self.init()
        self.pdfData = pdfData
        self.url = url
    }
    
    // This will be called BEFORE showing the user the apps to share (first step)
    func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        return pdfData!
    }
    
    // This will be called AFTER the user has selected an app to share (second step)
    func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
        //Instagram
        if activityType?.rawValue == "com.burbn.instagram.shareextension" {
            return pdfData!
        } else {
            return url
        }
    }
}
class TextActivityItem: NSObject, UIActivityItemSource {
    var textToShare: String?
    
    convenience init(textToShare: String) {
        self.init()
        self.textToShare = textToShare
    }
    
    // This will be called BEFORE showing the user the apps to share (first step)
    func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        return NSObject()
    }
    
    // This will be called AFTER the user has selected an app to share (second step)
    func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
//        var text = ""
        var pdfData = NSURL()
        if activityType?.rawValue == "net.whatsapp.WhatsApp.ShareExtension" {
//            text = "Sharing on Whatsapp"
            pdfData = pdfD
            return pdfData
        }
        
        return pdff
    }
}
