//
//  MenuViewController.swift
//  PenguinFactory
//
//  Created by Elizabeth Wei on 7/21/15.
//  Copyright (c) 2015 Elizabeth Wei. All rights reserved.
//

import UIKit

class MenuViewController: UIViewController {
    @IBAction func goBack(segue: UIStoryboardSegue) {
        println("back to menu!")
    }
    
    @IBOutlet weak var playButton: UIButton!
    var timer: NSTimer?
    
    override func viewDidLoad() {
        view.backgroundColor = UIColor(red: 0.6, green: 0.88, blue: 0.97, alpha: 1.0)

        timer = NSTimer()
        timer = NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: "flashSign:", userInfo: nil, repeats: true)
    }
    
    func flashSign(timer: NSTimer?) {
        let silver = UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1.0)
        let gold = UIColor(red: 0.86, green: 0.85, blue: 0.16, alpha: 1.0)
        
        if playButton.currentTitleColor.isEqual(silver) {
            playButton.setTitleColor(gold, forState: UIControlState.Normal)
        }
        else {
            playButton.setTitleColor(silver, forState: UIControlState.Normal)
        }
    }
}
