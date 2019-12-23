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
import CoreData

class DiveListController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    // Declare global variables & objects
    let cellSpacingHeight: CGFloat = 5
    
    var coreDataManager: CoreDataManager!
    
    var dives: [NSManagedObject] = []
    
    let diveSegueIdentifier = "ShowDiveSegue"
    
    @IBAction func unwindToDiveList(unwindSegue: UIStoryboardSegue) {}
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.rowHeight = 140;
        self.tableView.allowsSelection = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Set up Core Data
        coreDataManager = CoreDataManager(modelName: "DiveModel")
        
        let managedContext = coreDataManager.managedObjectContext
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "DiveInstance")
        
        let sortDescriptor = NSSortDescriptor(key: "timeInterval", ascending: true)
        
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        do {
            let diveList = try managedContext.fetch(fetchRequest)

            for (index, dive) in diveList.enumerated() {
                
                let diveNum = String(index + 1)
                
                dive.setValue(diveNum, forKeyPath: "diveNo")
            }
            self.dives = diveList
        }
        catch let error as NSError
            { print("Couldn't fetch. \(error), \(error.userInfo)") }
        
        do
            { try managedContext.save() }
        catch let error as NSError
            { print("Could not delete. \(error), \(error.userInfo)") }
        
        // Reload Dive Data on background thread
        DispatchQueue.main.async
        { self.tableView.reloadData() }
        
        if self.dives.isEmpty
            { loadDummyData() }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {}
    
    // Set up tableview
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
        { return cellSpacingHeight }
    
    func numberOfSections(in tableView: UITableView) -> Int
        { return dives.count }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.white
        return headerView
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {}
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
        { return 1 }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell: TableViewCell = tableView.dequeueReusableCell(withIdentifier: "cellReuseIdentifier") as! TableViewCell
        
        let dive = dives[indexPath.section]
        
        let diveNoLabel = dive.value(forKeyPath: "diveNo") as? String
        let dateLabel = dive.value(forKeyPath: "date") as? String
        let diveSiteLabel = dive.value(forKeyPath: "diveSite") as? String
        let locationLabel = dive.value(forKeyPath: "location") as? String
        let countryLabel = dive.value(forKeyPath: "country") as? String
        let depthLabel = dive.value(forKeyPath: "depth") as? String
        let btmTimeLabel = dive.value(forKeyPath: "bottomTime") as? String
        
        cell.diveNoLabel.text = "No." + (diveNoLabel ?? "0")
        cell.dateLabel.text = dateLabel
        cell.diveSiteLabel.text = diveSiteLabel
        
        if (locationLabel != nil) {
        
            if locationLabel!.isEmpty == false
                { cell.locationLabel.text = (locationLabel ?? "") + "," }
            else
                { cell.locationLabel.text = (locationLabel ?? "") }
        }
        cell.countryLabel.text = countryLabel
        cell.depthLabel.text = depthLabel
        cell.btmTimeLabel.text = btmTimeLabel
        
        cell.layer.masksToBounds = true
        cell.layer.cornerRadius = 20
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let delete = UITableViewRowAction(style: .destructive, title: "Delete") { (action, indexPath) in
            
            // delete item at indexPath
            let sectionToDelete: IndexSet = [indexPath.section]
                        
            let managedContext = self.coreDataManager.managedObjectContext
            
            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "DiveInstance")
            
            let sortDescriptor = NSSortDescriptor(key: "timeInterval", ascending: true)
                    
            fetchRequest.sortDescriptors = [sortDescriptor]
            
            do {
                var test = try managedContext.fetch(fetchRequest)
                
                let diveToDelete = test[indexPath.section]
                
                test.remove(at: indexPath.section)

                managedContext.delete(diveToDelete)
                
                for (index, dive) in test.enumerated() {
                    
                    let diveNum = String(index + 1)
                    
                    dive.setValue(diveNum, forKeyPath: "diveNo")

                    }
                }
            catch let error as NSError
                { print("Could not fetch. \(error), \(error.userInfo)") }
            
            self.dives.remove(at: indexPath.section)
            
            self.tableView.deleteSections(sectionToDelete, with: .fade)
            
            self.tableView.reloadData()

            do
                { try managedContext.save() }
            catch let error as NSError
                { print("Could not delete. \(error), \(error.userInfo)") }
            
    }
        return [delete]
}
    
    func loadDummyData(){
        
        let managedContext = coreDataManager.managedObjectContext
        
        let entity = NSEntityDescription.entity(forEntityName: "DiveInstance", in: managedContext)!
        
        let dive1 = NSManagedObject(entity: entity, insertInto: managedContext)
        
        dive1.setValue("1", forKeyPath: "diveNo")
        dive1.setValue("11/2/15", forKeyPath: "date")
        dive1.setValue("Chumphon Pinnacle", forKeyPath: "diveSite")
        dive1.setValue("Koh Tao", forKeyPath: "location")
        dive1.setValue("Thailand", forKeyPath: "country")
        dive1.setValue("23 m", forKeyPath: "depth")
        dive1.setValue("45 min", forKeyPath: "bottomTime")
        dive1.setValue(10.17148333, forKeyPath: "latitude")
        dive1.setValue(99.77835, forKeyPath: "longitude")
        dive1.setValue("4:15 AM", forKeyPath: "timeIn")
        dive1.setValue("5.00 AM", forKeyPath: "timeOut")
        dive1.setValue("", forKeyPath: "diveType")
        dive1.setValue("", forKeyPath: "safetyStopDepth")
        dive1.setValue("", forKeyPath: "safetyStopDuration")
        dive1.setValue("", forKeyPath: "surfaceInterval")
        dive1.setValue("", forKeyPath: "diveMasterName")
        dive1.setValue("", forKeyPath: "diveMasterNum")
        dive1.setValue("", forKeyPath: "airTemp")
        dive1.setValue("", forKeyPath: "waterTemp")
        dive1.setValue("", forKeyPath: "visibility")
        dive1.setValue("", forKeyPath: "weight")
        dive1.setValue("", forKeyPath: "startTankPressure")
        dive1.setValue("", forKeyPath: "endTankPressure")
        dive1.setValue("", forKeyPath: "diveNotes")
        dive1.setValue(1446516480.0, forKeyPath: "timeInterval")
        
        
        let dive2 = NSManagedObject(entity: entity, insertInto: managedContext)
        
        dive2.setValue("2", forKeyPath: "diveNo")
        dive2.setValue("2/14/16", forKeyPath: "date")
        dive2.setValue("Victory Wreck", forKeyPath: "diveSite")
        dive2.setValue("West Java", forKeyPath: "location")
        dive2.setValue("Indonesia", forKeyPath: "country")
        dive2.setValue("21 m", forKeyPath: "depth")
        dive2.setValue("52 min", forKeyPath: "bottomTime")
        dive2.setValue(-5.972547505, forKeyPath: "latitude")
        dive2.setValue(105.8627155, forKeyPath: "longitude")
        dive2.setValue("8:10 AM", forKeyPath: "timeIn")
        dive2.setValue("9:02 AM", forKeyPath: "timeOut")
        dive2.setValue("", forKeyPath: "diveType")
        dive2.setValue("", forKeyPath: "safetyStopDepth")
        dive2.setValue("", forKeyPath: "safetyStopDuration")
        dive2.setValue("", forKeyPath: "surfaceInterval")
        dive2.setValue("", forKeyPath: "diveMasterName")
        dive2.setValue("", forKeyPath: "diveMasterNum")
        dive2.setValue("", forKeyPath: "airTemp")
        dive2.setValue("", forKeyPath: "waterTemp")
        dive2.setValue("", forKeyPath: "visibility")
        dive2.setValue("", forKeyPath: "weight")
        dive2.setValue("", forKeyPath: "startTankPressure")
        dive2.setValue("", forKeyPath: "endTankPressure")
        dive2.setValue("", forKeyPath: "diveNotes")
        dive2.setValue(1455502770.0, forKeyPath: "timeInterval")
        
        
        let dive3 = NSManagedObject(entity: entity, insertInto: managedContext)
        
        dive3.setValue("3", forKeyPath: "diveNo")
        dive3.setValue("4/7/17", forKeyPath: "date")
        dive3.setValue("Oluhuta", forKeyPath: "diveSite")
        dive3.setValue("Gorontalo", forKeyPath: "location")
        dive3.setValue("Indonesia", forKeyPath: "country")
        dive3.setValue("15 m", forKeyPath: "depth")
        dive3.setValue("58 min", forKeyPath: "bottomTime")
        dive3.setValue(0.419622485, forKeyPath: "latitude")
        dive3.setValue(123.1446362, forKeyPath: "longitude")
        dive3.setValue("8:30 AM", forKeyPath: "timeIn")
        dive3.setValue("9:28 AM", forKeyPath: "timeOut")
        dive3.setValue("", forKeyPath: "diveType")
        dive3.setValue("", forKeyPath: "safetyStopDepth")
        dive3.setValue("", forKeyPath: "safetyStopDuration")
        dive3.setValue("", forKeyPath: "surfaceInterval")
        dive3.setValue("", forKeyPath: "diveMasterName")
        dive3.setValue("", forKeyPath: "diveMasterNum")
        dive3.setValue("", forKeyPath: "airTemp")
        dive3.setValue("", forKeyPath: "waterTemp")
        dive3.setValue("", forKeyPath: "visibility")
        dive3.setValue("", forKeyPath: "weight")
        dive3.setValue("", forKeyPath: "startTankPressure")
        dive3.setValue("", forKeyPath: "endTankPressure")
        dive3.setValue("", forKeyPath: "diveNotes")
        dive3.setValue(1491614781.0, forKeyPath: "timeInterval")
    
        
        let dive4 = NSManagedObject(entity: entity, insertInto: managedContext)
        
        dive4.setValue("4", forKeyPath: "diveNo")
        dive4.setValue("12/22/17", forKeyPath: "date")
        dive4.setValue("Lighthouse Pinnacle", forKeyPath: "diveSite")
        dive4.setValue("Koh Tao", forKeyPath: "location")
        dive4.setValue("Thailand", forKeyPath: "country")
        dive4.setValue("20 m", forKeyPath: "depth")
        dive4.setValue("42 min", forKeyPath: "bottomTime")
        dive4.setValue(10.12089317, forKeyPath: "latitude")
        dive4.setValue(99.84523207, forKeyPath: "longitude")
        dive4.setValue("10:30 AM", forKeyPath: "timeIn")
        dive4.setValue("11:12 AM", forKeyPath: "timeOut")
        dive4.setValue("", forKeyPath: "diveType")
        dive4.setValue("", forKeyPath: "safetyStopDepth")
        dive4.setValue("", forKeyPath: "safetyStopDuration")
        dive4.setValue("", forKeyPath: "surfaceInterval")
        dive4.setValue("", forKeyPath: "diveMasterName")
        dive4.setValue("", forKeyPath: "diveMasterNum")
        dive4.setValue("", forKeyPath: "airTemp")
        dive4.setValue("", forKeyPath: "waterTemp")
        dive4.setValue("", forKeyPath: "visibility")
        dive4.setValue("", forKeyPath: "weight")
        dive4.setValue("", forKeyPath: "startTankPressure")
        dive4.setValue("", forKeyPath: "endTankPressure")
        dive4.setValue("", forKeyPath: "diveNotes")
        dive4.setValue(1513998074.0, forKeyPath: "timeInterval")
        
        
        let dive5 = NSManagedObject(entity: entity, insertInto: managedContext)
        
        dive5.setValue("5", forKeyPath: "diveNo")
        dive5.setValue("3/12/18", forKeyPath: "date")
        dive5.setValue("Intan Wreck", forKeyPath: "diveSite")
        dive5.setValue("Karimunjawa National Park", forKeyPath: "location")
        dive5.setValue("Indonesia", forKeyPath: "country")
        dive5.setValue("31 m", forKeyPath: "depth")
        dive5.setValue("39 min", forKeyPath: "bottomTime")
        dive5.setValue(-4.406666667, forKeyPath: "latitude")
        dive5.setValue(106.6833333, forKeyPath: "longitude")
        dive5.setValue("7:30 AM", forKeyPath: "timeIn")
        dive5.setValue("8:09 AM", forKeyPath: "timeOut")
        dive5.setValue("", forKeyPath: "diveType")
        dive5.setValue("", forKeyPath: "safetyStopDepth")
        dive5.setValue("", forKeyPath: "safetyStopDuration")
        dive5.setValue("", forKeyPath: "surfaceInterval")
        dive5.setValue("", forKeyPath: "diveMasterName")
        dive5.setValue("", forKeyPath: "diveMasterNum")
        dive5.setValue("", forKeyPath: "airTemp")
        dive5.setValue("", forKeyPath: "waterTemp")
        dive5.setValue("", forKeyPath: "visibility")
        dive5.setValue("", forKeyPath: "weight")
        dive5.setValue("", forKeyPath: "startTankPressure")
        dive5.setValue("", forKeyPath: "endTankPressure")
        dive5.setValue("", forKeyPath: "diveNotes")
        dive5.setValue(1520905153.0, forKeyPath: "timeInterval")
        
        do {
            try managedContext.save()
            dives.append(dive1)
            dives.append(dive2)
            dives.append(dive3)
            dives.append(dive4)
            dives.append(dive5)
           }
        catch let error as NSError
            { print("Could not save. \(error), \(error.userInfo)") }
    }
}

extension UITextField {
    var unwrappedText: String
        { return self.text ?? "" }
}
