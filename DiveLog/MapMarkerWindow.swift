//
//  MapMarkerWindow.swift
//  DiveLog
//
//  Created by Michael Whinfrey on 6/6/18.
//  Copyright © 2018 Michael Whinfrey. All rights reserved.
//

import UIKit


class MapMarkerWindow: UIView {

    @IBOutlet weak var firstBox: UIView!
    @IBOutlet weak var secondBox: UIView!
    @IBOutlet weak var thirdBox: UIView!
    
    
    @IBOutlet weak var diveNoLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var diveSiteLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var countryLabel: UILabel!
    @IBOutlet weak var depthLabel: UILabel!
    @IBOutlet weak var btmTimeLabel: UILabel!
    
    
    class func instanceFromNib() -> UIView {
        return UINib(nibName: "MapMarkerWindowView", bundle: nil).instantiate(withOwner: self, options: nil).first as! UIView
    }

}
