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
    @IBOutlet weak var editCalendarsButton: UIButton!
    
    let signOutButton = UIButton()
    let anonLoginButton = UIButton()
    let signInButton = GIDSignInButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        GIDSignIn.sharedInstance().clientID = FIRApp.defaultApp()?.options.clientID
        GIDSignIn.sharedInstance().delegate = self
        
        GIDSignIn.sharedInstance().uiDelegate = self
        //GIDSignIn.sharedInstance().signIn()
        
        //FIREBASE AUTH
        if (FIRAuth.auth()?.currentUser?.isAnonymous)!{
            print("ANONYMOUS USER")
        }
        
        //FIREBASE AUTH
        if (FIRAuth.auth()?.currentUser?.uid) == nil {
            displaySignOut()
        }
        else {
            displaySignIn()
        }
        
        //FORMAT PROFILE PICTURE
        profileImage.layer.cornerRadius = 10.0
        profileImage.clipsToBounds = true
        profileImage.layer.borderWidth = 3.0
        profileImage.layer.borderColor = UIColor.darkGray.cgColor
        
        //FORMAT SIGN OUT BUTTON
        signOutButton.setTitle("     Sign out     ", for: .normal)
        signOutButton.backgroundColor = UIColor(red: 221.0/255.0, green: 75.0/255.0, blue: 57.0/255.0, alpha: 1.0)
        signOutButton.setTitleColor(UIColor.white, for: .normal)
        signOutButton.addTarget(self, action: #selector(signOut(sender:)), for: .touchUpInside)
        signOutButton.layer.masksToBounds = false
        signOutButton.layer.cornerRadius = 3
        signOutButton.layer.shadowOffset = CGSize(width: 1.5, height: 1.5)
        signOutButton.layer.shadowRadius = 0.4
        signOutButton.layer.shadowOpacity = 1.0
        signOutButton.layer.shadowColor = UIColor.lightGray.cgColor
        signOutButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        
        //FORMAT EDIT CALENDARS BUTTON
        editCalendarsButton.backgroundColor = UIColor(red: 74.0/255.0, green: 139.0/255.0, blue: 244.0/255.0, alpha: 1.0)
        editCalendarsButton.layer.masksToBounds = false
        editCalendarsButton.layer.cornerRadius = 3
        editCalendarsButton.layer.shadowOffset = CGSize(width: 1.5, height: 1.5)
        editCalendarsButton.layer.shadowRadius = 0.4
        editCalendarsButton.layer.shadowOpacity = 1.0
        editCalendarsButton.layer.shadowColor = UIColor.lightGray.cgColor
        
        //FORMAT ANON LOGIN BUTTON
        anonLoginButton.setTitle("   Login anonymously   ", for: .normal)
        anonLoginButton.addTarget(self, action: #selector(anonLogin(sender:)), for: .touchUpInside)
        anonLoginButton.backgroundColor = UIColor(red: 221.0/255.0, green: 75.0/255.0, blue: 57.0/255.0, alpha: 1.0)
        anonLoginButton.setTitleColor(UIColor.white, for: .normal)
        anonLoginButton.layer.masksToBounds = false
        anonLoginButton.layer.cornerRadius = 3
        anonLoginButton.layer.shadowOffset = CGSize(width: 1.5, height: 1.5)
        anonLoginButton.layer.shadowRadius = 0.4
        anonLoginButton.layer.shadowOpacity = 1.0
        anonLoginButton.layer.shadowColor = UIColor.lightGray.cgColor
        anonLoginButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 13)
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
                if (FIRAuth.auth()?.currentUser?.isAnonymous)! {
                    //UPDATE SIGN IN LABEL
                    signInLabel.text = "Signed in as an anonymous user"
                    
                    //UPDATE PROFILE PIC
                    profileImage.image = UIImage(named: "profile")
                }
                else {
                    //UPDATE SIGN IN LABEL
                     signInLabel.text = "Signed in as " + (user.email!)
                    
                    //UPDATE PROFILE PICTURE
                    let url = user.photoURL!
                    let data = try? Data(contentsOf: url)
                    profileImage.image = UIImage(data: data!)
                }

                //UPDATE BUTTON
                //DELETE SIGN IN BUTTON
                if profileStackView.arrangedSubviews.count == 3 {
                    profileStackView.removeArrangedSubview(profileStackView.arrangedSubviews[2])
                    signInButton.removeFromSuperview()
                    anonLoginButton.removeFromSuperview()
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
        //ADD SIGN IN BUTTONS
        let loginStackView = UIStackView(arrangedSubviews: [signInButton, anonLoginButton])
        loginStackView.axis = .horizontal
        loginStackView.distribution = .fillEqually
        loginStackView.alignment = .fill
        loginStackView.spacing = 10
        
        //profileStackView.addArrangedSubview(signInButton)
        profileStackView.addArrangedSubview(loginStackView)
    }
    
    //SIGN IN ANONYMOUSLY
    func anonLogin(sender: UIButton!) {
        FIRAuth.auth()?.signInAnonymously(completion: { (user, error) in
            if let error = error {
                print(error)
                return
            }
            
            self.displaySignIn()
        })
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
    
    @IBAction func showCalendarSettings(_ sender: UIButton) {
        self.performSegue(withIdentifier: "CalendarSettingsSegue", sender: self)
    }
}
