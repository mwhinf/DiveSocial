//
//  DiveListController.swift
//  DiveLog
//
//  Created by Michael Whinfrey on 6/7/18.
//  Copyright © 2018 Michael Whinfrey. All rights reserved.
//

import UIKit
import GoogleMaps
import CloudKit

class DiveListController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    // Declare global variables & objects
    let cellSpacingHeight: CGFloat = 5
    var divesList: [Dive] = []
    var dives: [Dive] = []
    let diveSegueIdentifier = "ShowDiveSegue"
    let diveInstance = Dive(diveNo: "", date: "", diveSite: "", location: "", country: "", depth: "", bottomTime: "", latitude: 0, longitude: 0, diveType: "", timeIn: "", timeOut: "", surfaceInterval: "", safetyStopDepth: "", safetyStopDuration: "", diveMasterName: "", diveMasterNum: "", diveNotes: "", airTemp: "", waterTemp: "", visibility: "", weight: "", startTankPressure: "", endTankPressure: "")
    
    @IBAction func unwindToDiveList(unwindSegue: UIStoryboardSegue) {
        
    }
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.rowHeight = 140;
        self.tableView.allowsSelection = false
        
        if dives.isEmpty == true {
            //initialData()
            
            fetchDives()
            print(dives.count)
            //dives = diveInstance.loadFromFile()
            print(dives.count)
        }
    }
    
    private func fetchDives() {
        
        let privateDatabase = CKContainer.default().privateCloudDatabase
        
        let query = CKQuery(recordType: "Dive", predicate: NSPredicate(value: true))
        
        query.sortDescriptors = [NSSortDescriptor(key: "DiveSite", ascending: true)]
        
        privateDatabase.perform(query, inZoneWith: nil) { (records, error) in
            records?.forEach({ (record) in
                
                guard error == nil else{
                    print("There is an error!")
                    print(error?.localizedDescription as Any)
                    return
                }
                
                let diveNo = record.value(forKey: "DiveNo") as! String
                let diveSite = record.value(forKey: "DiveSite") as! String
                let date = record.value(forKey: "Date") as! String
                let location = record.value(forKey: "Location") as! String
                let country = record.value(forKey: "Country") as! String
                let depth = record.value(forKey: "Depth") as! String
                let bottomTime = record.value(forKey: "BottomTime") as! String
                let latitude = record.value(forKey: "Latitude") as! Double
                let longitude = record.value(forKey: "Longitude") as! Double
                let diveType = record.value(forKey: "DiveType") as! String?
                let timeIn = record.value(forKey: "TimeIn") as! String?
                let timeOut = record.value(forKey: "TimeOut") as! String?
                let surfaceInterval = record.value(forKey: "SurfaceInterval") as! String?
                let safetyStopDepth = record.value(forKey: "SafetyStopDepth") as! String?
                let safetyStopDuration = record.value(forKey: "SafetyStopDuration") as! String?
                let diveMasterName = record.value(forKey: "DiveMasterName") as! String?
                let diveMasterNum = record.value(forKey: "DiveMasterNum") as! String?
                let diveNotes = record.value(forKey: "DiveNotes") as! String?
                let airTemp = record.value(forKey: "AirTemp") as! String?
                let waterTemp = record.value(forKey: "WaterTemp") as! String?
                let visibility = record.value(forKey: "Visibility") as! String?
                let weight = record.value(forKey: "Weight") as! String?
                let startTankPressure = record.value(forKey: "StartTankPressure") as! String?
                let endTankPressure = record.value(forKey: "EndTankPressure") as! String?
                
                let diveInstance = Dive(diveNo: diveNo, date: date, diveSite: diveSite, location: location, country: country, depth: depth, bottomTime: bottomTime, latitude: latitude, longitude: longitude, diveType: diveType, timeIn: timeIn, timeOut: timeOut, surfaceInterval: surfaceInterval, safetyStopDepth: safetyStopDepth, safetyStopDuration: safetyStopDuration, diveMasterName: diveMasterName, diveMasterNum: diveMasterNum, diveNotes: diveNotes, airTemp: airTemp, waterTemp: waterTemp, visibility: visibility, weight: weight, startTankPressure: startTankPressure, endTankPressure: endTankPressure)
                
                self.divesList.append(diveInstance)
                
                diveInstance.saveToFile(dives: self.divesList)
                self.dives = diveInstance.loadFromFile()
                self.dives.sort() { $0.diveNo > $1.diveNo}
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            })
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        dives.sort() { $0.diveNo > $1.diveNo}
        
        DispatchQueue.main.async {
         self.tableView.reloadData()
         }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.destination is addDiveController
        {
            let vc = segue.destination as? addDiveController
            vc?.dives = dives
            vc?.divesList = divesList
        }
        else if segue.destination is mapViewController
        {
            let vc = segue.destination as? mapViewController
            vc?.dives = dives
            vc?.divesList = divesList
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        var diveType: String? = nil
        var timeIn: String? = nil
        var timeOut: String? = nil
        var surfaceInterval: String? = nil
        var safetyStopDepth: String? = nil
        var safetyStopDuration: String? = nil
        var diveMasterName: String? = nil
        var diveMasterNum: String? = nil
        var diveNotes: String? = nil
        var airTemp: String? = nil
        var waterTemp: String? = nil
        var visibility: String? = nil
        var weight: String? = nil
        var startTankPressure: String? = nil
        var endTankPressure: String? = nil
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
                //print(decodedDives)
                temp = decodedDives
            }
            return temp
        }
    }

    func initialData() {
        
        print("INITIAL DATA CALLED")
        
        // Add initial dive data
        let dive1 = Dive(diveNo: "1", date: "12/26/13", diveSite: "Jardines", location: "Playa del Carmen", country: "Mexico", depth: "15m", bottomTime: "56 min", latitude: 20.624050, longitude: -87.018933, diveType: "", timeIn: "", timeOut: "", surfaceInterval: "", safetyStopDepth: "", safetyStopDuration: "", diveMasterName: "", diveMasterNum: "", diveNotes: "", airTemp: "", waterTemp: "", visibility: "", weight: "", startTankPressure: "", endTankPressure: "")

        let dive2 = Dive(diveNo: "2", date: "12/26/13", diveSite: "Moc-Che Shallow", location: "Playa del Carmen", country: "Mexico", depth: "15m", bottomTime: "46 min", latitude: 20.689317, longitude: -86.931383, diveType: "", timeIn: "", timeOut: "", surfaceInterval: "", safetyStopDepth: "", safetyStopDuration: "", diveMasterName: "", diveMasterNum: "", diveNotes: "", airTemp: "", waterTemp: "", visibility: "", weight: "", startTankPressure: "", endTankPressure: "")

        let dive3 = Dive(diveNo: "3", date: "6/4/17", diveSite: "Twins", location: "Koh Tao", country: "Thailand", depth: "15.6m", bottomTime: "40 min", latitude: 10.116782, longitude: 99.813431, diveType: "", timeIn: "", timeOut: "", surfaceInterval: "", safetyStopDepth: "", safetyStopDuration: "", diveMasterName: "", diveMasterNum: "", diveNotes: "", airTemp: "", waterTemp: "", visibility: "", weight: "", startTankPressure: "", endTankPressure: "")

        let dive4 = Dive(diveNo: "4", date: "6/5/17", diveSite: "Chumphon Pinnacle", location: "Koh Tao", country: "Thailand", depth: "30.1m", bottomTime: "29 min", latitude: 10.171483, longitude: 99.778350, diveType: "", timeIn: "", timeOut: "", surfaceInterval: "", safetyStopDepth: "", safetyStopDuration: "", diveMasterName: "", diveMasterNum: "", diveNotes: "", airTemp: "", waterTemp: "", visibility: "", weight: "", startTankPressure: "", endTankPressure: "")

        let dive5 = Dive(diveNo: "5", date: "7/27/17", diveSite: "Sental Point", location: "Nusa Penida", country: "Indonesia", depth: "25m", bottomTime: "36 min", latitude: -8.675817, longitude: 115.524417, diveType: "", timeIn: "", timeOut: "", surfaceInterval: "", safetyStopDepth: "", safetyStopDuration: "", diveMasterName: "", diveMasterNum: "", diveNotes: "", airTemp: "", waterTemp: "", visibility: "", weight: "", startTankPressure: "", endTankPressure: "")

        let dive6 = Dive(diveNo: "6", date: "7/28/17", diveSite: "Pura Ped", location: "Nusa Penida", country: "Indonesia", depth: "25.3m", bottomTime: "50 min", latitude: -8.671667, longitude: 115.503900, diveType: "", timeIn: "", timeOut: "", surfaceInterval: "", safetyStopDepth: "", safetyStopDuration: "", diveMasterName: "", diveMasterNum: "", diveNotes: "", airTemp: "", waterTemp: "", visibility: "", weight: "", startTankPressure: "", endTankPressure: "")

        divesList.append(dive1)
        divesList.append(dive2)
        divesList.append(dive3)
        divesList.append(dive4)
        divesList.append(dive5)
        divesList.append(dive6)
        
        dive1.saveToFile(dives: divesList)
    }
    
    
    // Set up tableview
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return cellSpacingHeight
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return dives.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.white
        return headerView
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell: TableViewCell = tableView.dequeueReusableCell(withIdentifier: "cellReuseIdentifier") as! TableViewCell
        
        cell.diveNoLabel.text = "Dive No." + dives[indexPath.section].diveNo
        cell.dateLabel.text = dives[indexPath.section].date
        cell.diveSiteLabel.text = dives[indexPath.section].diveSite
        
        if dives[indexPath.section].location.isEmpty == false {
            cell.locationLabel.text = dives[indexPath.section].location + ","
        }
        else {
            cell.locationLabel.text = dives[indexPath.section].location
        }
        cell.countryLabel.text = dives[indexPath.section].country
        cell.depthLabel.text = dives[indexPath.section].depth
        cell.btmTimeLabel.text = dives[indexPath.section].bottomTime
        
        
        cell.layer.masksToBounds = true
        cell.layer.cornerRadius = 20
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let delete = UITableViewRowAction(style: .destructive, title: "Delete") { (action, indexPath) in
            // delete item at indexPath
            
            let sectionToDelete: IndexSet = [indexPath.section]
            
            let numba = self.dives.count - indexPath.section - 1
            
            print("DIVES THEN DIVESLIST")
            print(self.dives.count)
            print(self.divesList.count)
            
            self.dives.remove(at: indexPath.section)
            self.divesList.remove(at: numba)
            
            tableView.deleteSections(sectionToDelete, with: .fade)
            
        let privateDatabase = CKContainer.default().privateCloudDatabase
        
        let math = self.dives.count + 1 - indexPath.section
        
        let diveNoForSearch = String(math)
        
        let divePredicate = NSPredicate(format: "DiveNo == %@", diveNoForSearch)
            
        let query = CKQuery(recordType: "Dive", predicate: divePredicate)
        
        privateDatabase.perform(query, inZoneWith: nil) { (records, error) in
                records?.forEach({ (record) in
                    
                guard error == nil else{
                    print("There is an error!")
                    print(error?.localizedDescription as Any)
                    return
                }
            
              let site = record.value(forKey: "DiveSite") as! String
              let recordID = record.recordID
              print(site)
                    
                    privateDatabase.delete(withRecordID: recordID, completionHandler: { (recordID, error) -> Void in
                        guard recordID != nil else {
                            print("Error")
                            return
                        }
                        print("Successfully deleted record")
                    }
            )
            })
        }
        }
        
        return [delete]
    }
}

extension UITextField {
    var unwrappedText: String {
        return self.text ?? ""
    }
}
