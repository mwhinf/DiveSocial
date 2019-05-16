//
//  mapViewController.swift
//  DiveLog
//
//  Created by Michael Whinfrey on 5/30/18.
//  Copyright © 2018 Michael Whinfrey. All rights reserved.
//

import UIKit
import GoogleMaps
import CoreData


class mapViewController: UIViewController {

    
    var dives: [NSManagedObject] = []
    var camera = GMSCameraPosition.camera(withLatitude: 20.189, longitude: 89.702, zoom: 2.0)
    
    @IBAction func unwindToMap(unwindSegue: UIStoryboardSegue) {
        
    }
    
    
    @IBAction func longPress(_ sender: UILongPressGestureRecognizer) {
        camera = GMSCameraPosition.camera(withLatitude: 20.189, longitude: 89.702, zoom: 2.0)
        
        mapView.camera = camera
    }
    
    @IBOutlet fileprivate weak var mapView: GMSMapView!
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.destination is DiveListController
        {
            let vc = segue.destination as? DiveListController
            vc?.dives = dives
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        camera = GMSCameraPosition.camera(withLatitude: 20.189, longitude: 89.702, zoom: 2.0)
//
//        if dives.last != nil {
//           camera = GMSCameraPosition.camera(withLatitude: dives.last!.latitude, longitude: dives.last!.longitude, zoom: 2.0)
//        }
//        else {
//            camera = GMSCameraPosition.camera(withLatitude: 20.189, longitude: 89.702, zoom: 2.0)
//        }
//
//
//        mapView.camera = camera
        mapView.delegate = self
        mapView.mapType = GMSMapViewType.hybrid
        mapView.settings.consumesGesturesInView = false
        //markerPosition = GMSMarker()
        //mapView.selectedMarker = markerPosition
    }
    
    func showMarker(){
        var counter = 0
        for dive in dives {
            
            let marker = GMSMarker()
            let tempLat = dive.value(forKeyPath: "latitude") as? Double
            let tempLong = dive.value(forKeyPath: "longitude") as? Double
            marker.position = CLLocationCoordinate2D(latitude: tempLat!, longitude: tempLong!)
            marker.title = String(counter)
            marker.map = mapView
            if counter == dives.count - 1 {
                mapView.selectedMarker = marker
            
            }
            counter+=1
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
//        if dives.last != nil {
//            camera = GMSCameraPosition.camera(withLatitude: dives.last!.latitude, longitude: dives.last!.longitude, zoom: 2.0)
//        }
//        else {
//            camera = GMSCameraPosition.camera(withLatitude: 20.189, longitude: 89.702, zoom: 2.0)
//        }
        
        camera = GMSCameraPosition.camera(withLatitude: 20.189, longitude: 89.702, zoom: 2.0)
        
        mapView.camera = camera
        
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
        let diveTemp =  dives[tempNum!]
        let diveNoTemp = diveTemp.value(forKeyPath: "diveNo") as? String
        infoWindow.diveNoLabel.text = "Dive No. " + diveNoTemp!
        infoWindow.dateLabel.text = diveTemp.value(forKeyPath: "date") as? String
        infoWindow.diveSiteLabel.text = diveTemp.value(forKeyPath: "diveSite") as? String
        let locationTemp = diveTemp.value(forKeyPath: "location") as? String
        if locationTemp?.isEmpty == false {
            infoWindow.locationLabel.text = locationTemp! + ","
        }
        else {
            infoWindow.locationLabel.text = locationTemp!
        }
        
        infoWindow.countryLabel.text = diveTemp.value(forKeyPath: "country") as? String
        infoWindow.depthLabel.text = diveTemp.value(forKeyPath: "depth") as? String
        infoWindow.btmTimeLabel.text = diveTemp.value(forKeyPath: "bottomTime") as? String
        
        return infoWindow
    }
    
    
    //func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker)  {
        
    //    self.performSegue(withIdentifier: "infoWindowSegue", sender: nil)
   // }
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {

        let tempIndex = Int(marker.title!)

        let diveTemp =  dives[tempIndex!]
        let latTemp = diveTemp.value(forKeyPath: "latitude") as? Double
        let longTemp = diveTemp.value(forKeyPath: "longitude") as? Double
        let currentZoom = mapView.camera.zoom
        print(currentZoom)
        
        let camera2 = GMSCameraPosition.camera(withLatitude: latTemp!, longitude: longTemp!, zoom: currentZoom)

        //let cameraUpdate = GMSCameraUpdate.setCamera(camera2)
        
        
        mapView.animate(to: camera2)
        
        //mapView.camera = camera2

        return false
    }
}

