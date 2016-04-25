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
                            self.familyName = (info?.displayContact?.familyName)!
                            self.givenName = (info?.displayContact?.givenName)!
                            self.performSegueWithIdentifier("ToApp", sender: nil)
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
                self.statusLabel.text = "Please sign into iCloud"
                print(error!.localizedDescription)
                complete(instance: nil, error: error)
            } else {
                print("fetched ID \(recordID?.recordName)")
                complete(instance: recordID, error: nil)
            }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        let destinationVC = segue.destinationViewController as! Start
        destinationVC.familyName = familyName
        destinationVC.givenName = givenName
    }
}
