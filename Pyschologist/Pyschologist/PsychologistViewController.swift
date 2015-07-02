//
//  ViewController.swift
//  Pyschologist
//
//  Created by Elizabeth Wei on 7/1/15.
//  Copyright (c) 2015 Elizabeth Wei. All rights reserved.
//

import UIKit

class PsychologistViewController: UIViewController {
    
    //segue in code
    @IBAction func nothing(sender: UIButton) {
       performSegueWithIdentifier("nothing", sender: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        var destination = segue.destinationViewController as? UIViewController
        if let navCon = destination as? UINavigationController {
            destination = navCon.visibleViewController //returns controller on top of stack
        }
        if let hvc = destination as? HappinessViewController {
            if let identifier = segue.identifier {
                switch identifier {
                    case "sad": hvc.happiness = 0
                    case "happy": hvc.happiness = 100
                    case "nothing": hvc.happiness = 25
                    default: hvc.happiness = 50
                }
            }
        }
    }
}

