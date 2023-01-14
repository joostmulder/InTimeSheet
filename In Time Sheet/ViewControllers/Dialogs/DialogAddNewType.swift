//
//  DialogAddNewType.swift
//  In Time Sheet
//
//  Created by apple on 21/03/19.
//  Copyright © 2019 Sonu Singh. All rights reserved.
//

import UIKit

protocol DialogAddNewTypeDelegate {
    func addNewType(type: String)
}

class DialogAddNewType: UIViewController {

    var delegate: DialogAddNewTypeDelegate?
    
    // Outlets
    @IBOutlet weak var txtType: UnderLinedTextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    // Button Actions
    @IBAction func clickedCancel(_ sender: Any) {
        
        self.dismiss(animated: false, completion: nil)
    }
    @IBAction func clickedAdd(_ sender: Any) {
        
        if (self.txtType.text?.trimmingCharacters(in: .whitespaces))?.isEmpty == true {
            self.showAlert(title: "Please enter line name")
        }
        else {
            self.dismiss(animated: false, completion: {
                self.delegate?.addNewType(type: self.txtType.text!)
            })
        }
    }
}
