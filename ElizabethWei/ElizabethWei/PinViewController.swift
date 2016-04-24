//
//  PinViewController.swift
//  ElizabethWei
//
//  Created by Elizabeth Wei on 4/23/16.
//  Copyright © 2016 Elizabeth Wei. All rights reserved.
//

import UIKit
import MapKit

class PinViewController: UIViewController, UITextFieldDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var StartDateTextField: UITextField!
    @IBOutlet weak var LocationTextField: UITextField!
    
    @IBOutlet weak var EndDateTextField: UITextField!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    @IBAction func cancel(sender: UIBarButtonItem) {
        //navigationController!.popViewControllerAnimated(true)
//        let isPresentingInAddPinMode = presentingViewController is UINavigationController
//        
//        print(presentingViewController)
        
        if presentingViewController != nil {
            print("situation 1")
            dismissViewControllerAnimated(true, completion: nil)
        }
        else {
            print("situation 2")
            navigationController!.popViewControllerAnimated(true)
        }
    }
    
    var pin: Pin?
    
    var locationInput: MKPlacemark? = nil {
        didSet {
            saveButton.enabled = false
            if locationInput != nil && startDateInput != nil && endDateInput != nil  {
                let location = LocationTextField.text ?? ""
                let startDate = StartDateTextField.text ?? ""
                let endDate = EndDateTextField.text ?? ""
            
                let filledOut = !location.isEmpty && !startDate.isEmpty && !endDate.isEmpty
            
                if !filledOut || endDateInput!.compare(startDateInput!) == NSComparisonResult.OrderedAscending {
                    saveButton.enabled = false
                }
                else {
                    saveButton.enabled = true
                }
            }
        }
    }
    
    var startDateInput: NSDate? = nil {
        didSet {
            saveButton.enabled = false
            if locationInput != nil && startDateInput != nil && endDateInput != nil {
                let location = LocationTextField.text ?? ""
                let startDate = StartDateTextField.text ?? ""
                let endDate = EndDateTextField.text ?? ""
                
                let filledOut = !location.isEmpty && !startDate.isEmpty && !endDate.isEmpty
                
                if !filledOut || endDateInput!.compare(startDateInput!) == NSComparisonResult.OrderedAscending {
                    saveButton.enabled = false
                }
                else {
                    saveButton.enabled = true
                }
            }
        }
    }
    
    var endDateInput: NSDate? = nil {
        didSet {
            saveButton.enabled = false
            print("got here")
            if locationInput != nil && startDateInput != nil && endDateInput != nil {
                let location = LocationTextField.text ?? ""
                let startDate = StartDateTextField.text ?? ""
                let endDate = EndDateTextField.text ?? ""
                
                let filledOut = !location.isEmpty && !startDate.isEmpty && !endDate.isEmpty
                
                if !filledOut || endDateInput!.compare(startDateInput!) == NSComparisonResult.OrderedAscending {
                    saveButton.enabled = false
                }
                else {
                    saveButton.enabled = true
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        LocationTextField.delegate = self
        StartDateTextField.delegate = self
        EndDateTextField.delegate = self
        
        saveButton.enabled = false
        
        if let pin = pin {
            let formatter = NSDateFormatter()
            formatter.dateFormat = "MMMM dd, YYYY"
            
            navigationItem.title = pin.location.name
            LocationTextField.text   = pin.location.name 
            StartDateTextField.text = formatter.stringFromDate(pin.startDate)
            EndDateTextField.text = formatter.stringFromDate(pin.endDate)
            
            locationInput = pin.location
            startDateInput = pin.startDate
            endDateInput = pin.endDate
        }
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if saveButton === sender {
            pin = Pin(location: locationInput!, startDate: startDateInput!, endDate: endDateInput!)
        }
        if segue.identifier == "ShowLocation"{
            let navigationViewController = segue.destinationViewController as! UINavigationController
            if let locationViewController = navigationViewController.topViewController as! LocationViewController? {
                locationViewController.placemarkDelegate = self
            }
        }
        else if segue.identifier == "ShowStartDate" {
            let navigationViewController = segue.destinationViewController as! UINavigationController
            if let startDateViewController = navigationViewController.topViewController as! StartDateViewController? {
                startDateViewController.startDateDelegate = self
            }
        }
        else if segue.identifier == "ShowEndDate" {
            let navigationViewController = segue.destinationViewController as! UINavigationController
            if let endDateViewController = navigationViewController.topViewController as! EndDateViewController? {
                endDateViewController.endDateDelegate = self
            }
        }
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        if textField === LocationTextField {
            performSegueWithIdentifier("ShowLocation", sender: self)
        }
        else if textField === StartDateTextField {
            performSegueWithIdentifier("ShowStartDate", sender: self)
        }
        else if textField === EndDateTextField {
            performSegueWithIdentifier("ShowEndDate", sender: self)
        }
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        navigationItem.title = LocationTextField.text
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension PinViewController: PlacemarkDelegate
{
    func sendPlacemarkToPin(placemark: MKPlacemark?) {
        if placemark != nil {
            LocationTextField.text = placemark!.name
            locationInput = placemark
        }
    }
}

extension PinViewController: StartDateDelegate
{
    func sendStartDateToPin(date: NSDate) {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "MMMM dd, YYYY"
        StartDateTextField.text = formatter.stringFromDate(date)
        startDateInput = date
    }
}

extension PinViewController: EndDateDelegate
{
    func sendEndDateToPin(date: NSDate) {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "MMMM dd, YYYY"
        EndDateTextField.text = formatter.stringFromDate(date)
        endDateInput = date
    }
}