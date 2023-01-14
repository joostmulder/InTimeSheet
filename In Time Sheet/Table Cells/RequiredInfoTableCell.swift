//
//  RequiredInfoTableCell.swift
//  In Time Sheet
//
//  Created by apple on 21/03/19.
//  Copyright © 2019 Sonu Singh. All rights reserved.
//

import UIKit

class RequiredInfoTableCell: UITableViewCell {

    // Outlets
    @IBOutlet weak var lblType: UILabel!
    @IBOutlet weak var imageVWCheckBox: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        if selected == true {
            self.imageVWCheckBox.image = UIImage (named: "checked")
        }
        else {
            self.imageVWCheckBox.image = UIImage (named: "unchecked")
        }
        
        // Configure the view for the selected state
    }

}
