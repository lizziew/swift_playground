//
//  PauseViewController.swift
//  PenguinFactory
//
//  Created by Elizabeth Wei on 8/12/15.
//  Copyright (c) 2015 Elizabeth Wei. All rights reserved.
//

import UIKit

class PauseViewController: UIViewController {
    var score = 0.0
    var timeRemaining = 0.0
    
    @IBOutlet weak var helpLabel: UILabel!
    
    override func viewDidLoad() {
        helpLabel.text = ""
    }
    
    @IBAction func showHelp(sender: UIButton) {
        helpLabel.text = "Choose the color of the word that appears on the screen, not the word itself \n You earn 1 point if you're correct, and lose 0.5 points if you're wrong \n You have 30 seconds \n If you choose 5 in a row correctly, you get 5 extra seconds!"
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "resumeGameSegue" {
            if let unwoundMVC = segue.destinationViewController as? GameViewController {
                unwoundMVC.score = self.score
                unwoundMVC.timeRemaining = self.timeRemaining
            }
        }
    }

}
