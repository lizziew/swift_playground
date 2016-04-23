//
//  PinTableViewController.swift
//  ElizabethWei
//
//  Created by Elizabeth Wei on 4/23/16.
//  Copyright © 2016 Elizabeth Wei. All rights reserved.
//

import UIKit

class PinTableViewController: UITableViewController {
    
    var pins = [Pin]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = editButtonItem()
        if let savedPins = loadPins() {
            pins += savedPins
        }
        else {
            loadSamplePins()
        }
    }
    
    func loadSamplePins() {
        let pin1 = Pin(location: "Cambridge, MA", date: "April 23, 2016 to May 31, 2016")!
        let pin2 = Pin(location: "Seattle, WA", date: "June 1, 2016 to September 1, 2016")!
        let pin3 = Pin(location: "San Francisco, CA", date: "September 2, 2016 to December 31, 2016")!
        pins += [pin1, pin2, pin3]
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pins.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellIdentifier = "PinTableViewCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! PinTableViewCell
        let pin = pins[indexPath.row]

        cell.LocationLabel.text = pin.location
        cell.DateLabel.text = pin.date

        return cell
    }
    
    @IBAction func unwindToPinList(sender: UIStoryboardSegue) {
        if let sourceViewController = sender.sourceViewController as? PinViewController, pin = sourceViewController.pin {
            if let selectedIndexPath = tableView.indexPathForSelectedRow {
                pins[selectedIndexPath.row] = pin
                tableView.reloadRowsAtIndexPaths([selectedIndexPath], withRowAnimation: .None)
            }
            else {
                let newIndexPath = NSIndexPath(forRow: pins.count, inSection: 0)
                pins.append(pin)
                tableView.insertRowsAtIndexPaths([newIndexPath], withRowAnimation: .Bottom)
            }
            savePins()
        }
    }
    
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            pins.removeAtIndex(indexPath.row)
            savePins()
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


    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowDetail" {
            let pinDetailViewController = segue.destinationViewController as! PinViewController
            if let selectedPinCell = sender as? PinTableViewCell {
                let indexPath = tableView.indexPathForCell(selectedPinCell)!
                let selectedPin = pins[indexPath.row]
                pinDetailViewController.pin = selectedPin
            }
        }
        else if segue.identifier == "AddItem" {
            print("Adding new pin.")
        }
    }

    func savePins() {
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(pins, toFile: Pin.ArchiveURL.path!)
        if !isSuccessfulSave {
            print("Failed to save pins...")
        }
    }
    
    func loadPins() -> [Pin]? {
        return NSKeyedUnarchiver.unarchiveObjectWithFile(Pin.ArchiveURL.path!) as? [Pin]
    }
}
