//
//  Interval.swift
//  PlanForMe
//
//  Created by Elizabeth Wei on 1/2/17.
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
