//
//  Task.swift
//  PlanForMe
//
//  Created by Elizabeth Wei on 1/1/17.
//  Copyright © 2017 Elizabeth Wei. All rights reserved.
//


//Copyright 2017 Elizabeth Wei
//
//Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
//
//The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//
//THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

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
