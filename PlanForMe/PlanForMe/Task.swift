//
//  Task.swift
//  PlanForMe
//
//  Created by Elizabeth Wei on 1/1/17.
//  Copyright © 2017 Elizabeth Wei. All rights reserved.
//

import UIKit
import EventKit

class Task : CustomStringConvertible {
    var name: String
    var calendarID: String
    var lowerTime: Date
    var upperTime: Date
    var event: EKEvent
    var color: UIColor
    
    public var description: String { return "Task: \(name), \(calendarID), \(lowerTime) to \(upperTime)" }
    
    init(name: String, calendarID: String, lowerTime: Date, upperTime: Date, event: EKEvent, color: UIColor) {
        self.name = name
        self.calendarID = calendarID 
        self.lowerTime = lowerTime
        self.upperTime = upperTime
        self.event = event
        self.color = color 
    }
}
