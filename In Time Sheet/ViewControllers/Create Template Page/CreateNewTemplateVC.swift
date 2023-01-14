//
//  CreateNewTemplateVC.swift
//  In Time Sheet
//
//  Created by apple on 20/03/19.
//  Copyright © 2019 Sonu Singh. All rights reserved.
//

import UIKit

class CreateNewTemplateVC: UIViewController {

    var aryTypes: [String] = [] //["Time in", "Time out", "Staff signature", "Staff name", "Total billable time"]
    var aryNewTypes: [String] = [String]()
    var templateName: String = ""
    
    // Outlets
    @IBOutlet weak var tableVW: UITableView!
    @IBOutlet weak var txtTempName: UnderLinedTextField!
    @IBOutlet weak var lblTitle: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.txtTempName.text = self.templateName
        if !templateName.isEmpty {
            self.lblTitle.text = "Edit template"
        }
        
        self.tableVW.dataSource = self
        self.tableVW.delegate = self
        self.tableVW.tableFooterView = UIView()
        
        // Do any additional setup after loading the view.
    }

    // Button actions
    @IBAction func clickedCancel(_ sender: Any) {
        
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func clickedAddLines(_ sender: Any) {
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "RequiredInformationVC") as! RequiredInformationVC
        vc.delegate = self
        self.navigationController?.pushViewController(vc, animated: true)
    }
    @IBAction func clickedSaveTemplate(_ sender: Any) {
       
        if (self.txtTempName.text?.trimmingCharacters(in: .whitespaces))?.isEmpty == false {
            
            // Incase of edit, we have to delete old template
            if !templateName.isEmpty {
                let objDataModel = DataModel()
                objDataModel.deleteTemplate(tempName: templateName)
            }
                
            DataModel.saveTemplate(tempName: self.txtTempName.text!, tempOtherFields: self.aryTypes)
            
            self.navigationController?.popViewController(animated: true)
        }
        else {
            self.showAlert(title: "Please enter template name")
        }
        
    }
    
}
extension CreateNewTemplateVC: AddNewLineDelegate {
    func addNewLine(line: String) {
        if !self.aryTypes.contains(line) {
            self.aryTypes.append(line)
            self.aryNewTypes.append(line)
        }
        self.tableVW.reloadData()
    }
    func removeNewLine(line: String) {
        self.aryTypes = self.aryTypes.filter() { $0 != line }
        self.aryNewTypes = self.aryNewTypes.filter() { $0 != line }
        self.tableVW.reloadData()
    }
}
extension CreateNewTemplateVC: UITableViewDataSource, UITableViewDelegate {
  
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       
        return self.aryTypes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CreateNewTempTableCell") as!CreateNewTempTableCell
        
        cell.lblType.text = self.aryTypes[indexPath.row]
        
        return cell
    }
}
