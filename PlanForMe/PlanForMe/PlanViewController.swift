//
//  PlanViewController.swift
//  PlanForMe
//
//  Created by Elizabeth Wei on 1/1/17.
//  Copyright © 2017 Elizabeth Wei. All rights reserved.
//

import UIKit

class PlanViewController : UIViewController, UITableViewDelegate, UITableViewDataSource {
    var tasks = [[Task]]()
    var overlapTasks = [Task]()
    var optTasks = [Task]()
    
    var p = [Int]()
    var m = [Int]()
    var optIntervals = [Interval]()
    
    var allDayIndex = 0
    var mustDoIndex = 1
    var wouldLikeIndex = 2
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var importButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        
        //FORMAT IMPORT CALENDARS BUTTON
        importButton.backgroundColor = UIColor(red: 74.0/255.0, green: 139.0/255.0, blue: 244.0/255.0, alpha: 1.0)
        importButton.layer.masksToBounds = false
        importButton.layer.cornerRadius = 3
        importButton.layer.shadowOffset = CGSize(width: 1.5, height: 1.5)
        importButton.layer.shadowRadius = 0.4
        importButton.layer.shadowOpacity = 1.0
        importButton.layer.shadowColor = UIColor.lightGray.cgColor
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //GET TASKS FROM TASK LIST IN TODAY TAB
        if let taskTableViewController = self.tabBarController?.viewControllers?[0].childViewControllers[0] as? TaskTableViewController {
            tasks = taskTableViewController.tasks
            displayTasks(scheduleTasks())
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return optTasks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:UITableViewCell = self.tableView.dequeueReusableCell(withIdentifier: "eventCell")! as UITableViewCell
        
        let task = optTasks[indexPath.row]
        cell.textLabel?.text = task.name
        
        cell.contentView.backgroundColor = UIColor.clear
        
        let whiteRoundedView : UIView = UIView(frame: CGRect(x: 0, y: 10, width: self.view.frame.size.width, height: 70))
        
        whiteRoundedView.layer.backgroundColor = CGColor(colorSpace: CGColorSpaceCreateDeviceRGB(), components: [1.0, 1.0, 1.0, 1.0])
        whiteRoundedView.layer.masksToBounds = false
        whiteRoundedView.layer.shadowOffset = CGSize(width: -2, height: 2)
        whiteRoundedView.layer.shadowOpacity = 0.3
        
        whiteRoundedView.layer.shadowColor = task.color.darker(by: 30)?.cgColor
        whiteRoundedView.layer.borderColor = UIColor.darkGray.cgColor
        
        cell.contentView.addSubview(whiteRoundedView)
        cell.contentView.sendSubview(toBack: whiteRoundedView)
        
        cell.selectionStyle = .none
        
        if task.event.isAllDay {
            cell.detailTextLabel?.text = "All day"
            whiteRoundedView.layer.cornerRadius = 2.0
        }
        else {
            cell.detailTextLabel?.text = getDisplayDate(date: task.lowerTime) + " to " + getDisplayDate(date: task.upperTime)
            whiteRoundedView.layer.cornerRadius = 20.0
        }
        
        return cell
    }
    
//    func getCellHeight(_ task: Task) -> CGFloat {
//        if task.event.isAllDay {
//            return 90.0
//        }
//        
//        let interval = task.upperTime.timeIntervalSince(task.lowerTime)
//        let height = (CGFloat(interval) / 86400.0) * 1440.0
//        
//        if height < 90.0 {
//            return 90.0
//        }
//        else {
//            return height
//        }
//    }
//    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90.0 
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let taskStartDate = optTasks[indexPath.row].event.startDate
        let interval = taskStartDate.timeIntervalSinceReferenceDate
        let openCalendarUrl = URL(string: "calshow:\(interval)")!
        UIApplication.shared.open(openCalendarUrl, options: [:], completionHandler: nil)
    }
    
    //DISPLAY TASKS AFTER THEY'RE SCHEDULED
    func displayTasks(_ tasks: [Task]?) {
        if tasks == nil {
            if overlapTasks.count == 0 {
                showAlert("You have nothing planned for today: add a task you want to do or enjoy your day off :)")
                return
            }
            
            //DISPLAY OVERLAP TASKS
            let t1 = overlapTasks[0]
            let t2 = overlapTasks[1]
            
            showAlert("Your 'must do' tasks " + t1.name + " and " + t2.name + " overlap! Please reschedule or delete at least one of the tasks.")
        }
        else {
            var taskText = "Your plan is \n"
            for task in tasks! {
                taskText.append(getDisplayDate(date: task.lowerTime) + " to " + getDisplayDate(date: task.upperTime) + ": " + task.name + "\n")
            }
            print(taskText)
            if tasks != nil {
                optTasks = tasks!
                self.tableView.reloadData()
            }
        }
    }
    
    func showAlert(_ msg: String) {
        let alert = UIAlertController(title: "Heads up!", message: msg, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
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
    
    //SCHEDULE TASKS
    func scheduleTasks() -> [Task]? {
        if tasks.count == 0 || (tasks[0].count == 0 && tasks[1].count == 0 && tasks[2].count == 0){
            return nil
        }
        
        //SORT 'MUST DO' TASKS BY START TIME
        tasks[mustDoIndex] = tasks[mustDoIndex].sorted(by: { $0.lowerTime < $1.lowerTime })
        
        if mustDoIsValid(tasks[mustDoIndex]) {
            //SCHEDULE IN 'ALL DAY' AND 'MUST DO' TASKS
            var scheduledTasks = tasks[mustDoIndex] + tasks[allDayIndex]
            
            //CONVERT 'WOULD LIKE TO DO' TASKS TO INTERVALS, FILTER OUT ALL 'WOULD LIKE TO DO' TASKS THAT CONFLICT WITH 'MUST DO' TASK(S)
            let intervals = tasksToIntervals(mustDos: tasks[mustDoIndex], wouldLikes: tasks[wouldLikeIndex])
            
            //WEIGHTED INTERVAL SCHEDULING (DP) --> optIntervals
            weightedIntervalSchedule(intervals)
            
            //LOG OPTIMAL INTERVALS
            print(optIntervals)
            
            for interval in optIntervals {
                scheduledTasks.append(tasks[wouldLikeIndex][interval.index])
            }
            
            return scheduledTasks.sorted(by: { $0.lowerTime < $1.lowerTime })
        }
        else {
            return nil
        }
    }
    
    //WEIGHTED INTERVAL SCHEDULING (DP)
    func weightedIntervalSchedule(_ input: [Interval]) {
        if input.count == 0 {
            return 
        }
        
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
        else if intervals[i].weight > m[i-1] {
            optIntervals.append(intervals[i])
            findOptIntervals(i-1, intervals: intervals)
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
        if input.count == 0 {
            return true 
        }
        
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
}

extension UIColor {
    
    func lighter(by percentage:CGFloat=30.0) -> UIColor? {
        return self.adjust(by: abs(percentage) )
    }
    
    func darker(by percentage:CGFloat=30.0) -> UIColor? {
        return self.adjust(by: -1 * abs(percentage) )
    }
    
    func adjust(by percentage:CGFloat=30.0) -> UIColor? {
        var r:CGFloat=0, g:CGFloat=0, b:CGFloat=0, a:CGFloat=0;
        if(self.getRed(&r, green: &g, blue: &b, alpha: &a)){
            return UIColor(red: min(r + percentage/100, 1.0),
                           green: min(g + percentage/100, 1.0),
                           blue: min(b + percentage/100, 1.0),
                           alpha: a)
        }else{
            return nil
        }
    }
}

