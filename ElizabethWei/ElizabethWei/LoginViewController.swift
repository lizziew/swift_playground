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

    @IBAction func start(sender: UIButton) {
        self.performSegueWithIdentifier("ToPhone", sender: sender)
    }
    
    @IBOutlet weak var startButton: UIButton!
    
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var statusLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        activityIndicator.startAnimating()
        
        startButton.enabled = false

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
                        self.startButton.enabled = true
                        container.discoverUserInfoWithUserRecordID(recordID!) { (info, fetchError) in
                            self.performSegueWithIdentifier("ToPhone", sender: nil)
                        }
                    }
                }
            }
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        let container = CKContainer.defaultContainer()
        
        iCloudUserIDAsync() {
            recordID, error in
            if let userID = recordID?.recordName {
                print("received iCloudID \(userID)")
                container.requestApplicationPermission(.UserDiscoverability) { (status, error) in
                    guard error == nil else { return }
                    if status == CKApplicationPermissionStatus.Granted {
                        self.activityIndicator.stopAnimating()
                        self.startButton.enabled = true
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
}
