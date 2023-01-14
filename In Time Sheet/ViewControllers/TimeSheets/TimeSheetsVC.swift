//
//  TimeSheetsVC.swift
//  In Time Sheet
//
//  Created by apple on 19/03/19.
//  Copyright © 2019 Sonu Singh. All rights reserved.
//

import UIKit
import CoreLocation
import Instructions

protocol SaveTimeSheetDelegate {
    
    func saveTimeSheet(sheet:[String:String])
}

class TimeSheetsVC: ProfileViewController, CoachMarksControllerDataSource{

    var arysheets: [[String:AnyObject]] = [[String:AnyObject]]()
    var locationManager:CLLocationManager!
    let objDataModel = DataModel()
    let name = Notification.Name("didReceiveData")
    
    var windowLevel: UIWindow.Level?
    var presentationContext: Context = .independantWindow
    let blackView = UIView()

    // Outlets
    @IBOutlet weak var tableVW: UITableView!
    
    @IBOutlet weak var buttonAdd: UIButton!
    @IBOutlet weak var buttonOptions: UIButton!
    @IBOutlet weak var subscriptionView: UIView!
    
    private var isFullVersion = false
    var options: [Subscription]?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        blackView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
        blackView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.6)
        self.blackView.isHidden = true
        self.view.addSubview(self.blackView)
        self.view.bringSubviewToFront(self.subscriptionView)
        
        self.coachMarksController.dataSource = self
        self.coachMarksController.delegate = self
        
        let skipView = CoachMarkSkipDefaultView()
        skipView.setTitle("Skip", for: .normal)
        
        self.coachMarksController.skipView = skipView

        
        self.tableVW.dataSource = self
        self.tableVW.delegate = self
        self.tableVW.tableFooterView = UIView()
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        
        if CLLocationManager.locationServicesEnabled(){
            locationManager.startUpdatingLocation()
        }
        
        // Save generic templates
        DataModel.addGenericTemplates()
        
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

    override func viewWillAppear(_ animated: Bool) {
        self.arysheets = self.objDataModel.getSheetData()
        self.tableVW.reloadData()
    }
    
    // Button Actions
    @IBAction func clickedAddNew(_ sender: Any) {
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
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "AddNewTemplateVC") as! AddNewTemplateVC
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    @IBAction func clickedSettings(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "SettingsVC") as! SettingsVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    override func startInstructions() {
        let instructionShowed = UserDefaults.standard.bool(forKey: "instructionShowed")
        
        if !instructionShowed {
            UserDefaults.standard.set(true, forKey: "instructionShowed")

            if presentationContext == .controllerWindow {
                self.coachMarksController.start(in: .currentWindow(of: self))
            } else if presentationContext == .controller {
                self.coachMarksController.start(in: .viewController(self))
            } else {
                if let windowLevel = windowLevel {
                    self.coachMarksController.start(in: .newWindow(over: self, at: windowLevel))
                } else {
                    self.coachMarksController.start(in: .window(over: self))
                }
            }
        }
    }
    
    enum Context {
        case independantWindow, controllerWindow, controller
    }
    
    // MARK: - Protocol Conformance | CoachMarksControllerDataSource
    func numberOfCoachMarks(for coachMarksController: CoachMarksController) -> Int {
        return 2
    }
    
    func coachMarksController(_ coachMarksController: CoachMarksController, coachMarkAt index: Int) -> CoachMark {
        switch(index) {
        case 0:
            return coachMarksController.helper.makeCoachMark(for: self.buttonAdd)
        case 1:
            return coachMarksController.helper.makeCoachMark(for: self.buttonOptions)
        
        default:
            return coachMarksController.helper.makeCoachMark()
        }
    }
    
    func coachMarksController(_ coachMarksController: CoachMarksController, coachMarkViewsAt index: Int, madeFrom coachMark: CoachMark) -> (bodyView: CoachMarkBodyView, arrowView: CoachMarkArrowView?) {
        
        let coachViews = coachMarksController.helper.makeDefaultCoachViews(withArrow: true, arrowOrientation: coachMark.arrowOrientation)
        
        switch(index) {
        case 0:
            coachViews.bodyView.hintLabel.text = "Click add new to create a new time sheet"
            coachViews.bodyView.nextLabel.text = self.nextButtonText
        case 1:
            coachViews.bodyView.hintLabel.text = "Click options to activate GPS and password enabled PDFs"
            coachViews.bodyView.nextLabel.text = self.nextButtonText
        default: break
        }
        
        return (bodyView: coachViews.bodyView, arrowView: coachViews.arrowView)
    }
    
    // MARK: Protocol Conformance - CoachMarkControllerDelegate
    func coachMarksController(_ coachMarksController: CoachMarksController,
                              willLoadCoachMarkAt index: Int) -> Bool {
        if index == 0 && presentationContext == .controller {
            return false
        }
        
        return true
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

    private func showInAppPurchase(){
//        let alertController = UIAlertController(title: "Upgrade", message: "You've used 10 complimentary documents. Upgrade now & use unlimited timesheets. Only $1.99/month", preferredStyle: .alert)
//        let settingsAction = UIAlertAction(title: "Upgrade", style: .default) { (_) -> Void in
//            // Call in app purchase
//            guard self.options != nil, !self.options!.isEmpty, let option = self.options?[0] else { return }
//            SubscriptionService.shared.purchase(subscription: option)
//        }
//        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
//        alertController.addAction(cancelAction)
//        alertController.addAction(settingsAction)
//
//        self.present(alertController, animated: true, completion: nil)
        
        self.blackView.isHidden = false
        UIView.animate(withDuration: 0.5) {
            self.subscriptionView.frame.origin.y = (self.view.frame.height - self.subscriptionView.frame.height) / 2
        }
        
    }
    
    @IBAction func onClickedTermsButton(_ sender: Any) {
        guard let url = URL(string: "https://oregoncertified.com/terms.php") else { return }
        UIApplication.shared.open(url)
    }
    
    @IBAction func onClickedPrivacyButton(_ sender: Any) {
        guard let url = URL(string: "https://oregoncertified.com/privacy.php") else { return }
        UIApplication.shared.open(url)
    }
    
    @IBAction func onClickedCancelButton(_ sender: Any) {
        self.blackView.isHidden = true
        UIView.animate(withDuration: 0.5) {
            self.subscriptionView.frame.origin.y = self.view.frame.height
        }
    }
    
    @IBAction func onClickedUpgradeButton(_ sender: Any) {
        guard self.options != nil, !self.options!.isEmpty, let option = self.options?[0] else { return }
        SubscriptionService.shared.purchase(subscription: option)
    }
    
    
}

extension TimeSheetsVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if self.arysheets.count == 0 {
            return 1
        }
        return arysheets.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell = UITableViewCell()
        
        if self.arysheets.count == 0 {
            
            let cell1 = tableView.dequeueReusableCell(withIdentifier: "TimeSheetsNoDataCell") as! TimeSheetsNoDataCell
            cell1.isEditing = false
            cell = cell1
        }
        else if self.arysheets.count > 0 {
            
            let cell2 = tableView.dequeueReusableCell(withIdentifier: "TimeSheetsTableViewCell") as! TimeSheetsTableViewCell
            
            cell2.lblTitle.text = self.arysheets[indexPath.row]["sheetName"] as? String
            cell2.lblDate.text = self.arysheets[indexPath.row]["sheetCreateDate"] as? String
        
            cell = cell2
        }
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if self.arysheets.count > 0 {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "TimeSheetDetailsVC") as! TimeSheetDetailsVC
            //        vc.strName = self.arysheets[indexPath.row]["sheetName"] as! String
            vc.dictSheets = self.arysheets[indexPath.row]
            
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if self.arysheets.count == 0 {
            
            return self.tableVW.frame.height
        }
        return 62.0
    }
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle
    {
        if self.arysheets.count == 0 {
            return UITableViewCell.EditingStyle.none
        } else {
            return UITableViewCell.EditingStyle.delete
        }
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
      
            let alert = UIAlertController(title: "Delete time sheet?", message: "You want to delete this time sheet?", preferredStyle: UIAlertController.Style.alert)
            
            alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action: UIAlertAction!) in
                
                self.objDataModel.deleteSheet(sheetName: self.arysheets[indexPath.row]["sheetName"] as? String ?? String())
                self.arysheets.remove(at: indexPath.row)
                self.tableVW.reloadData()
            }))
            alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: { (action: UIAlertAction!) in
                
                // print("Handle Cancel Logic here")
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
}
extension UIView {
    
    func setLitleCorners() {
        self.layer.cornerRadius = 5
        self.clipsToBounds = true
    }
    func setCorners() {
        self.layer.cornerRadius = self.layer.bounds.size.height/2
        self.clipsToBounds = true
    }
}
extension UIViewController {
    
    func showAlert(title: String) {
        let alert = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        
        self.present(alert, animated: true)
    }
}
extension UIColor {
    
    static let appBackColour = UIColor (red: 249/255, green: 250/255, blue: 251/255, alpha: 1.0)
}

extension TimeSheetsVC: CLLocationManagerDelegate {
    
    //MARK: - location delegate methods
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation :CLLocation = locations[0] as CLLocation
        
        print("user latitude = \(userLocation.coordinate.latitude)")
        print("user longitude = \(userLocation.coordinate.longitude)")
        
//        self.labelLat.text = "\(userLocation.coordinate.latitude)"
//        self.labelLongi.text = "\(userLocation.coordinate.longitude)"
        
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(userLocation) { (placemarks, error) in
            if (error != nil){
                print("error in reverseGeocode")
            }
            let placemark = placemarks ?? [CLPlacemark]()
            if placemark.count>0{
                let placemark = placemarks![0]
                print(placemark.locality!)
                print(placemark.administrativeArea!)
                print(placemark.country!)
                let strLocation = "\(placemark.locality!), \(placemark.administrativeArea!), \(placemark.country!)"
                UserDefaults.standard.set(true, forKey: "isLocationEnabled")
                UserDefaults.standard.set(strLocation, forKey: "myLocation")
            }
        }
        self.locationManager.stopUpdatingLocation()
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error \(error)")
    }
}
