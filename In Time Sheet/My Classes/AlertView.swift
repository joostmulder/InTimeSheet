//
//  AlertView.swift
//  In Time Sheet
//
//  Created by apple on 20/03/19.
//  Copyright © 2019 Sonu Singh. All rights reserved.
//

import UIKit

class AlertView: UIView {
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        self.layer.cornerRadius = 5
        self.clipsToBounds = true
    }
}
