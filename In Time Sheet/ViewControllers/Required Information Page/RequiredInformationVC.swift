//
//  RequiredInformationVC.swift
//  In Time Sheet
//
//  Created by apple on 21/03/19.
//  Copyright © 2019 Sonu Singh. All rights reserved.
//

import UIKit

@objc protocol AddNewLineDelegate {
    
    func addNewLine(line:String)
    @objc optional func removeNewLine(line: String)
}

class RequiredInformationVC: UIViewController {

    var delegate: AddNewLineDelegate?
    
    var aryLines:[String] = ["Time in", "Time out", "Staff signature", "Staff name", "Total billable time", "Rate", "Client", "Patient/Claimant", "Language", "Assignment", "Provider","Appointment/Job", "Medical Appointment", "Claim Number"]
    
    // Outlets
    @IBOutlet weak var tableVW: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    // Button Actions
    @IBAction func clickedCancel(_ sender: Any) {
        
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func clickedAddNewType(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "DialogAddNewType") as! DialogAddNewType
        vc.delegate = self
        vc.modalPresentationStyle = .overCurrentContext
        self.navigationController?.present(vc, animated: false, completion: nil)
    }
    @IBAction func clikcedSaveTemplate(_ sender: Any) {
        
       self.navigationController?.popViewController(animated: true)
    }
}
extension RequiredInformationVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.aryLines.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "RequiredInfoTableCell") as! RequiredInfoTableCell
        
        cell.lblType.text = self.aryLines[indexPath.row]
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.delegate?.addNewLine(line: self.aryLines[indexPath.row])
    }
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        
        self.delegate?.removeNewLine!(line: self.aryLines[indexPath.row])
    }
}
extension RequiredInformationVC: DialogAddNewTypeDelegate {
   
    func addNewType(type: String) {
        var exist = false
        for item in self.aryLines {
            if item == type {
                exist = true
            }
        }
        if exist == false {
            self.aryLines.append(type)
            self.tableVW.reloadData()
        }
    }
}
