//
//  HelpViewController.swift
//
//
//  Created by Michael Whinfrey on 4/2/19.
//

import UIKit

class HelpViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBOutlet weak var linkButton: LinkButton!
    
    @IBAction func linkClicked(_ sender: Any)
    { openUrl(urlStr: "http://mwhinf.github.io") }
    
    func openUrl(urlStr:String!) {
        
        if let url = URL(string:urlStr)
        { UIApplication.shared.open(url as URL, options: [:], completionHandler: nil) }
    }
}
