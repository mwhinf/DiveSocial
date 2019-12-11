//
//  TableViewCell.swift
//  DiveLog
//
//  Created by Michael Whinfrey on 5/23/18.
//  Copyright © 2018 Michael Whinfrey. All rights reserved.
//

import UIKit

class TableViewCell: UITableViewCell {

    @IBOutlet weak var diveNoLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var diveSiteLabel: UILabel!
    @IBOutlet weak var depthLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var btmTimeLabel: UILabel!
    @IBOutlet weak var countryLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layoutMargins = UIEdgeInsetsMake(0,5,0,5)
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool)
    { super.setSelected(selected, animated: animated) }  // Configure the view for the selected state
}
