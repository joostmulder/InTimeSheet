//
//  AddNewTemplateVC.swift
//  In Time Sheet
//
//  Created by apple on 20/03/19.
//  Copyright © 2019 Sonu Singh. All rights reserved.
//

import UIKit
import Instructions

protocol SaveTempDelegate {
    
    func saveTemplate(temp:[String:String])
}

class AddNewTemplateVC: ProfileViewController, CoachMarksControllerDataSource {

    let objDataModel = DataModel()
    
    var aryTemplates: [[String:String]] = [[String:String]]()
    var aryNewTypes: [String] = [String]()
    var windowLevel: UIWindow.Level?
    var presentationContext: Context = .independantWindow

    // Outlets
    @IBOutlet weak var tableVW: UITableView!
    @IBOutlet weak var lblTempsLeft: UILabel!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var buttonAdd: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.coachMarksController.dataSource = self
        self.coachMarksController.delegate = self
        
        let skipView = CoachMarkSkipDefaultView()
        skipView.setTitle("Skip", for: .normal)
        
        self.coachMarksController.skipView = skipView
        
        self.tableVW.dataSource = self
        self.tableVW.delegate = self
        self.tableVW.tableFooterView = UIView()
        
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        
        self.aryTemplates.removeAll()
        self.aryTemplates = self.objDataModel.getTempData()
        self.tableVW.reloadData()
    }
    // Button Actions
    @IBAction func clickedBack(_ sender: Any) {
        self.navigationController?.popToRootViewController(animated: true)
    }
    @IBAction func clickedAddNew(_ sender: Any) {
        if self.aryTemplates.count >= 15 {
            self.showAlert(title: "No template left")
        }
        else {
            //let vc = self.storyboard?.instantiateViewController(withIdentifier: "CreateTempAlertVC") as! CreateTempAlertVC
            //vc.alertActionDelegate = self
            //vc.modalPresentationStyle = .overCurrentContext
            //self.navigationController?.present(vc, animated: false, completion: nil)
            
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "CreateNewTemplateVC") as! CreateNewTemplateVC
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    override func startInstructions() {
        let instructionShowed = UserDefaults.standard.bool(forKey: "instructionAddNewTemplateShowed")
        
        if !instructionShowed {
            UserDefaults.standard.set(true, forKey: "instructionAddNewTemplateShowed")
            
            if presentationContext == .controllerWindow {
                self.coachMarksController.start(in: .currentWindow(of: self))
            } else if presentationContext == .controller {
                self.coachMarksController.start(in: .viewController(self))
            } else {
                if let windowLevel = windowLevel {
                    self.coachMarksController.start(in: .newWindow(over: self, at: windowLevel))
                } else {
                    self.coachMarksController.start(in: .window(over: self))
                }
            }
        }
    }
    
    enum Context {
        case independantWindow, controllerWindow, controller
    }
    
    // MARK: - Protocol Conformance | CoachMarksControllerDataSource
    func numberOfCoachMarks(for coachMarksController: CoachMarksController) -> Int {
        return 2
    }
    
    func coachMarksController(_ coachMarksController: CoachMarksController, coachMarkAt index: Int) -> CoachMark {
        switch(index) {
        case 0:
            return coachMarksController.helper.makeCoachMark(for: self.buttonAdd)
        case 1:
            return coachMarksController.helper.makeCoachMark(for: self.tableVW.visibleCells.first)
            
        default:
            return coachMarksController.helper.makeCoachMark()
        }
    }
    
    func coachMarksController(_ coachMarksController: CoachMarksController, coachMarkViewsAt index: Int, madeFrom coachMark: CoachMark) -> (bodyView: CoachMarkBodyView, arrowView: CoachMarkArrowView?) {
        
        let coachViews = coachMarksController.helper.makeDefaultCoachViews(withArrow: true, arrowOrientation: coachMark.arrowOrientation)
        
        switch(index) {
        case 0:
            coachViews.bodyView.hintLabel.text = "Choose a template or create your own template"
            coachViews.bodyView.nextLabel.text = self.nextButtonText
        case 1:
            coachViews.bodyView.hintLabel.text = "Swipe left to edit or delete a template"
            coachViews.bodyView.nextLabel.text = self.nextButtonText
        default: break
        }
        
        return (bodyView: coachViews.bodyView, arrowView: coachViews.arrowView)
    }
    
    // MARK: Protocol Conformance - CoachMarkControllerDelegate
    func coachMarksController(_ coachMarksController: CoachMarksController,
                              willLoadCoachMarkAt index: Int) -> Bool {
        if index == 0 && presentationContext == .controller {
            return false
        }
        
        return true
    }
}
//extension AddNewTemplateVC: AddNewTempAlertDelegate {
//
//    func addNewAction() {
//        let vc = self.storyboard?.instantiateViewController(withIdentifier: "CreateNewTemplateVC") as! CreateNewTemplateVC
//        self.navigationController?.pushViewController(vc, animated: true)
//    }
//}
extension AddNewTemplateVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        print(self.aryTemplates)
        self.lblTempsLeft.text = "\(15-self.aryTemplates.count) templates left"
        if self.aryTemplates.count == 0 {
            return 1
        }
        return aryTemplates.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell = UITableViewCell()
        
        if self.aryTemplates.count == 0 {
            
            let cell1 = tableView.dequeueReusableCell(withIdentifier: "AddTempEmptyTableCell") as! AddTempEmptyTableCell
            cell = cell1
        }
        else if self.aryTemplates.count > 0 {
            
            let cell2 = tableView.dequeueReusableCell(withIdentifier: "AddNewTempTableCell") as! AddNewTempTableCell
            cell2.lblType.text = self.aryTemplates[indexPath.row]["tempName"]
            
            cell = cell2
        }
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if self.aryTemplates.count > 0 {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "AddingTimeSheetVC") as! AddingTimeSheetVC
            
            self.aryNewTypes.removeAll()
            let newtypes: [String] = (self.aryTemplates[indexPath.row]["tempOtherFields"])?.components(separatedBy: ",") ?? [String]()
            
            for type in newtypes {
                self.aryNewTypes.append(type)
                /*
                if type != "Time in" && type != "Time out" && type != "Staff signature" && type != "Staff name" && type != "Total billable time" {
                    
                    self.aryNewTypes.append(type)
                }
                */
            }
            vc.aryNewTypes = self.aryNewTypes
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if self.aryTemplates.count == 0 {
            
            return self.tableVW.frame.height
        }
        return 62.0
    }
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle
    {
        if self.aryTemplates.count == 0 {
            return UITableViewCell.EditingStyle.none
        } else {
            return UITableViewCell.EditingStyle.delete
        }
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            let alert = UIAlertController(title: "Delete template?", message: "You want to delete this template?", preferredStyle: UIAlertController.Style.alert)
            
            alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action: UIAlertAction!) in
                
                self.objDataModel.deleteTemplate(tempName: self.aryTemplates[indexPath.row]["tempName"] ?? String())
                self.aryTemplates.remove(at: indexPath.row)
                self.tableVW.reloadData()
            }))
            alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: { (action: UIAlertAction!) in
                
                // print("Handle Cancel Logic here")
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        if self.aryTemplates.count == 0 {
            return nil
        }
        
        let delete = UITableViewRowAction.init(style: .destructive, title: "Delete") { (action, indexPath) in
            let alert = UIAlertController(title: "Delete template?", message: "You want to delete this template?", preferredStyle: UIAlertController.Style.alert)
            
            alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action: UIAlertAction!) in
                
                self.objDataModel.deleteTemplate(tempName: self.aryTemplates[indexPath.row]["tempName"] ?? String())
                self.aryTemplates.remove(at: indexPath.row)
                self.tableVW.reloadData()
            }))
            alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: { (action: UIAlertAction!) in
                
                // print("Handle Cancel Logic here")
            }))
            self.present(alert, animated: true, completion: nil)
        }
        
        
        let editAction = UITableViewRowAction.init(style: .normal, title: "Edit") { (action, indexPath) in
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "CreateNewTemplateVC") as! CreateNewTemplateVC
             let template = self.aryTemplates[indexPath.row]
            vc.templateName = template["tempName"] ?? ""
            let other = template["tempOtherFields"] ?? ""
            let tempOtherFields = other.components(separatedBy: ",")
            
            for line in tempOtherFields {
                if !vc.aryTypes.contains(line) {
                    vc.aryTypes.append(line)
                    vc.aryNewTypes.append(line)
                }
            }
            
            self.navigationController?.pushViewController(vc, animated: true)
            
        }
        return [delete, editAction]
    }
    
}
