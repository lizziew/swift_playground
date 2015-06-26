//
//  ViewController.swift
//  Calculator
//
//  Created by Elizabeth Wei on 3/7/15.
//  Copyright (c) 2015 Elizabeth Wei. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var prevDisplay: UILabel!
    @IBOutlet weak var display: UILabel!
    
    var userTypingANum = false //type inference
    var decPoint = false
    var brain = CalculatorBrain() //connection from controller to model
    
    @IBAction func clear() { //redo this to work with CalculatorBrain
        displayValue = nil
        prevDisplay.text = "0="
        userTypingANum = false
        decPoint = false
        brain.clear() 
    }
    
    
    @IBAction func backspace() {
        if(userTypingANum) {
            if(count(display.text!) > 1) {
                display.text = dropLast(display.text!)
            }
            else {
                display.text = "0"
                userTypingANum = false
            }
        }
        
    }
    
    @IBAction func appendDigit(sender: UIButton) {
        let digit = sender.currentTitle!
        
        if(digit == ".") {
            if(decPoint) {
                return
            }
            else {
                decPoint = true
            }
        }
        
        if(userTypingANum) {
            display.text = display.text! + digit
        }
        else {
            display.text = digit
            userTypingANum = true
        }
    }
    
    @IBAction func setVar() {
        if userTypingANum {
            enter()
        }
        
        userTypingANum = false
        decPoint = false
        
        if let val = brain.getVariableValue() {
            if let result = brain.setVariable("M", value: val) {
                println("calculated result as \(result)")
                displayValue = result
            }
            else {
                displayValue = nil
            }
            prevDisplay.text = brain.description + "="
        }
    }
    
    
    @IBAction func pushVar() {
        brain.pushOperand("M")
    }
    
    @IBAction func invertSign(sender: UIButton) {
        if userTypingANum {
            if(displayValue < 0) {
                display.text = dropFirst(display.text!)
            }
            else {
                display.text = "-" + display.text!
            }
        }
        else {
            if let operation = sender.currentTitle {
                if let result = brain.performOperation(operation) {
                    displayValue = result
                }
                else {
                    displayValue = nil
                }
                prevDisplay.text = brain.description + "="
            }
        }
    }
    
    @IBAction func operate(sender: UIButton) {
        if userTypingANum {
            enter()
        }
        
        if let operation = sender.currentTitle {
            if let result = brain.performOperation(operation) {
                displayValue = result
            }
            else {
                displayValue = nil
            }
            prevDisplay.text = brain.description + "=";
        }
    }
    
    @IBAction func enter() {
        userTypingANum = false
        decPoint = false
        if let result = brain.pushOperand(displayValue!) {
            displayValue = result
        } else {
            displayValue = nil
        }
        prevDisplay.text = brain.description + "=";
    }
    
    //computed property (value not actually stored)
    var displayValue: Double? {
        get{
            return NSNumberFormatter().numberFromString(display.text!)!.doubleValue
        }
        set{
            if let val = newValue { //newValue: default name of new value to be set
                display.text = "\(val)"
            } else {
                display.text = " " //used for clear
            }
            userTypingANum = false
            decPoint = false
        }
    }
}

 