//
//  AddViewController.swift
//  PlanForMe
//
//  Created by Elizabeth Wei on 1/1/17.
//  Copyright © 2017 Elizabeth Wei. All rights reserved.
//

import UIKit
import os.log
import SwiftRangeSlider

class AddViewController: UIViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var timeSlider: RangeSlider!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var priorityPicker: UIPickerView!
    
    //TASK TO SEND BACK TO TASKTABLEVIEWCONTROLLER
    var task: Task?
    
    //PICKER VALUES
    var priorityChoices = ["Must do ❗️", "Would like to do"]
    
    override func viewDidAppear(_ animated: Bool) {
        //UPDATE PICKER VIEW HERE IF EDITING EXISTING TASK
        if let task = task {
            priorityPicker.selectRow(priorityChoices.count - task.priority, inComponent: 0, animated: true)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.nameTextField.delegate = self
        
        //IF EDITING EXISTING TASK (PICKER UPDATED IN VIEWDIDAPPEAR)
        if let task = task {
            nameTextField.text = task.name
            timeSlider.lowerValue = task.lowerTime
            timeSlider.upperValue = task.upperTime
        }
        
        //INITIALIZE TIME LABEL ABOVE TIME SLIDER
        let lowerText = valueToTime(timeSlider.lowerValue)
        let upperText = valueToTime(timeSlider.upperValue)
        timeLabel.text = "Time: " + lowerText + " to " + upperText
        
        //PRESS DONE OR TAP ANYWHERE TO DISMISS KEYBOARD
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(AddViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        //SET DELEGATE AND DATA SOURCE OF PRIORITY PICKER
        self.priorityPicker.delegate = self
        self.priorityPicker.dataSource = self
        
        //DISABLE SAVE BUTTON
        updateSaveButtonState()
    }
    
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        let isPresentingInAddTaskMode = presentingViewController is UITabBarController
        
        if isPresentingInAddTaskMode {
            //DISMISS WHEN ADDING NEW TASK
            dismiss(animated: true, completion: nil)
        }
        else if let owningNavigationController = navigationController {
            //DISMISS WHEN EDITING EXISTING TASK
            owningNavigationController.popViewController(animated: true)
        }
        else {
            fatalError("The AddViewController is not inside a navigation controller")
        }
    }
    
    //DISABLE SAVE BUTTON WHILE USER IS EDITING TASK NAME
    func textFieldDidBeginEditing(_ textField: UITextField) {
        saveButton.isEnabled = false
    }
    
    //DISABLE SAVE BUTTON IF TASK NAME FIELD IS EMPTY
    private func updateSaveButtonState() {
        let text = nameTextField.text ?? ""
        saveButton.isEnabled = !text.isEmpty
    }
    
    //ENABLE SAVE BUTTON IF TASK NAME FIELD IS NOT EMPTY
    func textFieldDidEndEditing(_ textField: UITextField) {
        updateSaveButtonState()
    }
    
    //PRESS DONE TO DISMISS KEYBOARD
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    //TAP ANYWHERE TO DISMISS KEYBOARD
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    //UPDATE LAYOUT FOR TIME SLIDER
    override func viewDidLayoutSubviews() {
        timeSlider.updateLayerFrames()
    }
    
    //PICKER METHOD
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    //PICKER METHOD
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return priorityChoices.count
    }
    
    //PICKER METHOD
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return priorityChoices[row]
    }
    
    @IBAction func timeSliderValueChanged(_ sender: RangeSlider) {
        let lowerText = valueToTime(timeSlider.lowerValue)
        let upperText = valueToTime(timeSlider.upperValue)
        timeLabel.text = "Time: " + lowerText + " to " + upperText
    }
    
    //UNWIND
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        guard let button = sender as? UIBarButtonItem, button === saveButton else
        {
            //CANCEL BUTTON WAS PRESSED
            os_log("The save button was not pressed, cancelling", log: OSLog.default, type: .debug)
            return
        }
        
        //SAVE BUTTON WAS PRESSED
        let name = nameTextField.text ?? ""
        let lowerTime = round(timeSlider.lowerValue * 2.0) / 2.0
        let upperTime = round(timeSlider.upperValue * 2.0) / 2.0
        
        var priority = 0
        let priorityInput = priorityChoices[priorityPicker.selectedRow(inComponent: 0)]
        switch priorityInput {
        case "Must do ❗️":
            priority = 2
        case "Would like to do":
            priority = 1
        default:
            priority = 0
        }
        
        task = Task(name: name, priority: priority, lowerTime: lowerTime, upperTime: upperTime)
    }
    
    //CONVERT TIME SLIDER VALUES TO DISPLAY TIME FOR LABEL
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

