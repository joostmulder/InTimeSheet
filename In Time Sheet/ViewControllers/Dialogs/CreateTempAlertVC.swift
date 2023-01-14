//
//  CreateTempAlertVC.swift
//  In Time Sheet
//
//  Created by apple on 20/03/19.
//  Copyright © 2019 Sonu Singh. All rights reserved.
//

import UIKit

protocol AddNewTempAlertDelegate {
    func addNewAction()
}

class CreateTempAlertVC: UIViewController {

    var alertActionDelegate: AddNewTempAlertDelegate?
    
    // Outlets
    @IBOutlet weak var viewAlert: AlertView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    // Button Actions
    @IBAction func clikcedCreate(_ sender: Any) {
        self.dismiss(animated: false, completion: {
            self.alertActionDelegate?.addNewAction()
        })
    }
    @IBAction func clickedNo(_ sender: Any) {
        self.dismiss(animated: false, completion: nil)
    }
}
