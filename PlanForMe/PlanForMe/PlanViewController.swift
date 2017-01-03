//
//  PlanViewController.swift
//  PlanForMe
//
//  Created by Elizabeth Wei on 1/1/17.
//  Copyright © 2017 Elizabeth Wei. All rights reserved.
//

import UIKit

class PlanViewController : UIViewController {
    var tasks = [[Task]]()
    var overlapTasks = [Task]()
    @IBOutlet weak var scheduleLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //GET TASKS FROM TASK LIST IN TODAY TAB
        if let taskTableViewController = self.tabBarController?.viewControllers?[0].childViewControllers[0] as? TaskTableViewController {
            tasks = taskTableViewController.tasks
        }
        
        displayTasks(scheduleTasks())
    }
    
    //DISPLAY TASKS AFTER THEY'RE SCHEDULED
    func displayTasks(_ tasks: [Task]?) {
        if tasks == nil {
            //DISPLAY OVERLAP TASKS
            let t1 = overlapTasks[0]
            let t2 = overlapTasks[1]
            scheduleLabel.numberOfLines = 0
            scheduleLabel.text = "Your 'must do' tasks " + t1.name + " and " + t2.name + " overlap! Please reschedule or delete at least one of the tasks."
        }
        else {
            var taskText = "Your plan is \n"
            for task in tasks! {
                taskText.append(valueToTime(task.lowerTime) + " to " + valueToTime(task.upperTime) + ": " + task.name + "\n")
            }
            
            scheduleLabel.text = taskText
        }
    }
    
    //SCHEDULE TASKS
    func scheduleTasks() -> [Task]? {
        //SORT TASKS BY START TIME
        for i in 0..<tasks.count {
            tasks[i] = tasks[i].sorted(by: { $0.lowerTime < $1.lowerTime })
        }
        
        if mustDoIsValid(tasks[0]) {
            //SORT 'WOULD LIKE TO DO' TASKS
            var scheduledTasks = tasks[0]
            
            //TBD: WEIGHTED INTERVAL SCHEDULING WITH 'WOULD LIKE TO DO TASKS'
            
            return scheduledTasks
        }
        else {
            return nil
        }
    }
    
    //CHECK IF ANY 'MUST DO' TASKS OVERLAP
    func mustDoIsValid(_ input: [Task]) -> Bool {
        //let sorted_input = input.sorted(by: { $0.lowerTime < $1.lowerTime })
        for i in 0..<input.count-1 {
            if overlap(input[i], input[i+1]) {
                overlapTasks = [input[i], input[i+1]]
                return false
            }
        }
        return true
    }
    
    //CHECK IF 2 TASKS OVERLAP
    func overlap(_ t1: Task, _ t2: Task) -> Bool {
        return t1.upperTime > t2.lowerTime && t2.upperTime > t1.lowerTime
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

