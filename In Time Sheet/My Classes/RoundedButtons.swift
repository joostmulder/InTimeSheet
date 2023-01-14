//
//  RoundedButtons.swift
//  In Time Sheet
//
//  Created by apple on 20/03/19.
//  Copyright © 2019 Sonu Singh. All rights reserved.
//

import UIKit

class RoundedButtons: UIButton {
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        self.layer.cornerRadius = self.layer.bounds.size.height/2
        self.clipsToBounds = true
    }
}
