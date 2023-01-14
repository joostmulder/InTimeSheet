//
//  DataModel.swift
//  In Time Sheet
//
//  Created by apple on 23/03/19.
//  Copyright © 2019 Sonu Singh. All rights reserved.
//

import UIKit
import CoreData

class DataModel: NSObject {
    
    static var dataTable: [NSManagedObject] = []
    var tempData: [NSManagedObject] = []
    var dictTemplate: [String: String] = [String:String]()
    var aryTempList = [[String: String]]()
    var sheetData: [NSManagedObject] = []
    var dictSheet: [String: AnyObject] = [String:AnyObject]()
    var arySheetList = [[String: AnyObject]]()
    
    static let k1stGenericTimeSheet: [String] = ["Time in",
                                                 "Time out",
                                                 "Staff signature",
                                                 "Staff name",
                                                 "Total billable time"]
    
    static let k2ndGenericTimeSheet = ["Time in",
                                       "Time out",
                                       "Staff signature",
                                       "Staff name",
                                       "Total billable time",
                                       "Rate",
                                       "Client"
    ]
    
    static let kFirstGenericTemplateName = "Template 1"
    static let kSecondGenericTemplateName = "Template 2"
    
    // Save Template
    static func saveTemplate(tempName: String, tempOtherFields: [String]) {
        
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        
        // 1
        let managedContext = appDelegate.persistentContainer.viewContext
        // 2
        let entity = NSEntityDescription.entity(forEntityName: "TemplatesTable", in: managedContext)!
        let template = NSManagedObject(entity: entity, insertInto: managedContext)
        // 3
        let strOtherFields = tempOtherFields.joined(separator: ",")
        template.setValue(tempName, forKeyPath: "tempName")
        template.setValue(strOtherFields, forKeyPath: "tempOtherFields")
        
        // 4
        do {
            try managedContext.save()
            DataModel.dataTable.append(template)
            print("Saved")
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    static func isTemplateExists(_ name: String, tempOtherFields: [String]) -> Bool {
        let objDataModel = DataModel()
        let templates = objDataModel.getTempData()
        let otherFields = tempOtherFields.joined(separator: ",")
        for tpl in templates {
            let tname = tpl["tempName"]
            if tname == name {
                if let other = tpl["tempOtherFields"] as? String {
                    if otherFields == other{
                        return true
                    }
                }
                
            }
        }
        return false
    }
    
    // Save Timesheet
    static func saveTimesheet(sheetName: String,sheetTempName: String,sheetTimeIn: String?,sheetTimeOut: String?,sheetStaffSign: String?,sheetStaffName: String?,sheetTotalBillableTime: String?, sheetSignDate: String, sheetCreateDate: String, sheetLocation: String, sheetOtherData: String) {
        
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        
        // 1
        let managedContext = appDelegate.persistentContainer.viewContext
        // 2
        let entity = NSEntityDescription.entity(forEntityName: "TimesheetTable", in: managedContext)!
        let sheet = NSManagedObject(entity: entity, insertInto: managedContext)
        // 3
//        let strOtherFields = sheetOtherData.joined(separator: ",")
        sheet.setValue(sheetName, forKeyPath: "sheetName")
        sheet.setValue(sheetTempName, forKeyPath: "sheetTempName")
        if let sheetTimeIn = sheetTimeIn {
            sheet.setValue(sheetTimeIn, forKeyPath: "sheetTimeIn")
        }
        if let sheetTimeOut = sheetTimeOut {
            sheet.setValue(sheetTimeOut, forKeyPath: "sheetTimeOut")
        }
        if let sheetStaffSign = sheetStaffSign {
            sheet.setValue(sheetStaffSign, forKeyPath: "sheetStaffSign")
        }
        if let sheetStaffName = sheetStaffName {
            sheet.setValue(sheetStaffName, forKeyPath: "sheetStaffName")
        }
        if let sheetTotalBillableTime = sheetTotalBillableTime {
            sheet.setValue(sheetTotalBillableTime, forKeyPath: "sheetTotalBillableTime")
        }
        sheet.setValue(sheetSignDate, forKeyPath: "sheetSignDate")
        sheet.setValue(sheetCreateDate, forKeyPath: "sheetCreateDate")
        sheet.setValue(sheetLocation, forKeyPath: "sheetLocation")
        sheet.setValue(sheetOtherData, forKeyPath: "sheetOtherData")
        
        // 4
        do {
            try managedContext.save()
            DataModel.dataTable.append(sheet)
            print("Saved")
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    static func addGenericTemplates() {
        
        let firstTemplateDeleted = UserDefaults.standard.bool(forKey: "firstTemplateDeleted")
        let secondTemplateDeleted = UserDefaults.standard.bool(forKey: "secondTemplateDeleted")

        // Save First generic template
        if (!firstTemplateDeleted){
            if !DataModel.isTemplateExists(kFirstGenericTemplateName, tempOtherFields: DataModel.k1stGenericTimeSheet) {
                DataModel.saveTemplate(tempName: kFirstGenericTemplateName, tempOtherFields: DataModel.k1stGenericTimeSheet)
            }
        }
        
        // Save second generic template
        if (!secondTemplateDeleted){
            if !DataModel.isTemplateExists(kSecondGenericTemplateName, tempOtherFields: DataModel.k2ndGenericTimeSheet) {
                DataModel.saveTemplate(tempName: kSecondGenericTemplateName, tempOtherFields: DataModel.k2ndGenericTimeSheet)
            }
        }
    }
    
    // Get Template Data
    func getTempData() -> [[String:String]] {
      
        self.dictTemplate.removeAll()
        self.tempData.removeAll()
        self.aryTempList.removeAll()
        //1
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return [[:]]
        }
        
        let managedContext =
            appDelegate.persistentContainer.viewContext
        
        //2
        let fetchRequest =
            NSFetchRequest<NSManagedObject>(entityName: "TemplatesTable")
        //3
        do {
            self.tempData = try managedContext.fetch(fetchRequest)
            print(tempData.count)
            for i in 0..<tempData.count {
                let template = tempData[i]
                
                self.dictTemplate["tempName"] = template.value(forKey: "tempName") as? String ?? ""
                self.dictTemplate["tempOtherFields"] = template.value(forKey: "tempOtherFields") as? String ?? ""
                self.aryTempList.append(self.dictTemplate)
            }
            
            return self.aryTempList
//            SVProgressHUD.dismiss()
            
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
//            SVProgressHUD.dismiss()
            return [[:]]
        }
    }
    
    // Get Sheet Data
    func getSheetData() -> [[String:AnyObject]] {
        
        self.dictSheet.removeAll()
        self.sheetData.removeAll()
        self.arySheetList.removeAll()
        //1
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return [[:]]
        }
        
        let managedContext =
            appDelegate.persistentContainer.viewContext
        
        //2
        let fetchRequest =
            NSFetchRequest<NSManagedObject>(entityName: "TimesheetTable")
        //3
        do {
            self.sheetData = try managedContext.fetch(fetchRequest)
            print(sheetData.count)
            for i in 0..<sheetData.count {
                let sheet = sheetData[i]
                
                self.dictSheet["sheetName"] = "\(sheet.value(forKey: "sheetName") ?? "")" as AnyObject
                self.dictSheet["sheetTimeIn"] = sheet.value(forKey: "sheetTimeIn") as AnyObject//"\(sheet.value(forKey: "sheetTimeIn") ?? "")" as AnyObject
                self.dictSheet["sheetCreateDate"] = "\(sheet.value(forKey: "sheetCreateDate") ?? "")" as AnyObject
                self.dictSheet["sheetStaffName"] = sheet.value(forKey: "sheetStaffName") as AnyObject //"\(sheet.value(forKey: "sheetStaffName") ?? "")" as AnyObject
                self.dictSheet["sheetSignDate"] = "\(sheet.value(forKey: "sheetSignDate") ?? "")" as AnyObject
                self.dictSheet["sheetLocation"] = "\(sheet.value(forKey: "sheetLocation") ?? "")" as AnyObject
                self.dictSheet["sheetTempName"] = "\(sheet.value(forKey: "sheetTempName") ?? "")" as AnyObject
                self.dictSheet["sheetTotalBillableTime"] = sheet.value(forKey: "sheetTotalBillableTime") as AnyObject //"\(sheet.value(forKey: "sheetTotalBillableTime") ?? "")" as AnyObject
                self.dictSheet["sheetTimeOut"] = sheet.value(forKey: "sheetTimeOut") as AnyObject //"\(sheet.value(forKey: "sheetTimeOut") ?? "")" as AnyObject
                self.dictSheet["sheetStaffSign"] = sheet.value(forKey: "sheetStaffSign") as AnyObject //"\(sheet.value(forKey: "sheetStaffSign") ?? "")" as AnyObject
                self.dictSheet["sheetOtherData"] = "\(sheet.value(forKey: "sheetOtherData")!)" as AnyObject
                
                //self.arySheetList.append(self.dictSheet)
                self.arySheetList.insert(self.dictSheet, at: 0)
            }
            
            return self.arySheetList
            //            SVProgressHUD.dismiss()
            
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
            //            SVProgressHUD.dismiss()
            return [[:]]
        }
    }
    func deleteTemplate(tempName: String) {
        
        //1
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        let managedContext =
            appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "TemplatesTable")
        let predicate = NSPredicate(format: "tempName == %@", tempName )
        fetchRequest.predicate = predicate
        
        let result = try? managedContext.fetch(fetchRequest)
        let resultData = result as! [TemplatesTable]
        
        for object in resultData {
            print(object)
            
            // "First generic template", "Second generic template"
            if let name = object.value(forKey: "tempName") as? String {
                if name == DataModel.kFirstGenericTemplateName {
                    if let other = object.value(forKey: "tempOtherFields") as? String {
                        if other == DataModel.k1stGenericTimeSheet.joined(separator: ","){
                            UserDefaults.standard.set(true, forKey: "firstTemplateDeleted")
                        }
                    }
                }
                else if name == DataModel.kSecondGenericTemplateName {
                    if let other = object.value(forKey: "tempOtherFields") as? String {
                        if other == DataModel.k2ndGenericTimeSheet.joined(separator: ","){
                            UserDefaults.standard.set(true, forKey: "secondTemplateDeleted")
                        }
                    }
                }
            }
            
            
            managedContext.delete(object)
            
        }
        do {
            try managedContext.save()
            
            print("Deleted!")
            
        } catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)")
        }
    }
    func deleteSheet(sheetName: String) {
        
        //1
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        let managedContext =
            appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "TimesheetTable")
        let predicate = NSPredicate(format: "sheetName == %@", sheetName )
        fetchRequest.predicate = predicate
        
        let result = try? managedContext.fetch(fetchRequest)
        let resultData = result as! [TimesheetTable]
        
        for object in resultData {
            print(object)
            managedContext.delete(object)
        }
        do {
            try managedContext.save()
            
            print("Deleted!")
            
        } catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)")
        }
    }
}
