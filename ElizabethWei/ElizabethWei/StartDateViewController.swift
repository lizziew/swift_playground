//
//  StartDateViewController.swift
//  ElizabethWei
//
//  Created by Elizabeth Wei on 4/23/16.
//  Copyright © 2016 Elizabeth Wei. All rights reserved.
//

import UIKit

protocol StartDateDelegate {
    func sendStartDateToPin(date: NSDate)
}

class StartDateViewController: UIViewController {
    @IBOutlet weak var startDatePicker: UIDatePicker!

    @IBAction func cancel(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func save(sender: UIBarButtonItem) {
        startDateDelegate?.sendStartDateToPin(startDatePicker.date)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    var startDateDelegate:StartDateDelegate? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        startDatePicker.minimumDate = NSDate()
    }
}
