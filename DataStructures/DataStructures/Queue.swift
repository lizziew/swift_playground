//
//  Queue.swift
//  DataStructures
//
//  Created by Elizabeth Wei on 5/17/15.
//  Copyright (c) 2015 Elizabeth Wei. All rights reserved.
//

import Foundation

class Queue<T>{
    private var front: Node<T>! = nil
    private var back: Node<T>! = nil
    private var count = 0
    
    func enq(item: T) {
        var originalBack = back
        back = Node<T>()
        back.item = item
        back.next = nil
        if(isEmpty()) {
            front = back
        }
        else {
            originalBack.next = back
        }
        count++
        printQueue()
    }
    
    func deq() -> T? {
        if(count == 0) {
            println("ERROR: QUEUE IS EMPTY")
            return nil
        }
        
        let item = front.item
        front = front.next
        
        count--
        
        if(isEmpty()) {
            back = nil
        }
        
        printQueue()
        return item
    }
    
    func isEmpty() -> Bool {
        if(count == 0) {
            return true
        }
        else {
            return false
        }
    }
    
    func printQueue() {
        var currentNode = front
        while currentNode != nil {
            print("\(currentNode.item) ")
            currentNode = currentNode.next
        }
        println()
    }
}