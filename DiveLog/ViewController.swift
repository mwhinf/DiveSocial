//
//  ViewController.swift
//  DiveLog
//
//  Created by Michael Whinfrey on 5/22/18.
//  Copyright © 2018 Michael Whinfrey. All rights reserved.
//

import UIKit
import GoogleMaps


class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    // Declare global variables & objects
    let cellSpacingHeight: CGFloat = 5
    var divesList: [Dive] = []
    var dives: [Dive] = []
    let diveSegueIdentifier = "ShowDiveSegue"
    let diveInstance = Dive(diveNo: "", date: "", diveSite: "", location: "", country: "", depth: "", bottomTime: "", latitude: 0, longitude: 0)
    
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
    
    
    @IBAction func unwindToTabs(unwindSegue: UIStoryboardSegue) {
        //self.tableView.reloadData()
    }
    @IBOutlet weak var loginView: UIView!
    @IBOutlet weak var userTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initialData()
        dives = diveInstance.loadFromFile()
        
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedStringKey.foregroundColor : UIColor.white]
        UIBarButtonItem.appearance(whenContainedInInstancesOf: [UINavigationBar.classForCoder() as! UIAppearanceContainer.Type]).setTitleTextAttributes([NSAttributedStringKey.foregroundColor: UIColor.white], for: .normal)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.destination is addDiveController
        {
            let vc = segue.destination as? addDiveController
            vc?.dives = dives
            vc?.divesList = divesList
        }
        
    }
    
    
    func initialData() {
        
        // Add initial dive data
        let dive1 = Dive(diveNo: "1", date: "12/26/13", diveSite: "Jardines", location: "Playa del Carmen", country: "Mexico", depth: "15m", bottomTime: "56 min", latitude: 20.624050, longitude: -87.018933)
        
        let dive2 = Dive(diveNo: "2", date: "12/26/13", diveSite: "Moc-Che Shallow", location: "Playa del Carmen", country: "Mexico", depth: "15m", bottomTime: "46 min", latitude: 20.689317, longitude: -86.931383)
        
        let dive3 = Dive(diveNo: "3", date: "6/4/17", diveSite: "Twins", location: "Koh Tao", country: "Thailand", depth: "15.6m", bottomTime: "40 min", latitude: 10.116782, longitude: 99.813431)
        
        let dive4 = Dive(diveNo: "4", date: "6/5/17", diveSite: "Chumphon Pinnacle", location: "Koh Tao", country: "Thailand", depth: "30.1m", bottomTime: "29 min", latitude: 10.171483, longitude: 99.778350)
        
        let dive5 = Dive(diveNo: "5", date: "7/27/17", diveSite: "Sental Point", location: "Nusa Penida", country: "Indonesia", depth: "25m", bottomTime: "36 min", latitude: -8.675817, longitude: 115.524417)
        
        let dive6 = Dive(diveNo: "6", date: "7/28/17", diveSite: "Pura Ped", location: "Nusa Penida", country: "Indonesia", depth: "25.3m", bottomTime: "50 min", latitude: -8.671667, longitude: 115.503900)
        
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
        cell.locationLabel.text = dives[indexPath.section].location + ","
        cell.countryLabel.text = dives[indexPath.section].country
        cell.depthLabel.text = dives[indexPath.section].depth
        cell.btmTimeLabel.text = dives[indexPath.section].bottomTime
        
        
        cell.layer.masksToBounds = true
        cell.layer.cornerRadius = 20
        
        return cell
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

extension UITextField {
    var unwrappedText: String {
        return self.text ?? ""
    }
}
