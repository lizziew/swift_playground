//
//  main.swift
//  DataStructures
//
//  Created by Elizabeth Wei on 5/17/15.
//  Copyright (c) 2015 Elizabeth Wei. All rights reserved.
//

import Foundation

/*var testStack = Stack<Int>()
testStack.push(2)
testStack.push(3)
testStack.push(4)
testStack.pop()
testStack.push(5)
testStack.pop() */

var testQueue = Queue<Int>()
testQueue.enq(2)
testQueue.enq(3)
testQueue.deq()
testQueue.enq(4)
testQueue.deq()
testQueue.deq()
testQueue.deq()
testQueue.deq() 