//
//  SettingsVC.swift
//  In Time Sheet
//
//  Created by apple on 19/03/19.
//  Copyright © 2019 Sonu Singh. All rights reserved.
//

import UIKit
import CoreLocation
import StoreKit

class SettingsVC: UIViewController {

    var locationManager:CLLocationManager!
    
    // Outlets
    @IBOutlet weak var switchGPS: UISwitch!
    @IBOutlet weak var switchAddPassword : UISwitch!
    @IBOutlet weak var switchSamePassword : UISwitch!
    @IBOutlet weak var switchAddUserInfo : UISwitch!
    @IBOutlet weak var labelUserInfo : UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        
        if CLLocationManager.locationServicesEnabled(){
            locationManager.startUpdatingLocation()
        }
        
        if let isAddPassword = UserDefaults.standard.object(forKey: "isAddPassword") as? Bool {
            switchAddPassword.isOn = isAddPassword
        }
        else {
            switchAddPassword.isOn = true
        }
        
        switchSamePassword.isOn = UserDefaults.standard.bool(forKey: "isSamePassword")
        
        // Default is off
        switchAddUserInfo.isOn = UserDefaults.standard.bool(forKey: "isAddUserInfo")
        
        
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        
        if UserDefaults.standard.bool(forKey: "isLocationEnabled") == true {
            self.switchGPS.isOn = true
        }
        else {
            self.switchGPS.isOn = false
            self.locationManager.stopUpdatingLocation()
        }
        
        // Get current userinfo
        //Name: ABC
        //Phone#: +1223433
        //Email: support@abc.com
        //Company name: My Company
        let name = UserDefaults.standard.object(forKey: "Name") as? String ?? ""
        let phone = UserDefaults.standard.object(forKey: "Phone") as? String ?? ""
        let email = UserDefaults.standard.object(forKey: "Email") as? String ?? ""
        let company = UserDefaults.standard.object(forKey: "Company") as? String ?? ""
        
        let strUserInfo = String.init(format: "Name: %@\nPhone#: %@\nEmail: %@\nCompany name: %@", name, phone, email, company)
        self.labelUserInfo.text = strUserInfo

    }
    // Button Actions
    @IBAction func clickedBack(_ sender: Any) {
        
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func switchGPS(_ sender: UISwitch) {
        
        if sender.isOn {
            self.getMyLocation()
        }
        else {
            UserDefaults.standard.set(false, forKey: "isLocationEnabled")
            self.locationManager.stopUpdatingLocation()
        }
    }
    
    @IBAction func switchAddPassword(_ sender: UISwitch) {
        
        UserDefaults.standard.set(sender.isOn, forKey: "isAddPassword")

        if sender.isOn {
            switchSamePassword.isOn = UserDefaults.standard.bool(forKey: "isSamePassword")
            switchSamePassword.isEnabled = true
        }
        else {
            switchSamePassword.isOn = false
            switchSamePassword.isEnabled = false
        }
    }

    @IBAction func switchSamePassword(_ sender: UISwitch) {
        UserDefaults.standard.set(sender.isOn, forKey: "isSamePassword")
    }

    @IBAction func switchAddUserInfo(_ sender: UISwitch) {
        if sender.isOn {
            let name = UserDefaults.standard.object(forKey: "Name") as? String ?? ""
            let phone = UserDefaults.standard.object(forKey: "Phone") as? String ?? ""
            let email = UserDefaults.standard.object(forKey: "Email") as? String ?? ""
            let company = UserDefaults.standard.object(forKey: "Company") as? String ?? ""
            
            if name.isEmpty && phone.isEmpty && email.isEmpty && company.isEmpty {
                // Show add user info
                if let controller = self.storyboard?.instantiateViewController(withIdentifier: "UserInfoVC") as? UserInfoVC {
                    self.navigationController?.pushViewController(controller, animated: true)
                }
            }
        }

        UserDefaults.standard.set(sender.isOn, forKey: "isAddUserInfo")

    }
    
    @IBAction func onButtonUserInfo(_ sender: UIButton) {
        // Show edit user info
        if let controller = self.storyboard?.instantiateViewController(withIdentifier: "UserInfoVC") as? UserInfoVC {
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }

    @IBAction func onRestorePurchase(_ sender: UIButton) {
//        SKPaymentQueue.default().add(self)
//        SKPaymentQueue.default().restoreCompletedTransactions()

        SubscriptionService.shared.restorePurchases()
    }

    
    func getMyLocation() {
        
        // initialise a pop up for using later
        let alertController = UIAlertController(title: nil, message: "Please go to Settings and turn on the location permissions", preferredStyle: .alert)
        let settingsAction = UIAlertAction(title: "Settings", style: .default) { (_) -> Void in
            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                return
            }
            
            if UIApplication.shared.canOpenURL(settingsUrl) {
                UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                    
                })
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        alertController.addAction(cancelAction)
        alertController.addAction(settingsAction)
        
        // check the permission status
        switch(CLLocationManager.authorizationStatus()) {
        case .authorizedAlways, .authorizedWhenInUse:
            print("Authorize.")
            self.locationManager.startUpdatingLocation()
        // get the user location
        case .notDetermined, .restricted, .denied:
            // redirect the users to settings
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    // MARK:- IAP
    /*
    private func setBuyFullFeatures(){
        UserDefaults.standard.set(true, forKey: "isFullVersion")
    }
    
    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        for transaction in queue.transactions {
            let t: SKPaymentTransaction = transaction
            
            let prodID = t.payment.productIdentifier as String
            print("paymentQueueRestoreCompletedTransactionsFinished: \(prodID)")
            setBuyFullFeatures()
        }
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        print("add paymnet")
        
        for transaction:AnyObject in transactions {
            let trans = transaction as! SKPaymentTransaction
            //print(trans.error)
            
            switch trans.transactionState {
                
            case .purchased:
                print("buy, ok unlock iap here")
                setBuyFullFeatures()
                
                queue.finishTransaction(trans)
                break;
            case .failed:
                print("buy error")
                queue.finishTransaction(trans)
                break;
                
            case .purchasing:
                print("Purchasing")
                break;
                
            default:
                print("default")
                break;
                
            }
        }
    }
    */
}
extension SettingsVC: CLLocationManagerDelegate {
    
    //MARK: - location delegate methods
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation :CLLocation = locations[0] as CLLocation
        
//        print("user latitude = \(userLocation.coordinate.latitude)")
//        print("user longitude = \(userLocation.coordinate.longitude)")
        
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(userLocation) { (placemarks, error) in
            if (error != nil){
                print("error in reverseGeocode")
            }
            let placemark:[CLPlacemark] = placemarks ?? [CLPlacemark]()
            if placemark.count>0{
                let placemark = placemarks![0]
                print(placemark.locality!)
                print(placemark.administrativeArea!)
                print(placemark.country!)
               
                let strLocation = "\(placemark.locality!), \(placemark.administrativeArea!), \(placemark.country!)"
                UserDefaults.standard.set(true, forKey: "isLocationEnabled")
                UserDefaults.standard.set(strLocation, forKey: "myLocation")
            }
            else {
                self.switchGPS.isOn = false
                self.showAlert(title: "Please turn on the internet to get your location.")
            }
        }
        self.locationManager.stopUpdatingLocation()
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error \(error)")
    }
}
