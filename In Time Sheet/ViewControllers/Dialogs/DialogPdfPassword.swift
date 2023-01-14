//
//  DialogPdfPassword.swift
//  In Time Sheet
//
//  Created by apple on 26/03/19.
//  Copyright © 2019 Sonu Singh. All rights reserved.
//

import UIKit

protocol PdfPasswordDelegate {
    func savePassword(pass: String)
}

class DialogPdfPassword: UIViewController {

    var delegate: PdfPasswordDelegate?
    
    // outlets
    @IBOutlet weak var txtPassword: UnderLinedTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    // Button Actions
    @IBAction func clickedNo(_ sender: Any) {
        
        self.dismiss(animated: false, completion: nil)
    }
    @IBAction func clickedYes(_ sender: Any) {
        
        if self.txtPassword.text?.trimmingCharacters(in: .whitespaces).isEmpty == true {
            
            self.showAlert(title: "Please enter a password")
        }
        else {
            self.dismiss(animated: false, completion: {
                self.delegate?.savePassword(pass: self.txtPassword.text ?? "")
            })
        }
    }
    

}
