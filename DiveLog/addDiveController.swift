//
//  addDiveController.swift
//  DiveLog
//
//  Created by Michael Whinfrey on 6/7/18.
//  Copyright © 2018 Michael Whinfrey. All rights reserved.
//

import UIKit
import CloudKit
import CoreData

class AddDiveController: UIViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
    var dives: [NSManagedObject] = []
    
    var coreDataManager: CoreDataManager!
    
    // Initialize global variables
    var lat = ""
    var long = ""
    var timeInString = ""
    var timeOutString = ""
    var btmTimeReal = ""
    var timeInHour = Int()
    var timeInMin = Int()
    var timeOutHour = Int()
    var timeOutMin = Int()
    var autoCompleteCharacterCount = 0
    var timer = Timer()
    var csvRows: [[String]] = []
    var diveIndex: [Int] = []
    var scrollViewOffset = CGPoint()
    
    // Set up IBOutlets and IBActions
    @IBOutlet weak var scrollView: UIScrollView!
    @IBAction func unwindToAdd(unwindSegue: UIStoryboardSegue) {
    }
    @IBOutlet weak var diveNoBox: UITextField!
    @IBOutlet weak var dateBox: UITextField!
    @IBOutlet weak var diveSiteBox: UITextField!
    @IBOutlet weak var locationBox: UITextField!
    @IBOutlet weak var countryBox: UITextField!
    @IBOutlet weak var timeInBox: UITextField!
    @IBOutlet weak var timeOutBox: UITextField!
    @IBOutlet weak var depthBox: UITextField!
    @IBOutlet weak var btmTimeBox: UITextField!
    @IBOutlet weak var latBox: UITextField!
    @IBOutlet weak var longBox: UITextField!
    @IBOutlet weak var ssDepthBox: UITextField!
    @IBOutlet weak var ssDurationBox: UITextField!
    @IBOutlet weak var surfaceIntervalBox: UITextField!
    @IBOutlet weak var divemasterBox: UITextField!
    @IBOutlet weak var diveTypeBox: UITextField!
    @IBOutlet weak var divemasterNumBox: UITextField!
    @IBOutlet weak var airTempBox: UITextField!
    @IBOutlet weak var waterTempBox: UITextField!
    @IBOutlet weak var visibilityBox: UITextField!
    @IBOutlet weak var weightBox: UITextField!
    @IBOutlet weak var tpStartBox: UITextField!
    @IBOutlet weak var tpEndBox: UITextField!
    @IBOutlet weak var notesBox: UITextField!
    
    @IBAction func saveButtonTapped(_ sender: Any) {
        
        let diveNoText = diveNoBox.unwrappedText
        let dateText = dateBox.unwrappedText
        let diveSiteText = diveSiteBox.unwrappedText
        let locationText = locationBox.unwrappedText
        let countryText = countryBox.unwrappedText
        let depthText = depthBox.unwrappedText + "m"
        let btmTimeText = btmTimeBox.unwrappedText + " min"
        let latText = latBox.unwrappedText
        let longText = longBox.unwrappedText
        var latDouble = Double(latText)
        var longDouble = Double(longText)
        let timeInText = timeInBox.unwrappedText
        let timeOutText = timeOutBox.unwrappedText
        let diveTypeText = diveTypeBox.unwrappedText
        let ssDepthText = ssDepthBox.unwrappedText
        let ssDurationText = ssDepthBox.unwrappedText
        let surfaceIntervalText = surfaceIntervalBox.unwrappedText
        let divemasterText = divemasterBox.unwrappedText
        let divemasterNumText = divemasterNumBox.unwrappedText
        let airTempText = airTempBox.unwrappedText
        let waterTempText = waterTempBox.unwrappedText
        let visibilityText = visibilityBox.unwrappedText
        let weightText = weightBox.unwrappedText
        let tpStartText = tpStartBox.unwrappedText
        let tpEndText = tpEndBox.unwrappedText
        let notesText = notesBox.unwrappedText
        
        if latText.isEmpty == true {
            latDouble = -12.712
            longDouble = 90.402
        }
        
        coreDataManager = CoreDataManager(modelName: "DiveModel")
        
        let managedContext = coreDataManager.managedObjectContext
        
        let entity =
            NSEntityDescription.entity(forEntityName: "DiveInstance",
                                       in: managedContext)!
        
        let dive = NSManagedObject(entity: entity,
                                   insertInto: managedContext)
        
        dive.setValue(diveNoText, forKeyPath: "diveNo")
        dive.setValue(dateText, forKeyPath: "date")
        dive.setValue(diveSiteText, forKeyPath: "diveSite")
        dive.setValue(locationText, forKeyPath: "location")
        dive.setValue(countryText, forKeyPath: "country")
        dive.setValue(depthText, forKeyPath: "depth")
        dive.setValue(btmTimeText, forKeyPath: "bottomTime")
        dive.setValue(latDouble, forKeyPath: "latitude")
        dive.setValue(longDouble, forKeyPath: "longitude")
        dive.setValue(timeInText, forKeyPath: "timeIn")
        dive.setValue(timeOutText, forKeyPath: "timeOut")
        dive.setValue(diveTypeText, forKeyPath: "diveType")
        dive.setValue(ssDepthText, forKeyPath: "safetyStopDepth")
        dive.setValue(ssDurationText, forKeyPath: "safetyStopDuration")
        dive.setValue(surfaceIntervalText, forKeyPath: "surfaceInterval")
        dive.setValue(divemasterText, forKeyPath: "diveMasterName")
        dive.setValue(divemasterNumText, forKeyPath: "diveMasterNum")
        dive.setValue(airTempText, forKeyPath: "airTemp")
        dive.setValue(waterTempText, forKeyPath: "waterTemp")
        dive.setValue(visibilityText, forKeyPath: "visibility")
        dive.setValue(weightText, forKeyPath: "weight")
        dive.setValue(tpStartText, forKeyPath: "startTankPressure")
        dive.setValue(tpEndText, forKeyPath: "endTankPressure")
        dive.setValue(notesText, forKeyPath: "diveNotes")
        
        do {
            try managedContext.save()
            dives.append(dive)
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
        
        performSegue(withIdentifier: "unwindToDiveList", sender: Any?.self)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var data = readDataFromCSV(fileName: "testerbook", fileType: "csv")
        
        data = cleanRows(file: data!)
        csvRows = csv(data: data!)
        
        // Hide keyboard upon screen tap
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
    
        view.addGestureRecognizer(tap)
        
        // Set up textfields
        setInitialDateBoxText()
        setDiveNumberTextfield()
        setDepthTextfield()
        setBottomTimeTextfield()
        setDiveSiteTextfieldAutocomplete()
        setTimeInTextfield()
        setTimeOutTextfield()
        setDateTextfield()
        setLatLongTextfields()
        setRemainingTextfieldDelegates()
        setAutoCapitalizationTextfields()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // set initial pickerView values
        let diveNoPickerRow = dives.count
        diveNoPicker.selectRow(diveNoPickerRow, inComponent: 0, animated: true)
        
        if depthBox.text?.isEmpty == false {
            let depthPickerRow = Int(depthBox.text!)! - 1
            depthPicker.selectRow(depthPickerRow, inComponent: 0, animated: true)
        }
        
        if btmTimeBox.text?.isEmpty == false {
            let btmTimePickerRow = Int(btmTimeBox.text!)! - 1
            btmTimePicker.selectRow(btmTimePickerRow, inComponent: 0, animated: true)
        }
        
        if timeInString.isEmpty && timeOutString.isEmpty == false {
            btmTimeBox.text = btmTimeReal
        }
        
        if lat.isEmpty == false {
            latBox.text = lat
            longBox.text = long
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.destination is DiveListController
        {
            let vc = segue.destination as? DiveListController
            vc?.dives = dives
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // dismiss keyboard upon tap event
    @objc func dismissKeyboard() {
        if diveSiteBox.becomeFirstResponder() == true {
            let countryAutoString = diveSiteBox.text
            if countryAutoString!.isEmpty == false {
                let indexEndOfText = countryAutoString!.index(countryAutoString!.endIndex, offsetBy: (-autoCompleteCharacterCount - 1))
                let substring = countryAutoString![...indexEndOfText]
                let newstring = String(substring)
                diveSiteBox.text = newstring
            }
        }
        
        view.endEditing(true)
        scrollView.setContentOffset(scrollViewOffset, animated: true)
    }
    
    func setInitialDateBoxText() {
        let date = Date()
        let calendar = Calendar.current
        let day = calendar.component(.day, from: date)
        let month = calendar.component(.month, from: date)
        let year = calendar.component(.year, from: date)
        let dayString = String(day)
        let monthString = String(month)
        let yearString = String(year)
        dateBox.text = "\(monthString)/\(dayString)/\(yearString)"
    }
    
    func setDiveNumberTextfield() {
        diveNoPicker.delegate = self
        diveNoPicker.dataSource = self
        diveNoBox.inputView = diveNoPicker
        diveNoBox.text = String(dives.count + 1)
        diveNoBox.delegate = self
    }
    
    func setDepthTextfield() {
        depthBox.delegate = self
        depthPicker.delegate = self
        depthPicker.dataSource = self
        depthBox.inputView = depthPicker
    }
    
    func setBottomTimeTextfield() {
        btmTimePicker.delegate = self
        btmTimePicker.dataSource = self
        btmTimeBox.inputView = btmTimePicker
        btmTimeBox.delegate = self
    }
    
    func setDiveSiteTextfieldAutocomplete() {
        diveSiteBox.autocorrectionType = .no
        diveSiteBox.autocapitalizationType = .none
    }
    
    func setTimeInTextfield() {
        timeInPicker.datePickerMode = .time
        timeInPicker.addTarget(self, action: #selector(handleDatePicker(sender:)), for: UIControlEvents.valueChanged)
        timeInBox.inputView = timeInPicker
        timeInBox.delegate = self
    }
    
    func setTimeOutTextfield() {
        timeOutPicker.datePickerMode = .time
        timeOutPicker.addTarget(self, action: #selector(handleDatePicker(sender:)), for: UIControlEvents.valueChanged)
        timeOutBox.inputView = timeOutPicker
        timeOutBox.delegate = self
    }
    
    func setDateTextfield() {
        datePicker.datePickerMode = .date
        datePicker.addTarget(self, action: #selector(handleDatePicker(sender:)), for: UIControlEvents.valueChanged)
        dateBox.inputView = datePicker
        dateBox.delegate = self
    }
    
    func setLatLongTextfields() {
        latBox.delegate = self
        longBox.delegate = self
    }
    
    func setRemainingTextfieldDelegates() {
        diveTypeBox.delegate = self
        diveSiteBox.delegate = self
        locationBox.delegate = self
        countryBox.delegate = self
        ssDepthBox.delegate = self
        ssDurationBox.delegate = self
        surfaceIntervalBox.delegate = self
        divemasterBox.delegate = self
        divemasterNumBox.delegate = self
        airTempBox.delegate = self
        waterTempBox.delegate = self
        visibilityBox.delegate = self
        weightBox.delegate = self
        tpStartBox.delegate = self
        tpEndBox.delegate = self
        notesBox.delegate = self
    }
    
    func setAutoCapitalizationTextfields() {
        locationBox.autocapitalizationType = UITextAutocapitalizationType.words
        countryBox.autocapitalizationType = UITextAutocapitalizationType.words
        diveTypeBox.autocapitalizationType = UITextAutocapitalizationType.words
        divemasterBox.autocapitalizationType = UITextAutocapitalizationType.words
        notesBox.autocapitalizationType = UITextAutocapitalizationType.sentences
    }
    
    // Set up Dive Site textField autocomplete
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == diveSiteBox {
            var subString = (textField.text!.capitalized as NSString).replacingCharacters(in: range, with: string)
            subString = formatSubstring(subString: subString)
        
            if subString.count == 0 { // when a user clears the textField
                resetValues()
            } else {
                searchAutocompleteEntriesWIthSubstring(substring: subString)
            }
        }
            return true
    }
    
    func formatSubstring(subString: String) -> String {
        let formatted = String(subString.dropLast(autoCompleteCharacterCount)).lowercased().capitalized
        return formatted
    }
    
    func resetValues() {
        autoCompleteCharacterCount = 0
        diveSiteBox.text = ""
    }
    
    func searchAutocompleteEntriesWIthSubstring(substring: String) {
        let userQuery = substring
        let autoCompleteSuggestions = getAutocompleteSuggestions(userText: substring)
        
        if diveSiteBox.becomeFirstResponder() == true {
            if autoCompleteSuggestions.count > 0 {
                timer = .scheduledTimer(withTimeInterval: 0.01, repeats: false, block: { (timer) in
                    let autocompleteResult = self.formatAutocompleteResult(substring: substring, possibleMatches: autoCompleteSuggestions)
                    self.putColourFormattedTextInTextField(autocompleteResult: autocompleteResult, userQuery : userQuery)
                    self.moveCaretToEndOfUserQueryPosition(userQuery: userQuery)
                })
            } else {
                timer = .scheduledTimer(withTimeInterval: 0.01, repeats: false, block: { (timer) in
                    self.diveSiteBox.text = substring
                })
                autoCompleteCharacterCount = 0
            }
        }
    }
    
    func getAutocompleteSuggestions(userText: String) -> [String]{
        var possibleMatches: [String] = []
        for (index, _) in csvRows.enumerated() {
            let myString:NSString! = csvRows[index][0] as NSString

            let substringRange :NSRange! = myString.range(of: userText)
            
            if (substringRange.location == 0)
            {
                possibleMatches.append(csvRows[index][0])
                diveIndex.append(index)
            }
        }
        return possibleMatches
    }
    
    func putColourFormattedTextInTextField(autocompleteResult: String, userQuery : String) {
        let colouredString: NSMutableAttributedString = NSMutableAttributedString(string: userQuery + autocompleteResult)
        colouredString.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor.gray, range: NSRange(location: userQuery.count,length:autocompleteResult.count))
        self.diveSiteBox.attributedText = colouredString
    }
    
    func moveCaretToEndOfUserQueryPosition(userQuery : String) {
        if let newPosition = self.diveSiteBox.position(from: self.diveSiteBox.beginningOfDocument, offset: userQuery.count) {
            self.diveSiteBox.selectedTextRange = self.diveSiteBox.textRange(from: newPosition, to: newPosition)
        }
        let selectedRange: UITextRange? = diveSiteBox.selectedTextRange
        diveSiteBox.offset(from: diveSiteBox.beginningOfDocument, to: (selectedRange?.start)!)
    }
    
    func formatAutocompleteResult(substring: String, possibleMatches: [String]) -> String {
        var autoCompleteResult = possibleMatches[0]
        autoCompleteResult.removeSubrange(autoCompleteResult.startIndex..<autoCompleteResult.index(autoCompleteResult.startIndex, offsetBy: substring.count))
        autoCompleteCharacterCount = autoCompleteResult.count
        return autoCompleteResult
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == diveSiteBox {
            for num in diveIndex {
                if diveSiteBox.text == csvRows[num][0] {
                    locationBox.text = csvRows[num][3]
                    countryBox.text = csvRows[num][1]
                    latBox.text = csvRows[num][4]
                    longBox.text = csvRows[num][5]
                }
            }
        }
        
        textField.textColor = .black
        textField.resignFirstResponder()
        textField.autocapitalizationType = UITextAutocapitalizationType.sentences
        autoCompleteCharacterCount = 0
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        switch textField {
            
        case diveNoBox:
            scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated:true)
            scrollViewOffset = CGPoint(x: 0, y: 0)
        case dateBox:
            scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated:true)
            scrollViewOffset = CGPoint(x: 0, y: 0)
        case diveTypeBox:
            scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated:true)
            scrollViewOffset = CGPoint(x: 0, y: 0)
        case diveSiteBox:
            scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated:true)
        case locationBox:
            scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated:true)
            scrollViewOffset = CGPoint(x: 0, y: 0)
        case countryBox:
            scrollView.setContentOffset(CGPoint(x: 0, y: 100), animated:true)
            scrollViewOffset = CGPoint(x: 0, y: 100)
        case timeInBox:
            scrollView.setContentOffset(CGPoint(x: 0, y: 320), animated:true)
            scrollViewOffset = CGPoint(x: 0, y: 320)
        case timeOutBox:
            scrollView.setContentOffset(CGPoint(x: 0, y: 320), animated:true)
            scrollViewOffset = CGPoint(x: 0, y: 320)
        case depthBox:
            scrollView.setContentOffset(CGPoint(x: 0, y: 410), animated:true)
            scrollViewOffset = CGPoint(x: 0, y: 410)
        case btmTimeBox:
            scrollView.setContentOffset(CGPoint(x: 0, y: 410), animated:true)
            scrollViewOffset = CGPoint(x: 0, y: 410)
        case latBox:
            scrollView.setContentOffset(CGPoint(x: 0, y: 230), animated:true)
            scrollViewOffset = CGPoint(x: 0, y: 230)
        case longBox:
            scrollView.setContentOffset(CGPoint(x: 0, y: 230), animated:true)
            scrollViewOffset = CGPoint(x: 0, y: 230)
        case ssDepthBox:
            scrollView.setContentOffset(CGPoint(x: 0, y: 490), animated:true)
            scrollViewOffset = CGPoint(x: 0, y: 490)
        case ssDurationBox:
            scrollViewOffset = CGPoint(x: 0, y: 490)
            scrollView.setContentOffset(CGPoint(x: 0, y: 490), animated:true)
        case surfaceIntervalBox:
            scrollViewOffset = CGPoint(x: 0, y: 560)
            scrollView.setContentOffset(CGPoint(x: 0, y: 560), animated: true)
        case divemasterBox:
            scrollView.setContentOffset(CGPoint(x: 0, y: 660), animated:true)
            scrollViewOffset = CGPoint(x: 0, y: 660)
        case divemasterNumBox:
            scrollView.setContentOffset(CGPoint(x: 0, y: 660), animated:true)
            scrollViewOffset = CGPoint(x: 0, y: 660)
        case airTempBox:
            scrollView.setContentOffset(CGPoint(x: 0, y: 750), animated:true)
            scrollViewOffset = CGPoint(x: 0, y: 750)
        case waterTempBox:
            scrollView.setContentOffset(CGPoint(x: 0, y: 750), animated:true)
            scrollViewOffset = CGPoint(x: 0, y: 750)
        case visibilityBox:
            scrollView.setContentOffset(CGPoint(x: 0, y: 830), animated:true)
            scrollViewOffset = CGPoint(x: 0, y: 830)
        case weightBox:
            scrollView.setContentOffset(CGPoint(x: 0, y: 830), animated:true)
            scrollViewOffset = CGPoint(x: 0, y: 830)
        case tpStartBox:
            scrollView.setContentOffset(CGPoint(x: 0, y: 920), animated:true)
            scrollViewOffset = CGPoint(x: 0, y: 920)
        case tpEndBox:
            scrollView.setContentOffset(CGPoint(x: 0, y: 920), animated:true)
            scrollViewOffset = CGPoint(x: 0, y: 920)
        case notesBox:
            scrollView.setContentOffset(CGPoint(x: 0, y: 1030), animated:true)
            scrollViewOffset = CGPoint(x: 0, y: 1030)
        default:
            print("Went with default")
        }
    }
    
    func readDataFromCSV(fileName:String, fileType: String)-> String!{
        guard let filepath = Bundle.main.path(forResource: fileName, ofType: fileType)
            else {
                return nil
        }
        do {
            var contents = try String(contentsOfFile: filepath, encoding: .utf8)
            
            contents = cleanRows(file: contents)
            
            return contents
        } catch {
            print("File Read Error for file \(filepath)")
            return nil
        }
    }
    
    func csv(data: String) -> [[String]] {
        var result: [[String]] = []
        let rows = data.components(separatedBy: "\n")
        for row in rows {
            let columns = row.components(separatedBy: ",")
            result.append(columns)
        }
        return result
    }
    
    func cleanRows(file:String)->String {
        var cleanFile = file
        cleanFile = cleanFile.replacingOccurrences(of: "\r", with: "\n")
        cleanFile = cleanFile.replacingOccurrences(of: "\n\n", with: "\n")
        
        return cleanFile
    }
    
    // set up diveNo PickerView
    var diveNoPickerData = Array(1...50)
    var depthPickerData = Array(1...70)
    var btmTimePickerData = Array(1...120)
    var diveNoPicker = UIPickerView()
    var depthPicker = UIPickerView()
    var btmTimePicker = UIPickerView()
    
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == diveNoPicker {
            return diveNoPickerData.count
        }
        else if pickerView == depthPicker {
            return depthPickerData.count
        }
        else if pickerView == btmTimePicker {
            return btmTimePickerData.count
        }
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == diveNoPicker {
            diveNoBox.text = String(diveNoPickerData[row])
        }
        else if pickerView == depthPicker {
            depthBox.text = String(depthPickerData[row])
        }
        else if pickerView == btmTimePicker {
            btmTimeBox.text = String(btmTimePickerData[row])
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == diveNoPicker {
            return String(diveNoPickerData[row])
        }
        else if pickerView == depthPicker {
            return String(depthPickerData[row])
        }
        else if pickerView == btmTimePicker {
            return String(btmTimePickerData[row])
        }
        return "None?"
    }
    
    // initialize Date/Time Pickers
    let timeInPicker = UIDatePicker()
    let timeOutPicker = UIDatePicker()
    let datePicker = UIDatePicker()
    
    @objc func handleDatePicker(sender: UIDatePicker) {
        var date = Date()
        
        if sender == timeInPicker {
            date = timeInPicker.date
        }
        else if sender == timeOutPicker {
            date = timeOutPicker.date
        }
        else if sender == datePicker {
            date = datePicker.date
        }
        let components = Calendar.current.dateComponents([.day, .month, .year, .hour, .minute], from: date)
        var hourInt = components.hour!
        let minInt = components.minute!
        let hour24 = components.hour!
        
        var AMPM = "AM"
        
        if hourInt > 12 {
            AMPM = "PM"
            hourInt -= 12
        }
        
        let minute = String(components.minute!)
        let day = String(components.day!)
        let month = String(components.month!)
        let year = String(components.year!)
        
        let dateString = "\(month)/\(day)/\(year)"
        let timeString = "\(hourInt):\(minute) \(AMPM)"
    
        if sender == timeInPicker {
            timeInString = timeString
            timeInHour = hour24
            timeInMin = minInt
            timeInBox.text = timeInString
            var difference = Int()
            
            if timeOutString.isEmpty == false {
                if timeOutHour > timeInHour {
                    difference = (timeOutMin + 60) - timeInMin
                }
                else {
                    difference = timeOutMin - timeInMin
                }
                
                btmTimeReal = String(difference)
                btmTimeBox.text = btmTimeReal
            }
        }
        else if sender == timeOutPicker {
            timeOutString = timeString
            timeOutHour = hour24
            timeOutMin = minInt
            timeOutBox.text = timeOutString
            var difference = Int()
            
            if timeInString.isEmpty == false {
                if timeOutHour > timeInHour {
                    difference = (timeOutMin + 60) - timeInMin
                }
                else {
                    difference = timeOutMin - timeInMin
                }
                
                btmTimeReal = String(difference)
                btmTimeBox.text = btmTimeReal
        }
        }
        else if sender == datePicker {
            dateBox.text = dateString
        }
    }
}

extension Date {
    var formatted: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return  formatter.string(from: self as Date)
    }
}


