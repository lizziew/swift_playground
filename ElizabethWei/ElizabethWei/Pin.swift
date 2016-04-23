//
//  Pin.swift
//  ElizabethWei
//
//  Created by Elizabeth Wei on 4/23/16.
//  Copyright © 2016 Elizabeth Wei. All rights reserved.
//

import UIKit

class Pin: NSObject, NSCoding {
    var location: String
    var date: String
    
    static let DocumentsDirectory = NSFileManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.URLByAppendingPathComponent("pins")
    
    struct PropertyKey {
        static let locationKey = "name"
        static let dateKey = "date"
    }
    
    init?(location: String, date: String) {
        self.location = location
        self.date = date
        
        super.init()
        
        if location.isEmpty || date.isEmpty {
            return nil
        }
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(location, forKey: PropertyKey.locationKey)
        aCoder.encodeObject(date, forKey: PropertyKey.dateKey)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        let location = aDecoder.decodeObjectForKey(PropertyKey.locationKey) as! String
        let date = aDecoder.decodeObjectForKey(PropertyKey.dateKey) as! String
        self.init(location: location, date: date)
    }
}
