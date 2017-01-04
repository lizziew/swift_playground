//
//  TaskTableViewController.swift
//  PlanForMe
//
//  Created by Elizabeth Wei on 1/1/17.
//  Copyright © 2017 Elizabeth Wei. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import os.log

class TaskTableViewController: UITableViewController {
    
    var sections = ["Must do", "Would like to do"]
    var tasks = [[Task]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(FIRAuth.auth()?.currentUser?.email)
        
        navigationItem.leftBarButtonItem = editButtonItem
        
        loadTasks()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks[section].count
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
    
    //UNWIND FROM ADD TASK TO TASK LIST
    @IBAction func unwindToTaskList(sender: UIStoryboardSegue) {
        if let sourceViewController = sender.source as? AddViewController, let task = sourceViewController.task {
            if let selectedIndexPath = tableView.indexPathForSelectedRow {
                //EDIT EXISTING TASK
                if task.priority == 1 && selectedIndexPath.section == 0 {
                    //TASK HAS BEEN DEMOTED
                    
                    //REMOVE FROM SECTION 0
                    tasks[0].remove(at: selectedIndexPath.row)
                    tableView.deleteRows(at: [selectedIndexPath], with: .fade)
                    
                    //ADD TO SECTION 1
                    let newIndexPath = IndexPath(row: tasks[1].count, section: 1)
                    tasks[1].append(task)
                    tableView.insertRows(at: [newIndexPath], with: .automatic)
                }
                else if task.priority == 2 && selectedIndexPath.section == 1 {
                    //TASK HAS BEEN PROMOTED
                    
                    //REMOVE FROM SECTION 1
                    tasks[1].remove(at: selectedIndexPath.row)
                    tableView.deleteRows(at: [selectedIndexPath], with: .fade)
                    
                    //ADD TO SECTION 0
                    let newIndexPath = IndexPath(row: tasks[0].count, section: 0)
                    tasks[0].append(task)
                    tableView.insertRows(at: [newIndexPath], with: .automatic)
                }
                else {
                    //EDITED TASK HAS SAME PRIORITY
                    tasks[selectedIndexPath.section][selectedIndexPath.row] = task
                    tableView.reloadRows(at: [selectedIndexPath], with: .none)
                }
            }
            else {
                //ADD NEW TASK
                let section = sections.count - task.priority
                
                let newIndexPath = IndexPath(row: tasks[section].count, section: section)
                tasks[section].append(task)
                
                tableView.insertRows(at: [newIndexPath], with: .automatic)
            }
        }
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
    
    //SWITCHES FROM TASK LIST TO EITHER ADD TASK OR EDIT TASK
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        switch(segue.identifier ?? "") {
        case "AddItem":
            os_log("Adding a new task", log: OSLog.default, type: .debug)
        case "ShowDetail":
            guard let taskDetailViewController = segue.destination as? AddViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            
            guard let selectedTaskCell = sender as? TaskTableViewCell else {
                fatalError("Unexpected sender: \(sender)")
            }
            
            guard let indexPath = tableView.indexPath(for: selectedTaskCell) else {
                fatalError("The selected cell is not being displayed by the table")
            }
            
            let selectedTask = tasks[indexPath.section][indexPath.row]
            taskDetailViewController.task = selectedTask
        default:
            fatalError("Unexpected segue identifier: \(segue.identifier)") 
        }
    }

    //DISPLAY LIST OF TASKS
    private func loadTasks() {
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
