
//
//  CustomPin.swift
//  ElizabethWei
//
//  Created by Elizabeth Wei on 4/24/16.
//  Copyright © 2016 Elizabeth Wei. All rights reserved.
//

import Foundation
import MapKit

class CustomPin: NSObject, MKAnnotation {
    let title: String?
    let name: String
    let phoneNumber: String
    let coordinate: CLLocationCoordinate2D
    
    init(title: String, name: String, phoneNumber: String, coordinate: CLLocationCoordinate2D) {
        self.title = title
        self.name = name
        self.phoneNumber = phoneNumber
        self.coordinate = coordinate
        
        super.init()
    }
    
    var subtitle: String? {
        return name
    }
}

