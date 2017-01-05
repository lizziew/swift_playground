//
//  CalendarSettingsTableViewController.swift
//  
//
//  Created by Elizabeth Wei on 1/4/17.
//
//

import UIKit
import EventKit

import Firebase
import FirebaseAuth
import FirebaseDatabase

class CalendarSettingsTableViewController: UITableViewController {

    let eventStore = EKEventStore()
    var calendars = [Calendar]()
    
    //FIREBASE DATABASE
    var ref: FIRDatabaseReference!
    var userID = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //FIREBASE DATABASE SETUP
        ref = FIRDatabase.database().reference()
        userID = (FIRAuth.auth()?.currentUser?.uid)!
        
        //LOAD IN CALENDARS
        self.refreshControl?.addTarget(self, action: #selector(handleRefresh(refreshControl:)), for: UIControlEvents.valueChanged)
        checkCalendarAuthorizationStatus()
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
            cell.checkbox.setTitle("✅", for: .normal)
            cell.checked = true
        }
        else {
            cell.backgroundColor = UIColor.red.withAlphaComponent(0.3)
            cell.checkbox.setTitle("❌", for: .normal)
            cell.checked = true
        }
        
        cell.tapAction = { (cell) in
            self.toggleCalendar(cell, self.calendars[indexPath.row])
        }

        return cell
    }
    
    func toggleCalendar(_ cell: CalendarTableViewCell, _ cal: Calendar) {
        if cell.checkbox.titleLabel?.text == "✅" {
            cell.checkbox.setTitle("❌", for: .normal)
            cell.checked = false
            cell.backgroundColor = UIColor.red.withAlphaComponent(0.3)
            self.ref.child("Users/\(self.userID)/Calendars/").child(cal.ID).setValue(["Title": cal.title, "Visible": false])
        }
        else {
            cell.checkbox.setTitle("✅", for: .normal)
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
        let alert = UIAlertController(title: "Alert", message: "PlanForMe needs access to your calendar in order to optimize your schedule. You can enable or disable access in Settings.", preferredStyle: UIAlertControllerStyle.alert)
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
        print("LOADING IN CALENDARS")
        let input = eventStore.calendars(for: EKEntityType.event)
        calendars.removeAll()
        
        //RECONCILE iOS CALENDARS WITH FIREBASE CALENDARS
        self.ref.child("Users/\(userID)/").observeSingleEvent(of: .value, with: { (snapshot) in
            if !snapshot.hasChild("Calendars"){
                //FIREBASE HAS NO CALENDARS PROPERTY
                for cal in input {
                    //ADD EACH CALENDAR TO CALENDARS ARRAY AND TO FIREBASE AS VISIBLE
                    self.calendars.append(Calendar(title: cal.title, ID: cal.calendarIdentifier, visible: true))
                    self.ref.child("Users/\(self.userID)/Calendars/").child(cal.calendarIdentifier).setValue(["Title": cal.title, "Visible": true])
                }
            }
            else {
                //FIREBASE HAS CALENDARS PROPERTY
                for cal in input {
                    if snapshot.hasChild("Calendars/\(cal.calendarIdentifier)/") {
                        //CALENDAR IS IN FIREBASE -> ADD TO CALENDARS ARRAY
                        let value = (snapshot.childSnapshot(forPath: "Calendars/\(cal.calendarIdentifier)/").value as? NSDictionary)!
                        self.calendars.append(Calendar(title: cal.title, ID: cal.calendarIdentifier, visible: value["Visible"] as! Bool))
                        self.ref.child("Users/\(self.userID)/Calendars/").child(cal.calendarIdentifier).setValue(["Title": value["Title"] as! String, "Visible": value["Visible"] as! Bool])
                    }
                    else {
                        //CALENDAR NOT IN FIREBASE -> ADD IN CALENDARS ARRAY AS VISIBLE, ADD TO FIREBASE AS VISIBLE
                        self.calendars.append(Calendar(title: cal.title, ID: cal.calendarIdentifier, visible: true))
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
