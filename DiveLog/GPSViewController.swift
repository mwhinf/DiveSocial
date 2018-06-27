//
//  GPSViewController.swift
//  DiveLog
//
//  Created by Michael Whinfrey on 6/14/18.
//  Copyright © 2018 Michael Whinfrey. All rights reserved.
//

import UIKit
import GoogleMaps

class GPSViewController: UIViewController {

    var latitude = ""
    var longitude = ""
    
    @IBOutlet weak var testButton: UIButton!
    @IBOutlet weak var mapView: GMSMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let camera = GMSCameraPosition.camera(withLatitude: 20.189, longitude: 89.702, zoom: 2.0)
        mapView.camera = camera
        mapView.delegate = self
        mapView.settings.consumesGesturesInView = false
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        //if segue.destination is addDiveController
        if sender is ConfirmButton
        {
            let vc = segue.destination as? addDiveController
            let latString = latitude as NSString
            let longString = longitude as NSString
            let latDouble = latString.doubleValue
            let longDouble = longString.doubleValue
            let trimmedLatDouble = latDouble.truncate(places: 4)
            let trimmedLongDouble = longDouble.truncate(places: 4)
            let finalLatString = String(trimmedLatDouble)
            let finalLongString = String(trimmedLongDouble)
            
            vc?.lat = finalLatString
            vc?.long = finalLongString
            
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

extension GPSViewController: GMSMapViewDelegate{
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D){
        mapView.clear()
        latitude += String(coordinate.latitude)
        longitude += String(coordinate.longitude)
        let marker = GMSMarker(position: coordinate)
        marker.map = mapView
    }
}


extension Double
{
    func truncate(places : Int)-> Double
    {
        return Double(floor(pow(10.0, Double(places)) * self)/pow(10.0, Double(places)))
    }
}
