//
//  mapViewController.swift
//  DiveLog
//
//  Created by Michael Whinfrey on 5/30/18.
//  Copyright © 2018 Michael Whinfrey. All rights reserved.
//

import UIKit
import GoogleMaps


class mapViewController: UIViewController {

    var dives: [Dive] = []
    
    @IBAction func unwindToMap(unwindSegue: UIStoryboardSegue) {
        
    }
    
    
    @IBAction func longPress(_ sender: UILongPressGestureRecognizer) {
        let camera = GMSCameraPosition.camera(withLatitude: 20.189, longitude: 89.702, zoom: 2.0)
        
        mapView.camera = camera
    }
    
    @IBOutlet fileprivate weak var mapView: GMSMapView!
    
    
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
        
        let dive1 = Dive(diveNo: "Dive No.1", date: "12/26/13", diveSite: "Jardines", location: "Playa del Carmen", country: "Mexico", depth: "15m", bottomTime: "56 min", latitude: 20.624050, longitude: -87.018933)
        
        let dive2 = Dive(diveNo: "Dive No.2", date: "12/26/13", diveSite: "Moc-Che Shallow", location: "Playa del Carmen", country: "Mexico", depth: "15m", bottomTime: "46 min", latitude: 20.689317, longitude: -86.931383)
        
        let dive3 = Dive(diveNo: "Dive No.3", date: "6/4/17", diveSite: "Twins", location: "Koh Tao", country: "Thailand", depth: "15.6m", bottomTime: "40 min", latitude: 10.116782, longitude: 99.813431)
        
        let dive4 = Dive(diveNo: "Dive No.4", date: "6/5/17", diveSite: "Chumphon Pinnacle", location: "Koh Tao", country: "Thailand", depth: "30.1m", bottomTime: "29 min", latitude: 10.171483, longitude: 99.778350)
        
        let dive5 = Dive(diveNo: "Dive No.5", date: "7/27/17", diveSite: "Sental Point", location: "Nusa Penida", country: "Indonesia", depth: "25m", bottomTime: "36 min", latitude: -8.675817, longitude: 115.524417)
        
        let dive6 = Dive(diveNo: "Dive No.6", date: "7/28/17", diveSite: "Pura Ped", location: "Nusa Penida", country: "Indonesia", depth: "25.3m", bottomTime: "50 min", latitude: -8.671667, longitude: 115.503900)
        
        dives.append(dive1)
        dives.append(dive2)
        dives.append(dive3)
        dives.append(dive4)
        dives.append(dive5)
        dives.append(dive6)
        
        let camera = GMSCameraPosition.camera(withLatitude: dive1.latitude, longitude: dive1.longitude, zoom: 2.0)
        
        mapView.camera = camera
        mapView.delegate = self
        mapView.mapType = GMSMapViewType.hybrid
        mapView.settings.consumesGesturesInView = false
        
        //showMarker()
    }
    
    func showMarker(){
        var counter = 0
        for dive in dives {
            let marker = GMSMarker()
            //marker.position = position
            marker.position = CLLocationCoordinate2D(latitude: dive.latitude, longitude: dive.longitude)
            marker.title = String(counter)
            marker.map = mapView
            counter+=1
            print(counter)
            
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        showMarker()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}


extension mapViewController: GMSMapViewDelegate{
    
    
    func mapView(_ mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView? {
        
        let infoWindow = MapMarkerWindow.instanceFromNib() as! MapMarkerWindow
        let tempNum = Int(marker.title!)
        
        infoWindow.layer.cornerRadius = 6
        infoWindow.layer.borderWidth = 2
        infoWindow.layer.borderColor = UIColor.white.cgColor
        infoWindow.diveNoLabel.text = dives[tempNum!].diveNo
        infoWindow.dateLabel.text = dives[tempNum!].date
        infoWindow.diveSiteLabel.text = dives[tempNum!].diveSite
        infoWindow.locationLabel.text = dives[tempNum!].location + ","
        infoWindow.countryLabel.text = dives[tempNum!].country
        infoWindow.depthLabel.text = dives[tempNum!].depth
        infoWindow.btmTimeLabel.text = dives[tempNum!].bottomTime
        
        return infoWindow
    }
    
    
    func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker)  {
        
        self.performSegue(withIdentifier: "infoWindowSegue", sender: nil)
    }
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        print("weeeee")
        
        let tempIndex = Int(marker.title!)
        
        let camera2 = GMSCameraPosition.camera(withLatitude: dives[tempIndex!].latitude, longitude: dives[tempIndex!].longitude, zoom: 7.0)
        
        mapView.camera = camera2
        
        return false
    }
}

