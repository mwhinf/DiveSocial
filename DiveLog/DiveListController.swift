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
    
    @IBAction func unwindToDiveList(unwindSegue: UIStoryboardSegue) {
    }
    
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
        
        let fetchRequest =
            NSFetchRequest<NSManagedObject>(entityName: "DiveInstance")
        
        do {
            dives = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        // Reload Dive Data on background thread
        DispatchQueue.main.async {
         self.tableView.reloadData()
         }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.destination is AddDiveController
        {
            let vc = segue.destination as? AddDiveController
            vc?.dives = dives
        }
        else if segue.destination is mapViewController
        {
            let vc = segue.destination as? mapViewController
            vc?.dives = dives
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        
        let dive = dives[indexPath.section]
        
        let diveNoLabel = dive.value(forKeyPath: "diveNo") as? String
        let dateLabel = dive.value(forKeyPath: "date") as? String
        let diveSiteLabel = dive.value(forKeyPath: "diveSite") as? String
        let locationLabel = dive.value(forKeyPath: "location") as? String
        let countryLabel = dive.value(forKeyPath: "country") as? String
        let depthLabel = dive.value(forKeyPath: "depth") as? String
        let btmTimeLabel = dive.value(forKeyPath: "bottomTime") as? String
        
        
        cell.diveNoLabel.text = "Dive No." + diveNoLabel!
        cell.dateLabel.text = dateLabel
        cell.diveSiteLabel.text = diveSiteLabel
        
        if locationLabel!.isEmpty == false {
            cell.locationLabel.text = locationLabel! + ","
        }
        else {
            cell.locationLabel.text = locationLabel!
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
            
            self.coreDataManager = CoreDataManager(modelName: "DiveModel")
            
            let managedContext = self.coreDataManager.managedObjectContext
            
            let fetchRequest =
                NSFetchRequest<NSManagedObject>(entityName: "DiveInstance")
            
            do {
                let test = try managedContext.fetch(fetchRequest)
                
                let diveToDelete = test[indexPath.section]
                managedContext.delete(diveToDelete)
                
            } catch let error as NSError {
                print("Could not fetch. \(error), \(error.userInfo)")
            }
            
            self.dives.remove(at: indexPath.section)
            
            tableView.deleteSections(sectionToDelete, with: .fade)
            
            do {
                try managedContext.save()
    
            } catch let error as NSError {
                print("Could not delete. \(error), \(error.userInfo)")
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
