//
//  CalendarSettingsTableViewController.swift
//  
//
//  Created by Elizabeth Wei on 1/4/17.
//
//


//Copyright 2017 Elizabeth Wei
//
//Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
//
//The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//
//THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

import UIKit
import EventKit

import Firebase
import FirebaseAuth
import FirebaseDatabase

class CalendarSettingsTableViewController: UITableViewController {
    //EVENTKIT
    let eventStore = EKEventStore()
    var calendars = [Cal]()
    var planForMeCalID: String?
    
    //FIREBASE DATABASE
    var ref: FIRDatabaseReference!
    var userID = ""
    var notLoggedIn = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //FIREBASE DATABASE SETUP
        ref = FIRDatabase.database().reference()
        if (FIRAuth.auth()?.currentUser?.uid) != nil {
            userID = (FIRAuth.auth()?.currentUser?.uid)!
        }
        else {
            notLoggedIn = true
        }
        
        //LOAD IN CALENDARS
        self.refreshControl?.addTarget(self, action: #selector(handleRefresh(refreshControl:)), for: UIControlEvents.valueChanged)
        checkCalendarAuthorizationStatus()
        
        tableView.separatorStyle = .none
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if (FIRAuth.auth()?.currentUser?.uid) != nil {
            userID = (FIRAuth.auth()?.currentUser?.uid)!
        }
        else {
            notLoggedIn = true
        }
    }
    
    func handleRefresh(refreshControl: UIRefreshControl) {
        checkCalendarAuthorizationStatus()
        self.tableView.reloadData()
        refreshControl.endRefreshing()
    }
    
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return calendars.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CalendarTableViewCell", for: indexPath) as? CalendarTableViewCell else {
            fatalError("Dequeued cell isn't an instance of CalendarTableViewCell")
        }
        
        if calendars.count == 0 {
            return cell
        }
        
        //SET TITLE
        cell.calendarLabel.text = calendars[indexPath.row].title
        
        //SET COLOR AND CHECKBOX
        if calendars[indexPath.row].visible {
            cell.backgroundColor = UIColor.green.withAlphaComponent(0.3)
            cell.checkbox.setImage(UIImage(named: "checked"), for: .normal)
            cell.checked = true
        }
        else {
            cell.backgroundColor = UIColor.red.withAlphaComponent(0.3)
            cell.checkbox.setImage(UIImage(named: "unchecked"), for: .normal)
            cell.checked = true
        }
        
        cell.tapAction = { (cell) in
            self.toggleCalendar(cell, self.calendars[indexPath.row])
        }

        return cell
    }
    
    func toggleCalendar(_ cell: CalendarTableViewCell, _ cal: Cal) {
        if cell.checked {
            cell.checkbox.setImage(UIImage(named: "unchecked"), for: .normal)
            cell.checked = false
            cell.backgroundColor = UIColor.red.withAlphaComponent(0.3)
            self.ref.child("Users/\(self.userID)/Calendars/").child(cal.ID).setValue(["Title": cal.title, "Visible": false])
        }
        else {
            cell.checkbox.setImage(UIImage(named: "checked"), for: .normal)
            cell.checked = true
            cell.backgroundColor = UIColor.green.withAlphaComponent(0.3)
            self.ref.child("Users/\(self.userID)/Calendars/").child(cal.ID).setValue(["Title": cal.title, "Visible": true])
        }
    }
    
    //CHECK IF WE HAVE ACCESS TO CALENDAR
    func checkCalendarAuthorizationStatus() {
        let status = EKEventStore.authorizationStatus(for: EKEntityType.event)
        
        switch (status) {
        case EKAuthorizationStatus.notDetermined:
            requestAccessToCalendar()
        case EKAuthorizationStatus.authorized:
            loadCalendars()
        case EKAuthorizationStatus.restricted, EKAuthorizationStatus.denied:
            requestCalendarPermissionAlert()
        }
    }
    
    
    //FIGURE OUT IF WE CAN LOAD CALENDARS OR ASK FOR ACCESS
    func requestAccessToCalendar() {
        eventStore.requestAccess(to: EKEntityType.event, completion: {
            (accessGranted: Bool, error: Error?) in
            
            if accessGranted == true {
                DispatchQueue.main.async(execute: {
                    self.loadCalendars()
                })
            } else {
                DispatchQueue.main.async(execute: {
                    self.requestCalendarPermissionAlert()
                })
            }
        })
    }
    
    //NOTIFICATION FOR CALENDAR ACCESS
    func requestCalendarPermissionAlert() {
        let alert = UIAlertController(title: "Heads up!", message: "PlanForMe needs access to your calendar in order to optimize your schedule. You can enable or disable access in Settings.", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: goToSettings))
        self.present(alert, animated: true, completion: nil)
    }
    
    //GO TO SETTINGS
    func goToSettings(alert: UIAlertAction!) {
        let openSettingsUrl = URL(string: UIApplicationOpenSettingsURLString)
        UIApplication.shared.open(openSettingsUrl!, options: [:], completionHandler: nil)
    }
    
    //LOAD TODAY'S EVENTS FROM CALENDAR
    func loadCalendars() {
        if notLoggedIn {
            let alert = UIAlertController(title: "Nothing to see here", message: "Sign in to choose visible calendars and save your preferences.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        print("LOADING IN CALENDARS")
        let input = eventStore.calendars(for: EKEntityType.event)
        calendars.removeAll()
        
        //CHECK PLANFORME CALENDAR
        self.ref.child("Users/\(userID)/").observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.hasChild("PlanForMeCalendar") {
                let value = (snapshot.childSnapshot(forPath: "PlanForMeCalendar/").value as? NSDictionary)!
                self.planForMeCalID = value["ID"] as! String
            }
        })
        
        //RECONCILE iOS CALENDARS WITH FIREBASE CALENDARS
        self.ref.child("Users/\(userID)/").observeSingleEvent(of: .value, with: { (snapshot) in
            if !snapshot.hasChild("Calendars"){
                //FIREBASE HAS NO CALENDARS PROPERTY
                for cal in input {
                    if cal.calendarIdentifier == self.planForMeCalID {
                        continue
                    }
                    //ADD EACH CALENDAR TO CALENDARS ARRAY AND TO FIREBASE AS VISIBLE
                    self.calendars.append(Cal(title: cal.title, ID: cal.calendarIdentifier, visible: true))
                    self.ref.child("Users/\(self.userID)/Calendars/").child(cal.calendarIdentifier).setValue(["Title": cal.title, "Visible": true])
                }
            }
            else {
                //FIREBASE HAS CALENDARS PROPERTY
                for cal in input {
                    if cal.calendarIdentifier == self.planForMeCalID {
                        continue
                    }
                    if snapshot.hasChild("Calendars/\(cal.calendarIdentifier)/") {
                        //CALENDAR IS IN FIREBASE -> ADD TO CALENDARS ARRAY
                        let value = (snapshot.childSnapshot(forPath: "Calendars/\(cal.calendarIdentifier)/").value as? NSDictionary)!
                        self.calendars.append(Cal(title: cal.title, ID: cal.calendarIdentifier, visible: value["Visible"] as! Bool))
                        self.ref.child("Users/\(self.userID)/Calendars/").child(cal.calendarIdentifier).setValue(["Title": value["Title"] as! String, "Visible": value["Visible"] as! Bool])
                    }
                    else {
                        //CALENDAR NOT IN FIREBASE -> ADD IN CALENDARS ARRAY AS VISIBLE, ADD TO FIREBASE AS VISIBLE
                        self.calendars.append(Cal(title: cal.title, ID: cal.calendarIdentifier, visible: true))
                        self.ref.child("Users/\(self.userID)/Calendars/").child(cal.calendarIdentifier).setValue(["Title": cal.title, "Visible": true])
                    }
                }
            }
            
            print("CALENDARS AFTER UPDATING")
            print(self.calendars)
            self.tableView.reloadData()
        })
    }
    

    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return false
    }
}
