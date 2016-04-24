//
//  Start.swift
//  ElizabethWei
//
//  Created by Elizabeth Wei on 4/24/16.
//  Copyright © 2016 Elizabeth Wei. All rights reserved.
//

import UIKit
import CloudKit

class Start: UITabBarController {
    
    var givenName: String? = nil
    
    var familyName: String? = nil
    
    var phoneNumber: String? = nil 
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let navigationController = viewControllers![0] as? UINavigationController {
            let controller = navigationController.viewControllers[0] as! PinTableViewController
            controller.familyName = familyName
            controller.givenName = givenName
            controller.phoneNumber = phoneNumber
        }
        if let controller = viewControllers![1] as? HomeViewController {
            controller.familyName = familyName
            controller.givenName = givenName
            controller.phoneNumber = phoneNumber
            self.selectedIndex = 1
        }
    }
}
