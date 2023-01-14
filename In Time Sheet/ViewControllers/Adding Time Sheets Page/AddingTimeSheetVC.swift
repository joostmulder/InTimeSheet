//
//  AddingTimeSheetVC.swift
//  In Time Sheet
//
//  Created by apple on 21/03/19.
//  Copyright © 2019 Sonu Singh. All rights reserved.
//

import UIKit

var totalHours = 0
var totalMinutes = 0

class AddingTimeSheetVC: UIViewController {

    var delegate: SaveTempDelegate?
    var strTempName = String()
    var strPickerType = "timeIn"
    var signImage = false
    var aryNewTypes: [String] = [String]()
    //var aryNewSheetTypes: [String:AnyObject] = [String:AnyObject]()
    var strNewSheetType = String()
    var aryNewSheetValue: [String] = [String]()
    var dictNewSheet: [String:AnyObject] = [String:AnyObject]()
    
    var aryHours = [Int]()
    var aryMinutes = [Int]()
    var hrs = ""
    var min = ""
    
    var isIndexSelected = false
    var minDate = Date()
    var timeInDate = Date()
    var timeOutDate = Date()
    var billableTimeDate = Date()
    
    var hasTimeIn = false
    var hasTimeOut = false
    var hasStaffSignature = false
    var hasStaffName = false
    var hasTotalBillableTime = false

    
    // Outlets
    @IBOutlet weak var tableVW: UITableView!
    @IBOutlet weak var txtSheetName: UITextField!
    @IBOutlet weak var btnTimeIn: UIButton!
    @IBOutlet weak var btnTimeOut: UIButton!
    @IBOutlet weak var btnStaffSign: UIButton!
    @IBOutlet weak var txtStaffName: UITextField!
    @IBOutlet weak var btnBillableTime: UIButton!
    // TimePicker
    @IBOutlet weak var viewTimePicker: UIView!
    @IBOutlet weak var timePicker: UIDatePicker!
    @IBOutlet weak var pickerVW: UIPickerView!
    @IBOutlet weak var labelTitle: UILabel!
    //@IBOutlet weak var itemsViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var headerView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableVW.dataSource = self
        self.tableVW.delegate = self
        self.tableVW.tableFooterView = UIView()
        
        //print(self.aryNewTypes)
        
        var aryRemoveTypes: [String] = [String]()
        
        if !self.aryNewTypes.isEmpty {
            for item in self.aryNewTypes {
                self.aryNewSheetValue.append("")
                
                print("\(item)")
                if item == "Time in"{
                    hasTimeIn = true
                    aryRemoveTypes.append(item)
                }
                else if item == "Time out"{
                    hasTimeOut = true
                    aryRemoveTypes.append(item)
                }
                else if item == "Staff signature"{
                    hasStaffSignature = true
                    aryRemoveTypes.append(item)
                }
                else if item == "Staff name"{
                    hasStaffName = true
                    aryRemoveTypes.append(item)
                }
                else if item == "Total billable time"{
                    hasTotalBillableTime = true
                    aryRemoveTypes.append(item)
                }
            }
        }
        
        // Remove "Time in", "Time out", "Staff signature", "Staff name", "Total billable time" from aryNewTypes
        self.aryNewTypes.removeAll { (item) -> Bool in
            return aryRemoveTypes.contains(item)
        }
        
        var frame = self.headerView.frame
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
        self.headerView.frame = frame
        
        /*
        else {
            self.txtSheetName.text = self.aryNewSheetTypes["sheetName"] as? String
            self.txtStaffName.text = self.aryNewSheetTypes["sheetStaffName"] as? String
            self.btnTimeIn.setTitle(self.aryNewSheetTypes["sheetTimeIn"] as? String, for: .normal)
            self.btnTimeOut.setTitle(self.aryNewSheetTypes["sheetTimeOut"] as? String, for: .normal)
            self.btnBillableTime.setTitle(self.aryNewSheetTypes["sheetTotalBillableTime"] as? String, for: .normal)
            
            let img = self.getImageFromBase64(base64: self.aryNewSheetTypes["sheetStaffSign"] as? String ?? "")
            self.btnStaffSign.setImage(img, for: .normal)
            self.signImage = (img != nil)
            
            self.btnTimeIn.setTitle(self.aryNewSheetTypes["sheetTimeIn"] as? String, for: .normal)
            
            let otherData: String = self.aryNewSheetTypes["sheetOtherData"] as? String ?? String()
            let aryOtherData: [String] = otherData.components(separatedBy: ",")
            
            for item in aryOtherData {
                let aryNew: [String] = item.components(separatedBy: ":")
                if aryNew[0] != "" {
                    //self.aryNewTypes.append([aryNew[0]:aryNew[1]])
                    //self.aryNewTempTypes.append(aryNew[0])
                    
                    self.aryNewSheetValue.append(aryNew[1])
                    self.aryNewTypes.append(aryNew[0])
                }
            }
 
            // Must init dictNewSheet
            for item in self.aryNewSheetTypes {
                self.dictNewSheet[item.key] = item.value
            }

            self.tableVW.reloadData()

            self.labelTitle.text  = "Edit time sheet"
        }
        */
        
        self.aryHours.removeAll()
        self.aryMinutes.removeAll()
        for i in 0..<24 {
            self.aryHours.append(i)
        }
        for i in 0..<60 {
            self.aryMinutes.append(i)
        }
        print(aryHours)
        print(aryMinutes)
        // Do any additional setup after loading the view.
    }
    
    // Button Actions
    @IBAction func clickedTimeIn(_ sender: Any) {
        self.pickerVW.isHidden = true
        self.timePicker.isHidden = false
        self.view.endEditing(true)
        self.timePicker.minimumDate = nil
        self.timePicker.setDate(self.timeInDate, animated: false)
        self.strPickerType = "timeIn"
        self.timePicker.datePickerMode = UIDatePicker.Mode.time
        self.viewTimePicker.isHidden = false
    }
    @IBAction func clickedTimeOut(_ sender: Any) {
        self.view.endEditing(true)
        if self.btnTimeIn.titleLabel?.text == "Select" {
            self.showAlert(title: "Please enter time in first")
        }
        else {
            self.pickerVW.isHidden = true
            self.timePicker.isHidden = false
            //self.timePicker.minimumDate = self.minDate
            self.timePicker.setDate(self.timeOutDate, animated: false)
            self.strPickerType = "timeOut"
            self.timePicker.datePickerMode = UIDatePicker.Mode.time
            self.viewTimePicker.isHidden = false
        }
    }
    @IBAction func clickedSign(_ sender: Any) {
        self.view.endEditing(true)
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "DialogStaffSignature") as! DialogStaffSignature
        vc.delegate = self
        vc.modalPresentationStyle = .overCurrentContext
        self.navigationController?.present(vc, animated: false, completion: nil)
    }
    @IBAction func clickedTotalTime(_ sender: Any) {
        self.view.endEditing(true)
        self.strPickerType = "totalTime"
        self.pickerVW.isHidden = false
        self.timePicker.isHidden = true
//        self.timePicker.setDate(self.billableTimeDate, animated: false)
//        self.timePicker.datePickerMode = UIDatePicker.Mode.countDownTimer
        self.viewTimePicker.isHidden = false
    }
    @IBAction func clickedCancel(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func clickedCreatePDF(_ sender: Any) {
        
//        let name = Notification.Name("didReceiveData")
//
//        NotificationCenter.default.post(name: name, object: self, userInfo: ["name":self.txtSheetName.text!, "date":"21/03/2019"])

        let message = "Are you sure you want to go on without "
        var missingFields = ""
        
        if self.txtSheetName.text?.trimmingCharacters(in: .whitespaces).isEmpty == true {
            missingFields += "reference number"
        }
            
        if self.btnTimeIn.titleLabel?.text == "Select" {
            if !missingFields.isEmpty {
                missingFields += ", "
            }
            missingFields += "time in"
        }
            
        if self.btnTimeOut.titleLabel?.text == "Select" {
            if !missingFields.isEmpty {
                missingFields += ", "
            }
            missingFields += "time out"
        }
            
        if self.signImage == false {
            if !missingFields.isEmpty {
                missingFields += ", "
            }
            missingFields += "staff signature"
        }
            
        if self.txtStaffName.text?.trimmingCharacters(in: .whitespaces).isEmpty == true {
            if !missingFields.isEmpty {
                missingFields += ", "
            }
            missingFields += "staff name"
        }
            
        if self.btnBillableTime.titleLabel?.text == "Select" {
            if !missingFields.isEmpty {
                missingFields += ", "
            }
            missingFields += "total billable time"
        }
        
        if !missingFields.isEmpty {
            let alert = UIAlertController(title: message + missingFields + "?", message: nil, preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                self.createPdf()
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
                
            }))
            
            self.present(alert, animated: true)
        }
        else {
            createPdf()
        }
    }
    
    private func createPdf(){
        if self.hasTotalBillableTime {
            var value = self.btnBillableTime.titleLabel?.text!
            if value == "Select"{
                value = ""
            }
            self.dictNewSheet["sheetTotalBillableTime"] = value as AnyObject
        }
        
        self.dictNewSheet["sheetName"] = self.txtSheetName.text as AnyObject
        self.dictNewSheet["sheetTempName"] = self.strTempName as AnyObject
        
        if self.hasStaffName {
            self.dictNewSheet["sheetStaffName"] = self.txtStaffName.text as AnyObject
        }
        
        if self.hasTimeIn {
            if self.dictNewSheet["sheetTimeIn"] == nil {
                self.dictNewSheet["sheetTimeIn"] = "" as AnyObject
            }
        }
        
        if self.hasTimeOut {
            if self.dictNewSheet["sheetTimeOut"] == nil {
                self.dictNewSheet["sheetTimeOut"] = "" as AnyObject
            }
        }
        
        if self.hasStaffSignature {
            if self.dictNewSheet["sheetStaffSign"] == nil {
                self.dictNewSheet["sheetStaffSign"] = "" as AnyObject
            }
        }
        
        var sheetLocation = ""
        if UserDefaults.standard.bool(forKey: "isLocationEnabled") == true {
            sheetLocation = UserDefaults.standard.string(forKey: "myLocation") ?? ""
        }
        self.dictNewSheet["sheetLocation"] = sheetLocation as AnyObject
        self.dictNewSheet["sheetOtherData"] = self.strNewSheetType as AnyObject
        //            createPDF()
        //  print(dictNewSheet)
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "ResultPDFVC") as! ResultPDFVC
        vc.new = true
        vc.img = self.btnStaffSign.imageView?.image ?? UIImage()
        vc.dictNewSheet = self.dictNewSheet
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    // Time Picker Button Actions
    @IBAction func clickedCancelPicker(_ sender: Any) {
        self.strPickerType = "timeIn"
        self.viewTimePicker.isHidden = true
    }
    @IBAction func clickedSaveTime(_ sender: Any) {
        if self.strPickerType == "timeIn" {
            let formatter = DateFormatter()
            formatter.timeStyle = .short
            self.btnTimeIn.setTitle("\(formatter.string(from: self.timePicker.date))", for: .normal)
            self.dictNewSheet["sheetTimeIn"] = "\(formatter.string(from: self.timePicker.date))" as AnyObject
            self.strPickerType = "timeIn"
            self.viewTimePicker.isHidden = true
            self.btnTimeIn.setTitleColor(UIColor.black, for: .normal)
            let billableTime = self.timeDifference(timeIn: "\(formatter.string(from: self.timePicker.date))", timeOut: self.btnTimeOut.titleLabel?.text ?? "")
            self.btnBillableTime.setTitle(billableTime, for: .normal)
            self.billableTimeDate = self.timePicker.date
            self.btnBillableTime.setTitleColor(UIColor.black, for: .normal)
            // Minimum time
            self.minDate = self.timePicker.date
            self.timeInDate = self.minDate
            self.pickerVW.selectRow(totalHours, inComponent: 0, animated: false)
            self.pickerVW.selectRow(totalMinutes, inComponent: 1, animated: false)
            //self.pickerVW.reloadAllComponents()
            // End of Minimum Time
        }
        else if self.strPickerType == "timeOut" {
            let formatter = DateFormatter()
            formatter.timeStyle = .short
            self.btnTimeOut.setTitle("\(formatter.string(from: self.timePicker.date))", for: .normal)
            self.dictNewSheet["sheetTimeOut"] = "\(formatter.string(from: self.timePicker.date))" as AnyObject
            self.strPickerType = "timeIn"
            self.viewTimePicker.isHidden = true
            self.btnTimeOut.setTitleColor(UIColor.black, for: .normal)
            let billableTime = self.timeDifference(timeIn: self.btnTimeIn.titleLabel?.text ?? "", timeOut: "\(formatter.string(from: self.timePicker.date))")
            self.btnBillableTime.setTitle(billableTime, for: .normal)
            self.billableTimeDate = self.timePicker.date
           // self.dictNewSheet["sheetTotalBillableTime"] = self.btnBillableTime.titleLabel?.text as AnyObject
            self.btnBillableTime.setTitleColor(UIColor.black, for: .normal)
            self.timeOutDate = self.timePicker.date
            
            self.pickerVW.selectRow(totalHours, inComponent: 0, animated: false)
            self.pickerVW.selectRow(totalMinutes, inComponent: 1, animated: false)
            //self.pickerVW.reloadAllComponents()
        }
        else {
            
            if hrs == "" {
                hrs = "0"
            }
            if min == "" {
                min = "0"
            }
            self.btnBillableTime.setTitle("\(hrs ) hrs:\(min ) min", for: .normal)
            //self.dictNewSheet["sheetTotalBillableTime"] = self.btnBillableTime.titleLabel?.text as AnyObject
            
//            let formatter = DateComponentsFormatter()
//            formatter.unitsStyle = .positional
//            formatter.allowedUnits = [ .hour, .minute ]
//            formatter.zeroFormattingBehavior = [ .pad ]
//            let formattedDuration = formatter.string(from: self.timePicker.countDownDuration)
//            let BT = formattedDuration?.components(separatedBy: ":")
//            self.btnBillableTime.setTitle("\(BT?[0] ?? "0") hrs:\(BT?[1] ?? "0") min", for: .normal)
//            self.dictNewSheet["sheetTotalBillableTime"] = "\(BT?[0] ?? "0") hrs:\(BT?[1] ?? "0") min" as AnyObject
            self.strPickerType = "timeIn"
            self.billableTimeDate = self.timePicker.date
            self.viewTimePicker.isHidden = true
            self.btnBillableTime.setTitleColor(UIColor.black, for: .normal)
        }
    }
    
    // Cell TextField Data Save
    @IBAction func saveCellText(sender: UITextField) {
       
        print(sender.tag)
        if sender.text?.trimmingCharacters(in: .whitespaces).isEmpty == false {
            let indexpath = IndexPath(row: sender.tag, section: 0)
            let cell = self.tableVW.cellForRow(at: indexpath) as! AddingTimeSheetTableCell
            self.aryNewSheetValue.insert(sender.text ?? "", at: sender.tag)
            
            if self.strNewSheetType == "" {
                
                self.strNewSheetType = "\(cell.lblType.text ?? ""):\(cell.txtValue.text as AnyObject)"
            }
            else {
                self.strNewSheetType = self.strNewSheetType + "," + "\(cell.lblType.text ?? ""):\(cell.txtValue.text as AnyObject)"
            }
        }
    }
    
    // Image To Base64
    public enum ImageFormat {
        case png
    }
    func convertImageTobase64(format: ImageFormat, image:UIImage) -> String? {
        var imageData: Data?
        switch format {
        case .png: imageData = image.pngData()
        }
        return imageData?.base64EncodedString()
    }
    
    // Create PDF
    func createPDF() {

         let html = "<br><br>\(self.dictNewSheet["sheetName"] as? String ?? "")<br><br><br><b>Start Time:</b> \(self.dictNewSheet["sheetTimeIn"]  as? String ?? "")<br><br><b>End Time:</b> \(self.dictNewSheet["sheetTimeOut"] as? String ?? "")<br><br><b>Date:</b> \(self.dictNewSheet["sheetCreateDate"] as? String ?? "")<br><br><b>Total billable time:</b> \(self.dictNewSheet["sheetTotalBillableTime"] as? String ?? "")<br><br><b>Staff Name:</b> \(self.dictNewSheet["sheetStaffName"] as? String ?? "")<br><br><b>Staff signature:</b> ( sign here )<br><b>Dated:</b> \(self.dictNewSheet["sheetSignDate"] as? String ?? "")<br><b>Location:</b> \(self.dictNewSheet["sheetLocation"] as? String ?? "")<br><br>I hereby certify that the contractor was present during the time listed above."
        
        //  \(self.dictNewSheet["sheetStaffSign"] as? String ?? "")
        
        let fmt = UIMarkupTextPrintFormatter(markupText: html)
        
        // 2. Assign print formatter to UIPrintPageRenderer
        
        let render = UIPrintPageRenderer()
        render.addPrintFormatter(fmt, startingAtPageAt: 0)
        
        // 3. Assign paperRect and printableRect
        
        let page = CGRect(x: 0, y: 0, width: 595.2, height: 841.8) // A4, 72 dpi
        let printable = page.insetBy(dx: 0, dy: 0)
        
        render.setValue((page), forKey: "paperRect")
        render.setValue((printable), forKey: "printableRect")
        
        // 4. Create PDF context and draw
        
        let pdfData = NSMutableData()
        UIGraphicsBeginPDFContextToData(pdfData, .zero, nil)
        
        for i in 1...render.numberOfPages {
            UIGraphicsBeginPDFPage();
            let bounds = UIGraphicsGetPDFContextBounds()
            render.drawPage(at: i - 1, in: bounds)
        }
        
        UIGraphicsEndPDFContext();
        
        // 5. Save PDF file
        
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        
        pdfData.write(toFile: "\(documentsPath)/InTimeSheet.pdf", atomically: true)
        //   print(documentsPath)
        
        let filePath = "\(documentsPath+"/InTimeSheet.pdf")"
        print(filePath)
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "ResultPDFVC") as! ResultPDFVC
      //  vc.strFileURL = "\(filePath)"
        //vc.strImageURL = "\(image1)"
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
extension AddingTimeSheetVC: DialogStaffSignatureDelegate {
   
    func signComplete(sign: UIImage) {
        self.btnStaffSign.setImage(sign, for: .normal)
        let signDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short
        dateFormatter.locale = Locale(identifier: "en_US")
        self.signImage = true
        self.dictNewSheet["sheetSignDate"] = "\(dateFormatter.string(from: signDate))" as AnyObject
        
        let base64String = convertImageTobase64(format: .png, image: sign)
        self.dictNewSheet["sheetStaffSign"] = base64String as AnyObject
        
        print(dateFormatter.string(from: signDate)) // Jan 2, 2001
        
    }
}
extension AddingTimeSheetVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.aryNewTypes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "AddingTimeSheetTableCell") as! AddingTimeSheetTableCell
        
        cell.lblType.text = self.aryNewTypes[indexPath.row]
        cell.lblType.tag = indexPath.row
        cell.txtValue.tag = indexPath.row
        
        cell.txtValue.text = self.aryNewSheetValue[indexPath.row]
        
        cell.txtValue.addTarget(self, action: #selector(self.saveCellText(sender:)), for: .editingDidEnd)
        
        return cell
    }
}
extension AddingTimeSheetVC: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        if component == 0 {
            return self.aryHours.count
        }
        return self.aryMinutes.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        if component == 0 {
            return "\(self.aryHours[row]) hrs"
        }
        else {
            return "\(self.aryMinutes[row]) min"
        }
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        if component == 0 {
            self.hrs = "\(self.aryHours[row])"
        }
        else {
            self.min = "\(self.aryMinutes[row])"
        }
    }
}
extension UIViewController {
    func timeDifference(timeIn: String, timeOut: String) -> String {
        
        if timeIn != "" && timeOut != "" && timeIn != "Select" && timeOut != "Select" {
            let formatter = DateFormatter()
            formatter.dateFormat = "h:mma"
            
            let date1 = formatter.date(from: timeIn)!
            var date2 = formatter.date(from: timeOut)!
            
            if date2 < date1 {
                date2 = Calendar.current.date(byAdding: .day, value: 1, to: date2)!
            }
            let elapsedTime = date2.timeIntervalSince(date1)
            
            // convert from seconds to hours, rounding down to the nearest hour
            let hours = floor(elapsedTime / 60 / 60)
            
            // we have to subtract the number of seconds in hours from minutes to get
            // the remaining minutes, rounding down to the nearest minute (in case you
            // want to get seconds down the road)
            let minutes = floor((elapsedTime - (hours * 60 * 60)) / 60)
            
            print("\(Int(hours)) hr and \(Int(minutes)) min")
            
            totalHours = Int(hours)
            totalMinutes = Int(minutes)
            
            return "\(Int(hours)) hrs:\(Int(minutes)) min"
        }
        return ""
    }
}
