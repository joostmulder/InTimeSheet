//
//  DialogStaffSignature.swift
//  In Time Sheet
//
//  Created by apple on 21/03/19.
//  Copyright © 2019 Sonu Singh. All rights reserved.
//

import UIKit
import SwiftSignatureView

protocol DialogStaffSignatureDelegate {
    
    func signComplete(sign: UIImage)
}
class DialogStaffSignature: UIViewController {

    var delegate: DialogStaffSignatureDelegate?
    
    var imageSign: UIImage = UIImage()
    
    // Outlets
    @IBOutlet weak var viewStaffSign: SwiftSignatureView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    // Button Actions
    @IBAction func clickedSave(_ sender: Any) {
        
        self.imageSign = self.viewStaffSign.signature ?? UIImage()
        
        if self.imageSign.size.width != 0 {
            self.dismiss(animated: false, completion: {
                self.delegate?.signComplete(sign: self.imageSign)
            })
        }
        else {
            self.showAlert(title: "Please add staff signature")
        }
    }
    @IBAction func clickedCancel(_ sender: Any) {
        
        self.dismiss(animated: false, completion: nil)
    }
    
}
