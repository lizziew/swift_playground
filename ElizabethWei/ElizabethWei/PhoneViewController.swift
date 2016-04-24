//
//  PhoneViewController.swift
//  ElizabethWei
//
//  Created by Elizabeth Wei on 4/24/16.
//  Copyright © 2016 Elizabeth Wei. All rights reserved.
//

import UIKit
import CloudKit

class PhoneViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var PhoneInput: UITextField!
    
    @IBOutlet weak var startButton: UIButton!
    
    @IBAction func start(sender: UIButton) {
        self.performSegueWithIdentifier("ToApp", sender: sender)
    }
    
    @IBOutlet weak var WelcomeLabel: UILabel!
    
    var givenName: String? = nil
    
    var familyName: String? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        startButton.enabled = false

        PhoneInput.delegate = self
        
        PhoneInput.addTarget(self, action: #selector(PhoneViewController.textFieldDidChange(_:)), forControlEvents: UIControlEvents.EditingChanged)

        let container = CKContainer.defaultContainer()
        
        iCloudUserIDAsync() {
            recordID, error in
            if let userID = recordID?.recordName {
                print("received iCloudID \(userID)")
                
                container.requestApplicationPermission(.UserDiscoverability) { (status, error) in
                    guard error == nil else { return }
                    if status == CKApplicationPermissionStatus.Granted {
                        print("allowed to discovers user info")
                        container.discoverUserInfoWithUserRecordID(recordID!) { (info, fetchError) in
                            self.WelcomeLabel.text = "Welcome, " + (info?.displayContact?.givenName)! + " " + (info?.displayContact?.familyName)!
                            self.familyName = (info?.displayContact?.familyName)!
                            self.givenName = (info?.displayContact?.givenName)!
                        }
                    }
                }
            }
        }
    }
    
    func iCloudUserIDAsync(complete: (instance: CKRecordID?, error: NSError?) -> ()) {
        let container = CKContainer.defaultContainer()
        container.fetchUserRecordIDWithCompletionHandler() {
            recordID, error in
            if error != nil {
                print(error!.localizedDescription)
                complete(instance: nil, error: error)
            } else {
                print("fetched ID \(recordID?.recordName)")
                complete(instance: recordID, error: nil)
            }
        }
    }
    
    func textFieldDidChange(textField: UITextField) {
        if PhoneInput.text!.characters.count == 10 {
            startButton.enabled = true
        }
        else {
            startButton.enabled = false
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        let destinationVC = segue.destinationViewController as! Start
        destinationVC.familyName = familyName
        destinationVC.givenName = givenName
        destinationVC.phoneNumber = PhoneInput.text!
    }
}
