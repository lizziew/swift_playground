//
//  Calendar.swift
//  PlanForMe
//
//  Created by Elizabeth Wei on 1/4/17.
//  Copyright © 2017 Elizabeth Wei. All rights reserved.
//

import UIKit
import EventKit

class Calendar : CustomStringConvertible {
    var ID: String
    var visible: Bool
    var title: String
    
    public var description: String { return "Calendar: \(title), \(ID), \(visible)" }
    
    init(title: String, ID: String, visible: Bool) {
        self.ID = ID
        self.visible = visible
        self.title = title 
    }
}
