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
    
    var givenName: String? = nil
    
    var familyName: String? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = editButtonItem()
        navigationItem.leftBarButtonItem?.tintColor = UIColor.whiteColor() 
        
        refresh = UIRefreshControl()
        refresh.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refresh.addTarget(self, action: #selector(PinTableViewController.loadPins), forControlEvents: .ValueChanged)
        self.tableView.addSubview(refresh)
        
        loadPins()
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
            deletePin(indexPath, recordID: pins[indexPath.row].recordID)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowDetail" {
            let pinDetailViewController = segue.destinationViewController as! PinViewController
            if let selectedPinCell = sender as? PinTableViewCell {
                let indexPath = tableView.indexPathForCell(selectedPinCell)!
                let pin = pins[indexPath.row]
                pinDetailViewController.pin = Pin(name: (pin["name"] as? String)!, location: (pin["location"] as? CLLocation)!, startDate: (pin["startDate"] as? NSDate)!, endDate: (pin["endDate"] as? NSDate)!, phoneNumber: (pin["phoneNumber"] as? String)!)
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
        newPin.setValue(givenName, forKey: "givenName")
        newPin.setValue(familyName, forKey: "familyName")
        newPin.setValue(pin.phoneNumber, forKey: "phoneNumber")
        
        let publicData = CKContainer.defaultContainer().publicCloudDatabase
        publicData.saveRecord(newPin) { (record: CKRecord?, error: NSError?) in
            if error == nil {
                print("successfully saved to public database")
            }
            else {
                print(error)
            }
        }
        
        let privateData = CKContainer.defaultContainer().privateCloudDatabase
        privateData.saveRecord(newPin) { (record: CKRecord?, error: NSError?) in
            if error == nil {
                print("successfully saved to private database")
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
                record!["givenName"] = self.givenName
                record!["familyName"] = self.familyName
                record!["phoneNumber"] = pin.phoneNumber
                publicData.saveRecord(record!) { (record: CKRecord?, error: NSError?) in
                    if error == nil {
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            print("successfully modified public database")
                        })
                    }
                    else {
                        print(error)
                    }
                }
            }
        }
        
        let privateData = CKContainer.defaultContainer().privateCloudDatabase
        privateData.fetchRecordWithID(recordID) { (record: CKRecord?, error: NSError?) in
            if error != nil {
                print(error)
            }
            else {
                record!["name"] = pin.name
                record!["location"] = pin.location
                record!["startDate"] = pin.startDate
                record!["endDate"] = pin.endDate
                privateData.saveRecord(record!) { (record: CKRecord?, error: NSError?) in
                    if error == nil {
                        print("successfully modified private database")
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
    
    func deletePin(indexPath: NSIndexPath, recordID: CKRecordID) {
        let publicData = CKContainer.defaultContainer().publicCloudDatabase
        publicData.deleteRecordWithID(recordID) { (record: CKRecordID?, error: NSError?) in
            if error != nil {
                print(error)
            }
            else {
                print("successfully deleted from public database")
            }
        }
        
        let privateData = CKContainer.defaultContainer().privateCloudDatabase
        privateData.deleteRecordWithID(recordID) { (record: CKRecordID?, error: NSError?) in
            if error != nil {
                print(error)
            }
            else {
                print("successfully deleted from private database")
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.tableView.beginUpdates()
                    self.pins.removeAtIndex(indexPath.row)
                    self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
                    self.tableView.endUpdates()
                })
            }
        }
    }
    
    func loadPins() {
        let privateData = CKContainer.defaultContainer().privateCloudDatabase
        let query = CKQuery(recordType: "Pin", predicate: NSPredicate(format: "TRUEPREDICATE", argumentArray: nil))
        
        privateData.performQuery(query, inZoneWithID: nil) { (results: [CKRecord]?, error: NSError?) in
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