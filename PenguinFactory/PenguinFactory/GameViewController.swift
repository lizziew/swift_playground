//
//  GameViewController.swift
//  PenguinFactory
//
//  Created by Elizabeth Wei on 7/21/15.
//  Copyright (c) 2015 Elizabeth Wei. All rights reserved.
//

import UIKit

class GameViewController: UIViewController {
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "unwindToMenu" {
            if let unwoundMVC = segue.destinationViewController as? MenuViewController {
                println("going back to menu, save score here")
            }
        }
    }
    
    @IBAction func quitRound() {
        var alert = UIAlertController(title: "Quit Round?", message: "Current score...", preferredStyle: UIAlertControllerStyle.Alert)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: { (action: UIAlertAction!) -> Void in
            //go back to game
        }))
        
        alert.addAction(UIAlertAction(title: "Quit", style: UIAlertActionStyle.Destructive, handler: { (action: UIAlertAction!) -> Void in
            self.performSegueWithIdentifier("unwindToMenu", sender: nil)
        }))
        
        presentViewController(alert, animated: true, completion: nil)
    }
}
