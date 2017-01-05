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
    
    var sections = ["Must do", "Would like to do"]
    var tasks = [[Task]]()
    
    var ref: FIRDatabaseReference!
    
    //FIREBASE AUTH
    var userEmail = ""
    var userID = ""
    
    //CALENDAR
    let eventStore = EKEventStore()
    var calendars = [Calendar]()
    
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
        })
        
        //TODO: LOAD IN EVENTS FROM CALENDARS IN CALENDARS ARRAY
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
        switch task.priority {
        case 2:
            cell.priorityLabel.text = "❗️"
        default:
            cell.priorityLabel.text = ""
        }
        
        //DISPLAY TASK TIME
        cell.timeLabel.text = valueToTime(task.lowerTime) + " to " + valueToTime(task.upperTime)

        return cell
    }
    
    func getDictOfTasks() -> [[String: Any]] {
        var dictOfTasks = [[String: Any]]()
        for section in tasks {
            for t in section {
                let t = ["name": t.name,
                         "priority": t.priority,
                         "lowerTime": t.lowerTime,
                         "upperTime": t.upperTime] as [String : Any]
                dictOfTasks.append(t)
            }
        }
        return dictOfTasks
    }
    
    //SECTION TITLE
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section]
    }
 
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            tasks[indexPath.section].remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            
            //UPDATE TASKS IN FIREBASE DATABASE
            ref.child("Users/\(userID)/Tasks").setValue(getDictOfTasks())     
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }

    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
        let itemToMove = tasks[fromIndexPath.section][fromIndexPath.row]
        tasks[fromIndexPath.section].remove(at: fromIndexPath.row)
        tasks[fromIndexPath.section].insert(itemToMove, at: to.row)
    }

    //Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
         return true
    }
    
    override func tableView(_ tableView: UITableView, targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath, toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath {
        if sourceIndexPath.section != proposedDestinationIndexPath.section {
            var row = 0;
            if sourceIndexPath.section < proposedDestinationIndexPath.section {
                row = tableView.numberOfRows(inSection: sourceIndexPath.section) - 1
            }
            return IndexPath(row: row, section: sourceIndexPath.section)
        }
        
        return proposedDestinationIndexPath
    }

    //LOAD TASKS FROM FIREBASE
    private func loadTasks() {
        tasks = [[], []]
        
        ref.child("Users/\(userID)").child("Tasks").observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.value == nil {
                return
            }
            let value = (snapshot.value as? NSArray)!
        
            for i in 0..<value.count {
                if let item = value[i] as? [String: Any] {
                    let name = item["name"] as! String
                    let priority = item["priority"] as! Int
                    let lowerTime = item["lowerTime"] as! Double
                    let upperTime = item["upperTime"] as! Double
                    let t = Task(name: name, priority: priority, lowerTime: lowerTime, upperTime: upperTime)
                    if priority == 2 {
                        self.tasks[0].append(t!)
                    }
                    else {
                        self.tasks[1].append(t!)
                    }
                }
            }
            
            self.tableView.reloadData()
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    //TEST FUNCTION 
    private func loadExampleTasks() {
        guard let task1 = Task(name: "Math class", priority: 1, lowerTime: 11, upperTime: 13) else {
            fatalError("Unable to instantiate task")
        }

        guard let task2 = Task(name: "Soccer practice", priority: 2, lowerTime: 17, upperTime: 19) else {
            fatalError("Unable to instantiate task")
        }

        guard let task3 = Task(name: "Breakfast", priority: 1, lowerTime: 8, upperTime: 9) else {
            fatalError("Unable to instantiate task")
        }

        guard let task4 = Task(name: "test", priority: 1, lowerTime: 9, upperTime: 16.5) else {
            fatalError("Unable to instantiate task")
        }
        
        tasks += [[task2], [task4, task1, task3]]
    }
    
    //CONVERT TIME VALUE TO DISPLAY TIME
    private func valueToTime(_ input: Double) -> String {
        let value = round(input * 2.0) / 2.0
        
        if value < 1 {
            if value == 0 {
                return "12 AM"
            }
            else {
                return "12:30 AM"
            }
        }
        else if value == 24 {
            return "12 AM"
        }
        else if value == 12 {
            return "12 PM"
        }
        else if value == 12.5 {
            return "12:30 PM"
        }
        else if value > 12 {
            if value == floor(value) {
                return String(Int(value) - 12) + " PM"
            }
            else {
                return String(Int(value) - 12) + ":30 PM"
            }
        }
        else {
            if value == floor(value) {
                return String(Int(value)) + " AM"
            }
            else {
                return String(Int(value)) + ":30 AM"
            }
        }
    }
}
