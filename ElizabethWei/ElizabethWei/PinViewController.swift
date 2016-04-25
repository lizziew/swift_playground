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
        let isPresentingInAddPinMode = presentingViewController is UINavigationController
        if isPresentingInAddPinMode {
            print("situation 1")
            
            dismissViewControllerAnimated(true, completion: nil)
            
        }
        else {
            print("situation 2")
           navigationController!.popViewControllerAnimated(true)
        }
    }
    
    @IBOutlet weak var phoneTextField: UITextField!
    
    var pin: Pin?
    
    var nameInput: String? = nil
    
    var phoneInput: String? = nil {
        didSet {
            saveButton.enabled = false
            if locationInput != nil && startDateInput != nil && endDateInput != nil && phoneInput != nil {
                let location = LocationTextField.text ?? ""
                let startDate = StartDateTextField.text ?? ""
                let endDate = EndDateTextField.text ?? ""
                let phoneNumber = phoneTextField.text ?? ""
                
                let filledOut = !location.isEmpty && !startDate.isEmpty && !endDate.isEmpty && !phoneNumber.isEmpty
                
                if !filledOut || (endDateInput!.compare(startDateInput!) == NSComparisonResult.OrderedAscending || endDateInput!.compare(startDateInput!) == NSComparisonResult.OrderedSame) {
                    saveButton.enabled = false
                }
                else {
                    saveButton.enabled = true
                }
            }
        }
    }
    
    var locationInput: CLLocation? = nil {
        didSet {
            saveButton.enabled = false
            if locationInput != nil && startDateInput != nil && endDateInput != nil && phoneInput != nil {
                let location = LocationTextField.text ?? ""
                let startDate = StartDateTextField.text ?? ""
                let endDate = EndDateTextField.text ?? ""
                let phoneNumber = phoneTextField.text ?? ""
            
                let filledOut = !location.isEmpty && !startDate.isEmpty && !endDate.isEmpty && !phoneNumber.isEmpty
            
                if !filledOut || (endDateInput!.compare(startDateInput!) == NSComparisonResult.OrderedAscending || endDateInput!.compare(startDateInput!) == NSComparisonResult.OrderedSame) {
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
            if locationInput != nil && startDateInput != nil && endDateInput != nil && phoneInput != nil {
                let location = LocationTextField.text ?? ""
                let startDate = StartDateTextField.text ?? ""
                let endDate = EndDateTextField.text ?? ""
                let phoneNumber = phoneTextField.text ?? ""
                
                let filledOut = !location.isEmpty && !startDate.isEmpty && !endDate.isEmpty && !phoneNumber.isEmpty
                
                if !filledOut || (endDateInput!.compare(startDateInput!) == NSComparisonResult.OrderedAscending || endDateInput!.compare(startDateInput!) == NSComparisonResult.OrderedSame) {
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
            if locationInput != nil && startDateInput != nil && endDateInput != nil && phoneInput != nil {
                let location = LocationTextField.text ?? ""
                let startDate = StartDateTextField.text ?? ""
                let endDate = EndDateTextField.text ?? ""
                let phoneNumber = phoneTextField.text ?? ""
                
                let filledOut = !location.isEmpty && !startDate.isEmpty && !endDate.isEmpty && !phoneNumber.isEmpty
                
                if !filledOut || (endDateInput!.compare(startDateInput!) == NSComparisonResult.OrderedAscending || endDateInput!.compare(startDateInput!) == NSComparisonResult.OrderedSame) {
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
        phoneTextField.delegate = self
        
        saveButton.enabled = false
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(PinViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        phoneTextField.addTarget(self, action: #selector(PinViewController.textFieldDidChange(_:)), forControlEvents: UIControlEvents.EditingChanged)
        
        if let pin = pin {
            let formatter = NSDateFormatter()
            formatter.dateFormat = "MMMM dd, YYYY"
            
            navigationItem.title = pin.name
            LocationTextField.text   = pin.name
            StartDateTextField.text = formatter.stringFromDate(pin.startDate)
            EndDateTextField.text = formatter.stringFromDate(pin.endDate)
            phoneTextField.text = pin.phoneNumber
            
            nameInput = pin.name 
            locationInput = pin.location
            startDateInput = pin.startDate
            endDateInput = pin.endDate
            phoneInput = pin.phoneNumber
        }
    }
    
    func textFieldDidChange(textField: UITextField) {
        phoneInput = phoneTextField.text
    }
    
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        phoneInput = phoneTextField.text
        view.endEditing(true)
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if saveButton === sender {
            pin = Pin(name: nameInput!, location: locationInput!, startDate: startDateInput!, endDate: endDateInput!, phoneNumber: phoneInput!)
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
            nameInput = placemark!.name
            locationInput = placemark!.location
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