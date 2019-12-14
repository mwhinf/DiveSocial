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
        { UIApplication.shared.open(url as URL, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil) }
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}
