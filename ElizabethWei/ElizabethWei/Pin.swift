//
//  Pin.swift
//  ElizabethWei
//
//  Created by Elizabeth Wei on 4/23/16.
//  Copyright © 2016 Elizabeth Wei. All rights reserved.
//

import UIKit
import MapKit

class Pin: NSObject {
    var name: String
    var location: CLLocation
    var startDate: NSDate
    var endDate: NSDate
    var phoneNumber: String
    
    init?(name: String, location: CLLocation, startDate: NSDate, endDate: NSDate, phoneNumber: String) {
        self.name = name 
        self.location = location
        self.startDate = startDate
        self.endDate = endDate
        self.phoneNumber = phoneNumber 
        
        super.init()
    }
}
