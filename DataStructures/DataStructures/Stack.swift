//
//  Stack.swift
//  DataStructures
//
//  Created by Elizabeth Wei on 5/17/15.
//  Copyright (c) 2015 Elizabeth Wei. All rights reserved.
//

import Foundation

class Stack<T>{
    private var front: Node<T>! = nil
    private var count = 0
    
    func push(item: T) {
        var originalFront = front
        front = Node<T>()
        front.item = item
        front.next = originalFront
        count++
        
        printStack()
    }
    
    func pop() -> T? {
        if(front == nil) {
            println("STACK IS EMPTY")
            return nil
        }
        
        count--
        let item = front.item
        front = front.next
        
        printStack()
        
        return item
    }
    
    func peek() -> T? {
        if(front == nil) {
            return nil
        }
        return front.item
    }
    
    func isEmpty() -> Bool {
        if(count == 0) {
            return true
        }
        else {
            return false
        }
    }
    
    func getCount() -> Int{
        return count
    }
    
    func printStack() {
        var currNode = front
        while currNode != nil {
            print("\(currNode.item) ")
            currNode = currNode.next
        }
        println()
    }
}