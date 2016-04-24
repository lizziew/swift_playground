//
//  SettingsViewController.swift
//  ElizabethWei
//
//  Created by Elizabeth Wei on 4/22/16.
//  Copyright © 2016 Elizabeth Wei. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {
    @IBOutlet weak var ExplanationLabel: UILabel!

    @IBOutlet weak var ExplanationLabel2: UILabel!
    
    @IBOutlet weak var CreditsLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()

        ExplanationLabel.text = "In the middle tab:\nFIND YOUR FRIENDS in the map! Their pins will show up if you'll be within 50 miles of each other for at least a day.\nTEXT YOUR FRIENDS by tapping on their pin."
        
        ExplanationLabel2.text = "In the left tab:\nADD NEW PINS by specifying your location and your data range if you want to be discoverable!"
        
        CreditsLabel.text = "Thanks to makeappicon.com and flaticon artists Dave Gandy, Egor Rymyantsev, and Freepik for icons"
    }
    
}
