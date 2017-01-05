//
//  TaskTableViewController.swift
//  PlanForMe
//
//  Created by Elizabeth Wei on 1/1/17.
//  Copyright © 2017 Elizabeth Wei. All rights reserved.
//

import UIKit
import EventKit

import Firebase
import FirebaseAuth
import FirebaseDatabase

import os.log

class TaskTableViewController: UITableViewController {
    
    var sections = ["All day", "Must do", "Would like to do", "Don't want to do"]
    var tasks = [[Task]]()
    var allDayIndex = 0
    var mustDoIndex = 1
    var wouldLikeIndex = 2
    var notDoingIndex = 3
    
    var ref: FIRDatabaseReference!
    
    //FIREBASE AUTH
    var userEmail = ""
    var userID = ""
    
    //CALENDAR
    let eventStore = EKEventStore()
    var calendars = [Cal]()
    var raw_calendars = [EKCalendar]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //UI SETUP
        navigationItem.leftBarButtonItem = editButtonItem
        
        //FIREBASE DATABASE SETUP
        ref = FIRDatabase.database().reference()
        userEmail = (FIRAuth.auth()?.currentUser?.email)!
        userID = (FIRAuth.auth()?.currentUser?.uid)!
        
        //LOAD IN EVENTS FROM CALENDARS
        self.refreshControl?.addTarget(self, action: #selector(handleRefresh(refreshControl:)), for: UIControlEvents.valueChanged)
        checkCalendarAuthorizationStatus()
    }
    
    func handleRefresh(refreshControl: UIRefreshControl) {
        checkCalendarAuthorizationStatus()
        self.tableView.reloadData()
        refreshControl.endRefreshing()
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
        raw_calendars = eventStore.calendars(for: EKEntityType.event)
        calendars.removeAll()
        
        //RECONCILE iOS CALENDARS WITH FIREBASE CALENDARS
        self.ref.child("Users/\(userID)/").observeSingleEvent(of: .value, with: { (snapshot) in
            if !snapshot.hasChild("Calendars"){
                 //FIREBASE HAS NO CALENDARS PROPERTY
                for cal in self.raw_calendars {
                    //ADD EACH CALENDAR TO CALENDARS ARRAY AND TO FIREBASE AS VISIBLE
                    self.calendars.append(Cal(title: cal.title, ID: cal.calendarIdentifier, visible: true))
                    self.ref.child("Users/\(self.userID)/Calendars/").child(cal.calendarIdentifier).setValue(["Title": cal.title, "Visible": true])
                }
            }
            else {
                //FIREBASE HAS CALENDARS PROPERTY 
                for cal in self.raw_calendars {
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
            
            self.tasks = [[], [], [], []]
            
            //LOAD IN TODAY'S EVENTS FROM VISIBLE CALENDARS IN CALENDARS ARRAY
            let startDate = Calendar.current.startOfDay(for: Date())
            var components = DateComponents()
            components.day = 1
            components.second = -1
            let endDate = Calendar.current.date(byAdding: components, to: startDate)!
            
            for cal in self.calendars {
                if cal.visible {
                    let raw_cal = self.raw_calendars.first(where: {$0.calendarIdentifier == cal.ID})!
                    let eventsPredicate = self.eventStore.predicateForEvents(withStart: startDate, end: endDate, calendars: [raw_cal])
                    let events = self.eventStore.events(matching: eventsPredicate).sorted(){
                        (e1: EKEvent, e2: EKEvent) -> Bool in
                        return e1.startDate.compare(e2.startDate) == ComparisonResult.orderedAscending
                    }
                    
                    for event in events {
                        if event.isAllDay {
                            self.tasks[self.allDayIndex].append(Task(name: event.title, calendarID: cal.ID, lowerTime: event.startDate, upperTime: event.endDate, event: event, color: UIColor(cgColor: raw_cal.cgColor)))
                        }
                        else {
                            self.tasks[self.wouldLikeIndex].append(Task(name: event.title, calendarID: cal.ID, lowerTime: event.startDate, upperTime: event.endDate, event: event, color: UIColor(cgColor: raw_cal.cgColor)))
                        }
                    }
                }
            }
            
            print(self.tasks)
            
            self.tableView.reloadData()
        })
    }
    
    //TURN DATE INTO STRING
    func getDisplayDate(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mm a"
        formatter.amSymbol = "AM"
        formatter.pmSymbol = "PM"
        formatter.timeZone = TimeZone.current
        return formatter.string(from: date)
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tasks.count == 0 {
            return 0
        }
        else {
            return tasks[section].count
        }
    }

    //FORMAT TASK CELLS
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "TaskTableViewCell"
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? TaskTableViewCell else {
            fatalError("Dequeued cell isn't an instance of TaskTableViewCell")
        }

        let task = tasks[indexPath.section][indexPath.row]
        
        //DISPLAY TASK NAME
        cell.nameLabel.text = task.name
        
        //DISPLAY TASK PRIORITY
        if indexPath.section == mustDoIndex {
            cell.priorityLabel.text = "❗️"
        }
        else {
            cell.priorityLabel.text = ""
        }
        
        //DISPLAY TASK CALENDAR INDICATOR
        cell.calendarView.backgroundColor = task.color.withAlphaComponent(0.5)

        //DISPLAY TASK TIME
        if !task.event.isAllDay {
            cell.timeLabel.text = getDisplayDate(date: task.lowerTime) + " to " + getDisplayDate(date: task.upperTime)
        }
        else {
            cell.timeLabel.text = ""
        }
        
        cell.selectionStyle = .none
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section]
    }
 
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return .none
    }
    
    override func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false 
    }
    
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let taskStartDate = tasks[indexPath.section][indexPath.row].event.startDate
        let interval = taskStartDate.timeIntervalSinceReferenceDate
        let openCalendarUrl = URL(string: "calshow:\(interval)")!
        UIApplication.shared.open(openCalendarUrl, options: [:], completionHandler: nil)
    }
    
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
        let itemToMove = tasks[fromIndexPath.section][fromIndexPath.row]
        tasks[fromIndexPath.section].remove(at: fromIndexPath.row)
        tasks[to.section].insert(itemToMove, at: to.row)
    }
    
    override func tableView(_ tableView: UITableView, targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath, toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath {
        let task = tasks[sourceIndexPath.section][sourceIndexPath.row]
        
        if task.event.isAllDay {
            //CAN ONLY MOVE TO ALL DAY OR NOT DOING
            if sourceIndexPath.section == allDayIndex && proposedDestinationIndexPath.section != notDoingIndex {
                return IndexPath(row: tasks[allDayIndex].count-1, section: allDayIndex)
            }
            else if sourceIndexPath.section == notDoingIndex && proposedDestinationIndexPath.section != allDayIndex {
                return IndexPath(row: 0, section: notDoingIndex)
            }
            else {
                return proposedDestinationIndexPath
            }
        }
        else {
            //CAN'T MOVE TO ALL DAY
            if proposedDestinationIndexPath.section == allDayIndex {
                return IndexPath(row: 0, section: sourceIndexPath.section)
            }
            else {
                return proposedDestinationIndexPath
            }
        }
    }
}
