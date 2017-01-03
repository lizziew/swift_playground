//
//  Task.swift
//  PlanForMe
//
//  Created by Elizabeth Wei on 1/1/17.
//  Copyright © 2017 Elizabeth Wei. All rights reserved.
//

import UIKit

class Task : CustomStringConvertible {
    var name: String
    var priority: Int
    var lowerTime: Double
    var upperTime: Double
    
    public var description: String { return "Task: \(name), \(priority), \(lowerTime) to \(upperTime)" }
    
    init?(name: String, priority: Int, lowerTime: Double, upperTime: Double) {
        if name.isEmpty || !(priority == 1 || priority == 2) || !(lowerTime >= 0 && lowerTime <= 24) || !(upperTime >= 0 && upperTime <= 24) {
            print("INVALID TASK") 
            return nil
        }
        
        self.name = name
        self.priority = priority
        self.lowerTime = lowerTime
        self.upperTime = upperTime
    }
}
