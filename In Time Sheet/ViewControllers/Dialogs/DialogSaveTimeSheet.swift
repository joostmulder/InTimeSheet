//
//  DialogSaveTimeSheet.swift
//  In Time Sheet
//
//  Created by apple on 21/03/19.
//  Copyright © 2019 Sonu Singh. All rights reserved.
//

import UIKit

protocol SaveAlertDelegate {
    
    func saveTimeSheet()
    func dontSaveTimeSheet()
}

class DialogSaveTimeSheet: UIViewController {

    var delegate: SaveAlertDelegate?
    
    var dictNewSheet: [String:String] = [String:String]()
    
    // Outlets
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    // Button Actions
    @IBAction func clickedNo(_ sender: Any) {
        
        self.dismiss(animated: false, completion: {
            self.delegate?.dontSaveTimeSheet()
        })
    }
    @IBAction func clickedSave(_ sender: Any) {
        
        self.dismiss(animated: false, completion: {
            self.delegate?.saveTimeSheet()
        })
    }
}
