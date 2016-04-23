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

    @IBOutlet weak var LocationTextField: UITextField!
    
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    @IBAction func cancel(sender: UIBarButtonItem) {
        let isPresentingInAddPinMode = presentingViewController is UINavigationController
        if isPresentingInAddPinMode {
            dismissViewControllerAnimated(true, completion: nil)
        }
        else {
            navigationController!.popViewControllerAnimated(true)
        }
    }
    
    var pin: Pin?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        LocationTextField.delegate = self
        
        if let pin = pin {
            navigationItem.title = pin.location
            LocationTextField.text   = pin.location
        }
        
        checkValidPinLocation()
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if saveButton === sender {
            let location = LocationTextField.text ?? ""
            pin = Pin(location: location, date: "new date placeholder")
        }
        if segue.identifier == "ShowLocation"{
            let navigationViewController = segue.destinationViewController as! UINavigationController
            if let locationViewController = navigationViewController.topViewController as! LocationViewController? {
                locationViewController.placemarkDelegate = self
            }
        }
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        saveButton.enabled = false
        performSegueWithIdentifier("ShowLocation", sender: self)
    }
    
    func checkValidPinLocation() {
        let text = LocationTextField.text ?? ""
        saveButton.enabled = !text.isEmpty
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        checkValidPinLocation()
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
        }
    }
}
