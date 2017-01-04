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
    
    var p = [Int]()
    var m = [Int]()
    var optIntervals = [Interval]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //GET TASKS FROM TASK LIST IN TODAY TAB
        if let taskTableViewController = self.tabBarController?.viewControllers?[0].childViewControllers[0] as? TaskTableViewController {
            tasks = taskTableViewController.tasks
            displayTasks(scheduleTasks())
        }
    }
    
    //DISPLAY TASKS AFTER THEY'RE SCHEDULED
    func displayTasks(_ tasks: [Task]?) {
        if tasks == nil {
            if overlapTasks.count == 0 {
                scheduleLabel.text = "You have nothing planned for today! Add an event or enjoy your day off :)"
                return
            }
            
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
        if tasks.count == 0 {
            return nil
        }
        
        //SORT 'MUST DO' TASKS BY START TIME
        tasks[0] = tasks[0].sorted(by: { $0.lowerTime < $1.lowerTime })
        
        if mustDoIsValid(tasks[0]) {
            //SORT 'WOULD LIKE TO DO' TASKS
            var scheduledTasks = tasks[0]
            
            //CONVERT 'WOULD LIKE TO DO' TASKS TO INTERVALS, FILTER OUT ALL 'WOULD LIKE TO DO' TASKS THAT CONFLICT WITH 'MUST DO' TASK(S)
            let intervals = tasksToIntervals(mustDos: tasks[0], wouldLikes: tasks[1])
            
            //WEIGHTED INTERVAL SCHEDULING (DP) --> optIntervals
            weightedIntervalSchedule(intervals)
            
            //LOG OPTIMAL INTERVALS
            print(optIntervals)
            
            for interval in optIntervals {
                scheduledTasks.append(tasks[1][interval.index])
            }
            
            return scheduledTasks.sorted(by: { $0.lowerTime < $1.lowerTime })
        }
        else {
            return nil
        }
    }
    
    //WEIGHTED INTERVAL SCHEDULING (DP)
    func weightedIntervalSchedule(_ input: [Interval]) {
        //SORT TASKS BY FINISH TIME (MONOTONICALLY INCREASING ORDER) 
        var sorted_input = input.sorted(by: {$0.finish < $1.finish})
        p = [Int](repeating: -1, count: sorted_input.count)
        m = [Int](repeating: 0, count: sorted_input.count)
        
        for i in 1..<p.count {
            p[i] = computeMaxCompatibleIndex(i, sorted_input)
        }
        
        m[0] = sorted_input[0].weight
        for i in 1..<m.count {
            if p[i] == -1 {
                m[i] = max(sorted_input[i].weight, m[i-1])
            }
            else {
                m[i] = max(sorted_input[i].weight + m[p[i]], m[i-1])
            }
        }
        
        //LOG OPTIMAL VALUE
        print(m[m.count-1])
        
        optIntervals.removeAll()
        findOptIntervals(m.count-1, intervals: sorted_input)
    }
    
    //GET THE OPTIMAL INTERVALS THAT MAKE UP OPTIMAL SOLUTION
    func findOptIntervals(_ i: Int, intervals: [Interval]) {
        if i == 0 {
            if intervals.count <= 1 || !overlap(intervals[0], intervals[1]){
                optIntervals.append(intervals[0])
            }
            return
        }
        else if p[i] != -1 && intervals[i].weight + m[p[i]] > m[i-1] {
            optIntervals.append(intervals[i])
            findOptIntervals(p[i], intervals: intervals)
        }
        else {
            findOptIntervals(i-1, intervals: intervals)
        }
    }
    
    //BINARY SEARCH TO FIND MAX INDEX FROM [0, i-1] THAT'S COMPATIBLE WITH REQUEST i
    func computeMaxCompatibleIndex(_ i: Int, _ intervals: [Interval]) -> Int {
        var low = 0
        var high = i-1
        
        var j = -1
        
        while low <= high {
            let mid = low + (high - low)/2
            
            if !overlap(intervals[mid], intervals[i]) {
                j = mid
                //SEARCH [mid+1, high]
                low = mid+1
            }
            else {
                //SEARCH [low, mid-1]
                high = mid-1
            }
        }
        
        return j
    }
    
    //CONVERT 'WOULD LIKE TO DO' TASKS TO INTERVALS, FILTER OUT ALL 'WOULD LIKE TO DO' TASKS THAT CONFLICT WITH 'MUST DO' TASK(S)
    func tasksToIntervals(mustDos: [Task], wouldLikes: [Task]) -> [Interval] {
        var intervals = [Interval]()
        
        var weight = 3
        
        for i in (0..<wouldLikes.count).reversed()  {
            let wouldLikeTask = wouldLikes[i]
            
            //CHECK IF 'WOULD LIKE TO DO' TASK CONFLICTS WITH ANY 'MUST DO' TASK
            var isValidTask = true
            for mustDoTask in mustDos {
                if overlap(wouldLikeTask, mustDoTask) {
                    isValidTask = false
                    break
                }
            }
            
            //CONVERT 'WOULD LIKE TO DO' TASK TO INTERVAL
            if isValidTask {
                intervals.append(Interval(weight: weight, index: i, start: wouldLikeTask.lowerTime, finish: wouldLikeTask.upperTime))
                weight += 3
            }
        }
        
        return intervals
    }
    
    //CHECK IF ANY 'MUST DO' TASKS OVERLAP
    func mustDoIsValid(_ input: [Task]) -> Bool {
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
    
    //CHECK IF 2 INTERVALS OVERLAP
    func overlap(_ t1: Interval, _ t2: Interval) -> Bool {
        return t1.finish > t2.start && t2.finish > t1.start
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

