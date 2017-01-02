//
//  AddViewController.swift
//  PlanForMe
//
//  Created by Elizabeth Wei on 1/1/17.
//  Copyright © 2017 Elizabeth Wei. All rights reserved.
//

import UIKit
import SwiftRangeSlider

class AddViewController: UIViewController {
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var timeSlider: RangeSlider!
    @IBOutlet weak var timeLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let lowerText = valueToTime(timeSlider.lowerValue)
        let upperText = valueToTime(timeSlider.upperValue)
        timeLabel.text = "Time: " + lowerText + " to " + upperText
    }
    
    override func viewDidLayoutSubviews() {
        timeSlider.updateLayerFrames()
    }
    
    @IBAction func timeSliderValueChanged(_ sender: RangeSlider) {
        let lowerText = valueToTime(timeSlider.lowerValue)
        let upperText = valueToTime(timeSlider.upperValue)
        timeLabel.text = "Time: " + lowerText + " to " + upperText
    }
    
    func valueToTime(_ input: Double) -> String {
        let value = round(input * 2.0) / 2.0
        
        if value < 1 {
            if value == 0 {
                return "12 AM"
            }
            else {
                return "12:30 AM"
            }
        }
        else if value == 24 {
            return "12 AM" 
        }
        else if value == 12 {
            return "12 PM"
        }
        else if value == 12.5 {
            return "12:30 PM"
        }
        else if value > 12 {
            if value == floor(value) {
                return String(Int(value) - 12) + " PM"
            }
            else {
                return String(Int(value) - 12) + ":30 PM"
            }
        }
        else {
            if value == floor(value) {
                return String(Int(value)) + " AM"
            }
            else {
                return String(Int(value)) + ":30 AM"
            }
        }
    }
}

