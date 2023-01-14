//
//  TimeSheetDetailsCell.swift
//  In Time Sheet
//
//  Created by apple on 23/03/19.
//  Copyright © 2019 Sonu Singh. All rights reserved.
//

import UIKit

class TimeSheetDetailsCell: UITableViewCell {

    // outlets
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var txtValue: UITextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
