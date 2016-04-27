//
//  LoginViewController.swift
//  ElizabethWei
//
//  Created by Elizabeth Wei on 4/24/16.
//  Copyright © 2016 Elizabeth Wei. All rights reserved.
//

import UIKit
import CloudKit

class LoginViewController: UIViewController {
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var statusLabel: UILabel!
    
    var givenName: String? = nil
    
    var familyName: String? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        activityIndicator.startAnimating()

        let container = CKContainer.defaultContainer()
        
        //icloud sign in?
        iCloudUserIDAsync() {
            recordID, error in
            if let userID = recordID?.recordName {
                print("received iCloudID \(userID)")
                container.requestApplicationPermission(.UserDiscoverability) { (status, error) in
                    guard error == nil else { return }
                    if status == CKApplicationPermissionStatus.Granted {
                        self.activityIndicator.stopAnimating()
                        container.discoverUserInfoWithUserRecordID(recordID!) { (info, fetchError) in
                            if fetchError != nil {
                                self.statusLabel.text = "Please sign into iCloud"
                            }
                            else {
                                self.familyName = (info?.displayContact?.familyName)!
                                self.givenName = (info?.displayContact?.givenName)!
                                self.performSegueWithIdentifier("ToApp", sender: nil)
                            }
                        }
                    }
                }
            }
        }
    }

    func iCloudUserIDAsync(complete: (instance: CKRecordID?, error: NSError?) -> ()) {
        let container = CKContainer.defaultContainer()
        
        container.fetchUserRecordIDWithCompletionHandler { (record: CKRecordID?, error: NSError?) in
            if error != nil {
                let alert = UIAlertController(title: "Please sign into iCloud", message: "You can sign in at Settings > iCloud", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
                print(error?.localizedDescription)
            }
            else {
                print("fetched ID \(record?.recordName)")
                complete(instance: record, error: nil)
            }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        let destinationVC = segue.destinationViewController as! Start
        destinationVC.familyName = familyName
        destinationVC.givenName = givenName
    }
}
