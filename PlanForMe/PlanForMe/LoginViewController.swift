//
//  LoginViewController.swift
//  PlanForMe
//
//  Created by Elizabeth Wei on 1/3/17.
//  Copyright © 2017 Elizabeth Wei. All rights reserved.
//


//Copyright 2017 Elizabeth Wei
//
//Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
//
//The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//
//THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

import UIKit
import Firebase
import FirebaseAuth 
import GoogleSignIn
import FirebaseDatabase

class LoginViewController: UIViewController, GIDSignInDelegate, GIDSignInUIDelegate { 
    var ref: FIRDatabaseReference!
    @IBOutlet weak var anonLoginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //GOOGLE SIGN IN SETUP
        GIDSignIn.sharedInstance().clientID = FIRApp.defaultApp()?.options.clientID
        GIDSignIn.sharedInstance().delegate = self

        GIDSignIn.sharedInstance().uiDelegate = self
        
        if FIRAuth.auth()?.currentUser != nil  {
            GIDSignIn.sharedInstance().signIn()
        }
        
        //FIREBASE DATABASE SETUP
        ref = FIRDatabase.database().reference()
        
        //FORMAT ANON LOGIN BUTTON
        anonLoginButton.backgroundColor = UIColor(red: 221.0/255.0, green: 75.0/255.0, blue: 57.0/255.0, alpha: 1.0)
        anonLoginButton.setTitleColor(UIColor.white, for: .normal)
        anonLoginButton.layer.masksToBounds = false
        anonLoginButton.layer.cornerRadius = 3
        anonLoginButton.layer.shadowOffset = CGSize(width: 1.5, height: 1.5)
        anonLoginButton.layer.shadowRadius = 0.4
        anonLoginButton.layer.shadowOpacity = 1.0
        anonLoginButton.layer.shadowColor = UIColor.lightGray.cgColor
        anonLoginButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
    }
    

    @IBAction func anonLogin(_ sender: UIButton) {
        FIRAuth.auth()?.signInAnonymously(completion: { (user, error) in
            if let error = error {
                print(error)
                return
            }
            
            print("user logged in anonymously")
            self.performSegue(withIdentifier: "LoginSegue", sender: self)
        })
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error?) {
        if let error = error {
            print(error.localizedDescription)
            return
        }
        
        guard let authentication = user.authentication else { return }
        let credential = FIRGoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                          accessToken: authentication.accessToken)
        FIRAuth.auth()?.signIn(with: credential) { (user, error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            //CREATE USER RECORD IN FIREBASE DATABASE
            let userID = user!.uid
            let userEmail = user!.email!
            self.ref.child("Users").observeSingleEvent(of: .value, with: { (snapshot) in
                if snapshot.hasChild(userID){
                    print("user already exists")
                }
                else{
                    self.ref.child("Users").child(userID).setValue(["Email": userEmail, "Calendars": [], "Tasks": []])
                    print("adding new user")
                }
            })

            //LOG IN TO APP
            self.performSegue(withIdentifier: "LoginSegue", sender: self)
        }
    }
}
