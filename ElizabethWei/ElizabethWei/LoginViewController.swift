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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
                        print("allowed to discovers user info")
                        self.startButton.enabled = true
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
                        print("allowed to discovers user info")
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
                print(error!.localizedDescription)
                complete(instance: nil, error: error)
            } else {
                print("fetched ID \(recordID?.recordName)")
                complete(instance: recordID, error: nil)
            }
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
