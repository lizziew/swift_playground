//
//  Sorting.swift
//  Sorting
//
//  Created by Elizabeth Wei on 5/17/15.
//  Copyright (c) 2015 Elizabeth Wei. All rights reserved.
//

import Foundation

public class Sorting {
    func bubbleSort(var numberList: [Int]) -> [Int]{
        for i in 0..<numberList.count{
            for j in i+1..<numberList.count{
                if(numberList[i] > numberList[j]) {
                    swap(&numberList[i], &numberList[j])
                }
            }
        }
        return numberList
    }
    
    func insertionSort(var numberList: [Int]) -> [Int] {
        for i in 1..<numberList.count {
            var j = i
            while j > 0 {
                if(numberList[j] < numberList[j-1]) {
                    swap(&numberList[j-1], &numberList[j])
                    j--
                }
                else {
                    break 
                }
            }
        }
        return numberList
    }
    
    func selectionSort(var numberList: [Int]) -> [Int] {
        for i in 0..<numberList.count {
            var minimumIndex = i
            for j in i+1..<numberList.count {
                if(numberList[j] < numberList[minimumIndex]) {
                    minimumIndex = j
                }
            }
            swap(&numberList[i], &numberList[minimumIndex])
        }
        
        return numberList
    }
    
    func mergeSort(var numberList: [Int]) -> [Int] {
        var copyOfNumberList = [Int](count: numberList.count, repeatedValue: 0)
        recursiveMergeSort(&numberList, copyOfNumberList: copyOfNumberList, lowIndex: 0, highIndex: numberList.count-1)
        return numberList
    }

    func recursiveMergeSort(inout numberList: [Int], var copyOfNumberList: [Int], lowIndex: Int, highIndex: Int) {
        if(lowIndex > highIndex) {
            return
        }
        var midIndex = (lowIndex + highIndex)/2
        recursiveMergeSort(&numberList, copyOfNumberList: copyOfNumberList, lowIndex: lowIndex, highIndex: midIndex)
        recursiveMergeSort(&numberList, copyOfNumberList: copyOfNumberList,lowIndex: midIndex+1, highIndex: highIndex)
        merge(&numberList, copyOfNumberList: copyOfNumberList, lowIndex: lowIndex, midIndex: midIndex, highIndex: highIndex)
    }
    
    func merge(inout numberList: [Int], var copyOfNumberList: [Int], lowIndex: Int, midIndex: Int, highIndex: Int) {
        for i in 0..<numberList.count {
            copyOfNumberList[i] = numberList[i]
        }
        
        var i = lowIndex
        var j = midIndex+1
        
        for k in 0..<numberList.count {
            if(i > midIndex) {
                numberList[k] = copyOfNumberList[j++]
            }
            else if(j > highIndex) {
                numberList[k] = copyOfNumberList[i++]
            }
            else if(copyOfNumberList[j] > copyOfNumberList[i]) {
                numberList[k] = copyOfNumberList[j++]
            }
            else {
                numberList[k] = copyOfNumberList[i++]
            }
        }
    }
}
