//
//  Pin.swift
//  ElizabethWei
//
//  Created by Elizabeth Wei on 4/23/16.
//  Copyright © 2016 Elizabeth Wei. All rights reserved.
//

import UIKit
import MapKit

class Pin: NSObject/*, NSCoding*/ {
    var name: String
    var location: CLLocation
    var startDate: NSDate
    var endDate: NSDate
    
    //static let DocumentsDirectory = NSFileManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
   // static let ArchiveURL = DocumentsDirectory.URLByAppendingPathComponent("pins")
    
//    struct PropertyKey {
//        
//        static let locationKey = "location"
//        static let startDateKey = "startDate"
//        static let endDateKey = "endDate"
//        
//    }
    
    init?(name: String, location: CLLocation, startDate: NSDate, endDate: NSDate) {
        self.name = name 
        self.location = location
        self.startDate = startDate
        self.endDate = endDate
        
        super.init()
    }
    
//    func encodeWithCoder(aCoder: NSCoder) {
//        aCoder.encodeObject(location, forKey: PropertyKey.locationKey)
//        aCoder.encodeObject(startDate, forKey: PropertyKey.startDateKey)
//        aCoder.encodeObject(endDate, forKey: PropertyKey.endDateKey)
//    }
//    
//    required convenience init?(coder aDecoder: NSCoder) {
//        let location = aDecoder.decodeObjectForKey(PropertyKey.locationKey) as! MKPlacemark
//        let startDate = aDecoder.decodeObjectForKey(PropertyKey.startDateKey) as! NSDate
//        let endDate = aDecoder.decodeObjectForKey(PropertyKey.endDateKey) as! NSDate
//        self.init(location: location, startDate: startDate, endDate: endDate)
//    }
}
