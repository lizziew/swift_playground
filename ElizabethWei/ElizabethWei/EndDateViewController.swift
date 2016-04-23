//
//  EndDateViewController.swift
//  ElizabethWei
//
//  Created by Elizabeth Wei on 4/23/16.
//  Copyright © 2016 Elizabeth Wei. All rights reserved.
//

import UIKit

protocol EndDateDelegate {
    func sendEndDateToPin(date: NSDate)
}

class EndDateViewController: UIViewController {
    
    @IBAction func cancel(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    @IBAction func save(sender: UIBarButtonItem) {
        endDateDelegate?.sendEndDateToPin(endDatePicker.date)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBOutlet weak var endDatePicker: UIDatePicker!
    
    var endDateDelegate:EndDateDelegate? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        endDatePicker.minimumDate = NSDate()
    }
}
