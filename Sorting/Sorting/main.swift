//
//  main.swift
//  Sorting
//
//  Created by Elizabeth Wei on 5/17/15.
//  Copyright (c) 2015 Elizabeth Wei. All rights reserved.
//

import Foundation

var numberList = [10, 1, 5, 1, 10, 13, 100, 4, 1, 3, 10]

var sortTest = Sorting()

numberList = sortTest.mergeSort(numberList)

for item in numberList {
    println(item)
}

