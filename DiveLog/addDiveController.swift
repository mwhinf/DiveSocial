//
//  addDiveController.swift
//  DiveLog
//
//  Created by Michael Whinfrey on 6/7/18.
//  Copyright © 2018 Michael Whinfrey. All rights reserved.
//

import UIKit

class addDiveController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    let diveInstanceB = ViewController.Dive(diveNo: "", date: "", diveSite: "", location: "", country: "", depth: "", bottomTime: "", latitude: 0, longitude: 0)
    
    var divesList: [ViewController.Dive] = []
    var dives: [ViewController.Dive] = []
    
    var lat = ""
    var long = ""
    var timeInString = ""
    var timeOutString = ""
    var btmTimeReal = ""
    var timeInHour = Int()
    var timeInMin = Int()
    var timeOutHour = Int()
    var timeOutMin = Int()
    
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
        
        let diveTemp = ViewController.Dive(diveNo: diveNoText, date: dateText, diveSite: diveSiteText, location: locationText, country: countryText, depth: depthText, bottomTime: btmTimeText, latitude: 12.72, longitude: -91.799)
        
        divesList.append(diveTemp)
        diveInstanceB.saveToFile(dives: divesList)
        dives = diveInstanceB.loadFromFile()
        print("Saved!!!")
        print(dives.count)
        
        performSegue(withIdentifier: "unwindToTabs", sender: Any?.self)
    }
    
    
        // Create model object
        struct Dive: Codable {
            let diveNo: String
            let date: String
            let diveSite: String
            let location: String
            let country: String
            let depth: String
            let bottomTime: String
            let latitude: Double
            let longitude: Double
            let diveType: String? = nil
            let timeIn: String? = nil
            let timeOut: String? = nil
            let surfaceInterval: String? = nil
            let safetyStopDepth: Double? = nil
            let safetyStopDuration: Double? = nil
            let divemasterName: String? = nil
            let divemasterNum: Int? = nil
            let diveNotes: String? = nil
            let airTemp: Double? = nil
            let waterTemp: Double? = nil
            let weight: Double? = nil
            let startTankPressure: Double? = nil
            let endTankPressure: Double? = nil
            let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            
            func saveToFile(dives: Array<Dive>) {
                let archiveURL = documentsDirectory.appendingPathComponent("diveList").appendingPathExtension("plist")
                let propertyListEncoder = PropertyListEncoder()
                let encodedDives = try? propertyListEncoder.encode(dives)
                try? encodedDives?.write(to: archiveURL, options: .noFileProtection)
            }
            
            func loadFromFile() -> Array<Dive> {
                
                let propertyListDecoder = PropertyListDecoder()
                var temp: Array<Dive> = []
                let archiveURL = documentsDirectory.appendingPathComponent("diveList").appendingPathExtension("plist")
                if let retrievedDivesData = try? Data(contentsOf: archiveURL),
                    let decodedDives = try? propertyListDecoder.decode(Array<Dive>.self, from: retrievedDivesData) {
                    print(decodedDives)
                    temp = decodedDives
                }
                return temp
            }
        }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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


