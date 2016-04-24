//
//  PinTableViewController.swift
//  ElizabethWei
//
//  Created by Elizabeth Wei on 4/23/16.
//  Copyright © 2016 Elizabeth Wei. All rights reserved.
//

import UIKit
import CloudKit

class PinTableViewController: UITableViewController {
    
    var pins = [CKRecord]()
    
    var refresh:UIRefreshControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = editButtonItem()
        
        refresh = UIRefreshControl()
        refresh.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refresh.addTarget(self, action: #selector(PinTableViewController.loadPins), forControlEvents: .ValueChanged)
        self.tableView.addSubview(refresh)
        
        loadPins()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pins.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellIdentifier = "PinTableViewCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! PinTableViewCell
        
        if pins.count == 0 {
            return cell
        }
        
        let pin = pins[indexPath.row]
        
        if let pinName = pin["name"] as? String {
            cell.LocationLabel.text = pinName
        }
        
        if let startPinDate = pin["startDate"] as? NSDate, endPinDate = pin["endDate"] as? NSDate {
            let formatter = NSDateFormatter()
            formatter.dateFormat = "MMMM dd, YYYY"
            
            cell.DateLabel.text = formatter.stringFromDate(startPinDate) + " to " + formatter.stringFromDate(endPinDate)
        }
        
        return cell
    }
    
    @IBAction func unwindToPinList(sender: UIStoryboardSegue) {
        if let sourceViewController = sender.sourceViewController as? PinViewController, pin = sourceViewController.pin {
            
            if let selectedIndexPath = tableView.indexPathForSelectedRow {
                modifyPin(pin, selectedIndexPath: selectedIndexPath, recordID: pins[selectedIndexPath.row].recordID)
            }
            else {
                addPin(pin)
            }
        }
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }

    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            pins.removeAtIndex(indexPath.row)
            //savePins()
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowDetail" {
            let pinDetailViewController = segue.destinationViewController as! PinViewController
            if let selectedPinCell = sender as? PinTableViewCell {
                let indexPath = tableView.indexPathForCell(selectedPinCell)!
                let pin = pins[indexPath.row]
                pinDetailViewController.pin = Pin(name: (pin["name"] as? String)!, location: (pin["location"] as? CLLocation)!, startDate: (pin["startDate"] as? NSDate)!, endDate: (pin["endDate"] as? NSDate)!)
            }
        }
        else if segue.identifier == "AddItem" {
            print("Adding new pin.")
        }
    }
    
    func addPin(pin: Pin) {
        let newPin = CKRecord(recordType: "Pin")
        newPin.setValue(pin.name, forKey: "name")
        newPin.setValue(pin.location, forKey: "location")
        newPin.setValue(pin.startDate, forKey: "startDate")
        newPin.setValue(pin.endDate, forKey: "endDate")
        
        let publicData = CKContainer.defaultContainer().publicCloudDatabase
        publicData.saveRecord(newPin) { (record: CKRecord?, error: NSError?) in
            if error == nil {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.tableView.beginUpdates()
                    let indexPath = NSIndexPath(forRow: self.pins.count, inSection: 0)
                    self.pins.append(newPin)
                    self.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Bottom)
                    self.tableView.endUpdates()
                })
            }
            else {
                print(error)
            }
        }
    }
    
    func modifyPin(pin: Pin, selectedIndexPath: NSIndexPath, recordID: CKRecordID) {
        let publicData = CKContainer.defaultContainer().publicCloudDatabase
        publicData.fetchRecordWithID(recordID) { (record: CKRecord?, error: NSError?) in
            if error != nil {
                print(error)
            }
            else {
                record!["name"] = pin.name
                record!["location"] = pin.location
                record!["startDate"] = pin.startDate
                record!["endDate"] = pin.endDate
                publicData.saveRecord(record!) { (record: CKRecord?, error: NSError?) in
                    if error == nil {
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            self.tableView.beginUpdates()
                            self.pins[selectedIndexPath.row] = record!
                            self.tableView.reloadRowsAtIndexPaths([selectedIndexPath], withRowAnimation: .None)
                            self.tableView.endUpdates()
                        })
                    }
                    else {
                        print(error)
                    }
                }
            }
        }
    }
    
    func loadPins() {
        let publicData = CKContainer.defaultContainer().publicCloudDatabase
        let query = CKQuery(recordType: "Pin", predicate: NSPredicate(format: "TRUEPREDICATE", argumentArray: nil))
        
        publicData.performQuery(query, inZoneWithID: nil) { (results: [CKRecord]?, error: NSError?) in
            if let cloudPins = results {
                self.pins = cloudPins
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.tableView.reloadData()
                    self.refresh.endRefreshing()
                })
            }
        }
    }
}