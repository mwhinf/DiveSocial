//
//  CustomTabBarController.swift
//  DiveLog
//
//  Created by Michael Whinfrey on 6/15/18.
//  Copyright © 2018 Michael Whinfrey. All rights reserved.
//

import UIKit

class CustomTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.destination is mapViewController
        {
            print("WAHOOOO")
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
