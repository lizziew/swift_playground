//
//  SettingsViewController.swift
//  ElizabethWei
//
//  Created by Elizabeth Wei on 4/22/16.
//  Copyright © 2016 Elizabeth Wei. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {
    
    @IBOutlet weak var CreditsLabel: UILabel!
    
    @IBOutlet weak var title1: UILabel!
    
    @IBOutlet weak var subtitle1: UILabel!
    
    @IBOutlet weak var title2: UILabel!
    
    @IBOutlet weak var subtitle2: UILabel!
    
    @IBOutlet weak var title3: UILabel!
    
    @IBOutlet weak var subtitle3: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title1.text = "Find your friends"
        
        subtitle1.text = "Their pins show up on the map if you'll be within 50 miles of each other for at least a day"
        
        title2.text = "Text your friends"
        
        subtitle2.text = "Tap on a pin and send a text to meet up"
        
        title3.text = "Add your own pins"
        
        subtitle3.text = "Specify your location and date range if you want to be discoverable"
        
        CreditsLabel.text = "Thanks to makeappicon.com and flaticon artists Dave Gandy, Egor Rymyantsev, and Freepik for icons"
    }
    
}
