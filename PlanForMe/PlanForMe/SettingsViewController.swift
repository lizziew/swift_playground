//
//  SettingsViewController.swift
//  PlanForMe
//
//  Created by Elizabeth Wei on 1/3/17.
//  Copyright © 2017 Elizabeth Wei. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import GoogleSignIn

class SettingsViewController: UIViewController, GIDSignInDelegate, GIDSignInUIDelegate {

    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var signInLabel: UILabel!
    @IBOutlet weak var profileStackView: UIStackView!
    
    let signOutButton = UIButton()
    let signInButton = GIDSignInButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        GIDSignIn.sharedInstance().clientID = FIRApp.defaultApp()?.options.clientID
        GIDSignIn.sharedInstance().delegate = self
        
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().signIn()
        
        //FORMAT PROFILE PICTURE
        profileImage.layer.cornerRadius = 10.0
        profileImage.clipsToBounds = true
        profileImage.layer.borderWidth = 3.0
        profileImage.layer.borderColor = UIColor.white.cgColor
        
        //FORMAT SIGN OUT BUTTON
        signOutButton.setTitle("Sign out", for: .normal)
        signOutButton.backgroundColor = UIColor.red
        signOutButton.setTitleColor(UIColor.white, for: .normal)
        signOutButton.addTarget(self, action: #selector(signOut(sender:)), for: .touchUpInside)
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
            
            print("User logged in through google")
            self.displaySignIn()
        }
    }
    
    func displaySignIn() {
        if FIRAuth.auth()?.currentUser != nil {
            if let user = FIRAuth.auth()?.currentUser {
                //UPDATE SIGN IN LABEL
                signInLabel.text = "Signed in as " + (user.email!)
                
                //UPDATE PROFILE PICTURE
                let url = user.photoURL!
                let data = try? Data(contentsOf: url)
                profileImage.image = UIImage(data: data!)
                
                //UPDATE BUTTON
                //DELETE SIGN IN BUTTON
                if profileStackView.arrangedSubviews.count == 3 {
                    profileStackView.removeArrangedSubview(profileStackView.arrangedSubviews[2])
                    signInButton.removeFromSuperview()
                }
                //ADD SIGN OUT BUTTON
                profileStackView.addArrangedSubview(signOutButton)
            }
        }
    }
    
    func displaySignOut() {
        //UPDATE SIGN IN LABEL
        signInLabel.text = "You're not signed in"
        
        //UPDATE PROFILE PICTURE
        profileImage.image = UIImage(named: "profile")
        
        //UPDATE BUTTON
        //DELETE SIGN OUT BUTTON
        if profileStackView.arrangedSubviews.count == 3 {
            profileStackView.removeArrangedSubview(profileStackView.arrangedSubviews[2])
            signOutButton.removeFromSuperview()
        }
        //ADD SIGN IN BUTTON
        profileStackView.addArrangedSubview(signInButton)
    }
    
    //SIGN OUT USING FIREBASE AUTH
    func signOut(sender:UIButton!) {
        let firebaseAuth = FIRAuth.auth()
        do {
            try firebaseAuth?.signOut()
            
            displaySignOut()
            
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
    }
}
