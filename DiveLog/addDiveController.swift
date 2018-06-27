//
//  addDiveController.swift
//  DiveLog
//
//  Created by Michael Whinfrey on 6/7/18.
//  Copyright © 2018 Michael Whinfrey. All rights reserved.
//

import UIKit

class addDiveController: UIViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {

    let diveInstanceB = DiveListController.Dive(diveNo: "", date: "", diveSite: "", location: "", country: "", depth: "", bottomTime: "", latitude: 0, longitude: 0)
    
    var divesList: [DiveListController.Dive] = []
    var dives: [DiveListController.Dive] = []
    
    var lat = ""
    var long = ""
    var timeInString = ""
    var timeOutString = ""
    var btmTimeReal = ""
    var timeInHour = Int()
    var timeInMin = Int()
    var timeOutHour = Int()
    var timeOutMin = Int()
    let autoCompleteSuggestions: [String] = ["United States", "Mexico", "Thailand", "Indonesia"]
    var autoCompleteCharacterCount = 0
    var timer = Timer()
    
    
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
    @IBAction func saveButtonTapped(_ sender: Any) {
        
        let diveNoText = diveNoBox.unwrappedText
        let dateText = dateBox.unwrappedText
        let diveSiteText = diveSiteBox.unwrappedText
        let locationText = locationBox.unwrappedText
        let countryText = countryBox.unwrappedText
        let depthText = depthBox.unwrappedText
        let btmTimeText = btmTimeBox.unwrappedText
        let latText = latBox.unwrappedText
        let longText = longBox.unwrappedText
        var latDouble = Double(latText)
        var longDouble = Double(longText)
        
        if latText.isEmpty == true {
            latDouble = -12.712
            longDouble = 90.402
        }
        
        let diveTemp = DiveListController.Dive(diveNo: diveNoText, date: dateText, diveSite: diveSiteText, location: locationText, country: countryText, depth: depthText, bottomTime: btmTimeText, latitude: latDouble!, longitude: longDouble!)
        
        divesList.append(diveTemp)
        diveInstanceB.saveToFile(dives: divesList)
        dives = diveInstanceB.loadFromFile()
        print("Saved!!!")
        print(dives.count)
        
        performSegue(withIdentifier: "unwindToDiveList", sender: Any?.self)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool { //1
        var subString = (textField.text!.capitalized as NSString).replacingCharacters(in: range, with: string) // 2
        subString = formatSubstring(subString: subString)
        
        if subString.count == 0 { // 3 when a user clears the textField
            resetValues()
        } else {
            searchAutocompleteEntriesWIthSubstring(substring: subString) //4
        
        }
        return true
    }
    
    func formatSubstring(subString: String) -> String {
        let formatted = String(subString.dropLast(autoCompleteCharacterCount)).lowercased().capitalized //5
        return formatted
    }
    
    func resetValues() {
        autoCompleteCharacterCount = 0
        countryBox.text = ""
    }
    
    func searchAutocompleteEntriesWIthSubstring(substring: String) {
        let userQuery = substring
        let autoCompleteSuggestions = getAutocompleteSuggestions(userText: substring) //1
        
        if autoCompleteSuggestions.count > 0 {
            timer = .scheduledTimer(withTimeInterval: 0.01, repeats: false, block: { (timer) in //2
                let autocompleteResult = self.formatAutocompleteResult(substring: substring, possibleMatches: autoCompleteSuggestions) // 3
                self.putColourFormattedTextInTextField(autocompleteResult: autocompleteResult, userQuery : userQuery) //4
                self.moveCaretToEndOfUserQueryPosition(userQuery: userQuery) //5
            })
        } else {
            timer = .scheduledTimer(withTimeInterval: 0.01, repeats: false, block: { (timer) in //7
                self.countryBox.text = substring
            })
            autoCompleteCharacterCount = 0
        }
    }
    
    func getAutocompleteSuggestions(userText: String) -> [String]{
        var possibleMatches: [String] = []
        for item in autoCompleteSuggestions { //2
            let myString:NSString! = item as NSString
            let substringRange :NSRange! = myString.range(of: userText)
            
            if (substringRange.location == 0)
            {
                possibleMatches.append(item)
            }
        }
        return possibleMatches
    }
    
    func putColourFormattedTextInTextField(autocompleteResult: String, userQuery : String) {
        let colouredString: NSMutableAttributedString = NSMutableAttributedString(string: userQuery + autocompleteResult)
        colouredString.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor.gray, range: NSRange(location: userQuery.count,length:autocompleteResult.count))
        self.countryBox.attributedText = colouredString
    }
    
    func moveCaretToEndOfUserQueryPosition(userQuery : String) {
        if let newPosition = self.countryBox.position(from: self.countryBox.beginningOfDocument, offset: userQuery.count) {
            self.countryBox.selectedTextRange = self.countryBox.textRange(from: newPosition, to: newPosition)
        }
        let selectedRange: UITextRange? = countryBox.selectedTextRange
        countryBox.offset(from: countryBox.beginningOfDocument, to: (selectedRange?.start)!)
    }
    
    func formatAutocompleteResult(substring: String, possibleMatches: [String]) -> String {
        var autoCompleteResult = possibleMatches[0]
        autoCompleteResult.removeSubrange(autoCompleteResult.startIndex..<autoCompleteResult.index(autoCompleteResult.startIndex, offsetBy: substring.count))
        autoCompleteCharacterCount = autoCompleteResult.count
        return autoCompleteResult
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        print("WEEEEEE")
        textField.textColor = .black
        textField.resignFirstResponder()
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        countryBox.autocorrectionType = .no
        countryBox.autocapitalizationType = .none
        
        // Hide keyboard upon screen tap
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        // set initial dateBox text to current date
        let date = Date()
        let calendar = Calendar.current
        let day = calendar.component(.day, from: date)
        let month = calendar.component(.month, from: date)
        let year = calendar.component(.year, from: date)
        let dayString = String(day)
        let monthString = String(month)
        let yearString = String(year)
        dateBox.text = "\(monthString)/\(dayString)/\(yearString)"
        
        // set up Dive Number textfield
        diveNoPicker.delegate = self
        diveNoPicker.dataSource = self
        diveNoBox.inputView = diveNoPicker
        diveNoBox.text = String(dives.count + 1)
        
        // set up Depth textfield
        depthPicker.delegate = self
        depthPicker.dataSource = self
        depthBox.inputView = depthPicker
        
        // set up Bottom Time textfield
        btmTimePicker.delegate = self
        btmTimePicker.dataSource = self
        btmTimeBox.inputView = btmTimePicker
        
        // set up Time In textfield
        timeInPicker.datePickerMode = .time
        timeInPicker.addTarget(self, action: #selector(handleDatePicker(sender:)), for: UIControlEvents.valueChanged)
        timeInBox.inputView = timeInPicker
        
        // set up Time Out textfield
        timeOutPicker.datePickerMode = .time
        timeOutPicker.addTarget(self, action: #selector(handleDatePicker(sender:)), for: UIControlEvents.valueChanged)
        timeOutBox.inputView = timeOutPicker
        
        // set up Date textfield
        datePicker.datePickerMode = .date
        datePicker.addTarget(self, action: #selector(handleDatePicker(sender:)), for: UIControlEvents.valueChanged)
        dateBox.inputView = datePicker
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if timeInString.isEmpty && timeOutString.isEmpty == false {
            btmTimeBox.text = btmTimeReal
        }
        
        //var data = readDataFromFile(file: "Thailand_DiveSite_GPS")
        //print(data)
        
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
            vc?.divesList = divesList
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
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
    
   /*func readDataFromFile(file:String)-> String!{
    
         guard let filepath = Bundle.main.path(forResource: "Thailand_DiveSite_GPS", ofType: "txt")
            else {
                return nil
        }
        do {
            //let content = NSString.stringWithContentsOfFile(filepath) as! String
            let contents = try String(contentsOfFile: filepath, encoding: nil)
            return contents
        }
        catch {
            print("File Read Error for file \(filePath)")
            return nil
        }
    }*/
    
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


