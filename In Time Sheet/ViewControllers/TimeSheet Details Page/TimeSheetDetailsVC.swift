//
//  TimeSheetDetailsVC.swift
//  In Time Sheet
//
//  Created by apple on 21/03/19.
//  Copyright © 2019 Sonu Singh. All rights reserved.
//

import UIKit

class TimeSheetDetailsVC: UIViewController {

    var strName = String()
    var dictSheets: [String:AnyObject] = [String:AnyObject]()
    var aryNewTypes: [[String:String]] = [[String:String]]()
    var aryNewTempTypes: [String] = [String]()
    
    // Button Actions
    @IBOutlet weak var txtName: UITextField!
    @IBOutlet weak var btnTimeIn: UIButton!
    @IBOutlet weak var btnTimeOut: UIButton!
    @IBOutlet weak var btnStaffSign: UIButton!
    @IBOutlet weak var txtStaffName: UITextField!
    @IBOutlet weak var btnBillableTime: UIButton!
    @IBOutlet weak var tableVW: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableVW.dataSource = self
        self.tableVW.delegate = self
        self.tableVW.tableFooterView = UIView()
        
        self.txtName.text = self.dictSheets["sheetName"] as? String
        self.txtStaffName.text = self.dictSheets["sheetStaffName"] as? String
        self.btnTimeIn.setTitle(self.dictSheets["sheetTimeIn"] as? String, for: .normal)
        self.btnTimeOut.setTitle(self.dictSheets["sheetTimeOut"] as? String, for: .normal)
        self.btnBillableTime.setTitle(self.dictSheets["sheetTotalBillableTime"] as? String, for: .normal)
        
        if let imgString = self.dictSheets["sheetStaffSign"] as? String {
            let img = self.getImageFromBase64(base64: imgString) //UIImage (data: self.dictSheets["sheetStaffSign"] as? Data ?? Data())
            self.btnStaffSign.setImage(img, for: .normal)
        }
        
        self.btnTimeIn.setTitle(self.dictSheets["sheetTimeIn"] as? String, for: .normal)
        
        let otherData: String = self.dictSheets["sheetOtherData"] as? String ?? String()
        let aryOtherData: [String] = otherData.components(separatedBy: ",")
        
        //////////////////////
        let hasTimeIn = ((self.dictSheets["sheetTimeIn"] as? String) != nil)
        let hasTimeOut = ((self.dictSheets["sheetTimeOut"] as? String) != nil)
        let hasStaffSignature = ((self.dictSheets["sheetStaffSign"] as? String) != nil)
        let hasStaffName = ((self.dictSheets["sheetStaffName"] as? String) != nil)
        let hasTotalBillableTime = ((self.dictSheets["sheetTotalBillableTime"] as? String) != nil)
        
        
        if let headerView = self.btnTimeIn.superview?.superview?.superview {
            var frame = headerView.frame
            let step = frame.height/6
            var height = frame.height
            
            if !hasTimeIn {
                btnTimeIn.superview?.isHidden = true
                height -= step
            }
            if !hasTimeOut {
                btnTimeOut.superview?.isHidden = true
                height -= step
            }
            if !hasStaffSignature {
                btnStaffSign.superview?.isHidden = true
                height -= step
            }
            if !hasStaffName {
                txtStaffName.superview?.isHidden = true
                height -= step
            }
            if !hasTotalBillableTime {
                btnBillableTime.superview?.isHidden = true
                height -= step
            }
            
            frame.size.height = height
            headerView.frame = frame
        }
        /////////////////////
        
        
        for item in aryOtherData {
            let aryNew: [String] = item.components(separatedBy: ":")
            if aryNew[0] != "" {
                self.aryNewTypes.append([aryNew[0]:aryNew[1]])
                self.aryNewTempTypes.append(aryNew[0])
            }
        }
        
        self.tableVW.reloadData()
        
    }
    
    
    
    // Button Actions
    @IBAction func clickedBack(_ sender: Any) {
        
    
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func clickedCreatePDF(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "ResultPDFVC") as! ResultPDFVC
        vc.img = self.btnStaffSign.imageView?.image ?? UIImage()
        vc.dictNewSheet = self.dictSheets
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
}
extension TimeSheetDetailsVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.aryNewTempTypes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "TimeSheetDetailsCell") as! TimeSheetDetailsCell
        
        cell.lblTitle.text = self.aryNewTempTypes[indexPath.row]
        cell.txtValue.text = self.aryNewTypes[indexPath.row]["\(self.aryNewTempTypes[indexPath.row])"]
        
        return cell
    }
}
extension UIViewController {
    func getImageFromBase64(base64:String) -> UIImage? {
        let data = Data(base64Encoded: base64)
        return UIImage(data: data!)
    }
}

