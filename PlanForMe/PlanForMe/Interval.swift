//
//  Interval.swift
//  PlanForMe
//
//  Created by Elizabeth Wei on 1/2/17.
//  Copyright © 2017 Elizabeth Wei. All rights reserved.
//

import UIKit

class Interval : CustomStringConvertible {
    var weight: Int
    var index: Int
    var start: Date
    var finish: Date
    
    public var description: String { return "Interval: \(weight), \(index): \(start) to \(finish)" }
    
    init(weight: Int, index: Int, start: Date, finish: Date) {
        self.weight = weight
        self.index = index 
        self.start = start
        self.finish = finish
    }
}
