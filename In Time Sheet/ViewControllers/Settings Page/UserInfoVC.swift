//
//  UserInfoVC.swift
//  In Time Sheet
//
//  Created by Le Van Thang on 4/29/19.
//  Copyright © 2019 Sonu Singh. All rights reserved.
//

import UIKit

class UserInfoVC: UIViewController {
    
    @IBOutlet weak var textName : UITextField!
    @IBOutlet weak var textPhone : UITextField!
    @IBOutlet weak var textEmail : UITextField!
    @IBOutlet weak var textCompany : UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let name = UserDefaults.standard.object(forKey: "Name") as? String ?? ""
        let phone = UserDefaults.standard.object(forKey: "Phone") as? String ?? ""
        let email = UserDefaults.standard.object(forKey: "Email") as? String ?? ""
        let company = UserDefaults.standard.object(forKey: "Company") as? String ?? ""

        self.textName.text = name
        self.textPhone.text = phone
        self.textEmail.text = email
        self.textCompany.text = company
    }
    
    // Button Actions
    @IBAction func clickedBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }

    @IBAction func clickedSave(_ sender: Any) {
        UserDefaults.standard.set(self.textName.text, forKey: "Name")
        UserDefaults.standard.set(self.textPhone.text, forKey: "Phone")
        UserDefaults.standard.set(self.textEmail.text, forKey: "Email")
        UserDefaults.standard.set(self.textCompany.text, forKey: "Company")
        
        self.navigationController?.popViewController(animated: true)
    }
    
}
