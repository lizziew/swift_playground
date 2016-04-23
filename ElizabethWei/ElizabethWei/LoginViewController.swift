//
//  ViewController.swift
//  ElizabethWei
//
//  Created by Elizabeth Wei on 4/22/16.
//  Copyright © 2016 Elizabeth Wei. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, FBSDKLoginButtonDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        if (FBSDKAccessToken.currentAccessToken() != nil)
        {
            print("already logged in")
    
            let tabBar = self.storyboard?.instantiateViewControllerWithIdentifier("tabBar") as! UITabBarController
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            
            tabBar.selectedIndex = 1
            
            appDelegate.window?.rootViewController = tabBar
        }
        else
        {
            let loginView : FBSDKLoginButton = FBSDKLoginButton()
            loginView.center = self.view.center
            loginView.readPermissions = ["public_profile", "user_friends"]
            loginView.delegate = self
            self.view.addSubview(loginView)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        print("User Logged In")
        
        if ((error) != nil)
        {
            // Process error
        }
        else if result.isCancelled {
            // Handle cancellations
        }
        else {
            let tabBar = self.storyboard?.instantiateViewControllerWithIdentifier("tabBar") as! UITabBarController
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            
            tabBar.selectedIndex = 1
            
            appDelegate.window?.rootViewController = tabBar

            if result.grantedPermissions.contains("email")
            {
                // Do work
            }
        }
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        print("User Logged Out")
    }
    
    func returnUserData()
    {
        let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me", parameters: nil)
        graphRequest.startWithCompletionHandler({ (connection, result, error) -> Void in
            
            if ((error) != nil)
            {
                // Process error
                print("Error: \(error)")
            }
            else
            {
                print("fetched user: \(result)")
                let userName : NSString = result.valueForKey("name") as! NSString
                print("User Name is: \(userName)")
                let userEmail : NSString = result.valueForKey("email") as! NSString
                print("User Email is: \(userEmail)")
            }
        })
    }
}

