//
//  EndViewController.swift
//  PenguinFactory
//
//  Created by Elizabeth Wei on 8/5/15.
//  Copyright (c) 2015 Elizabeth Wei. All rights reserved.
//

import UIKit

class EndViewController: UIViewController {
    @IBOutlet weak var scoreLabel: UILabel!
    var score = 0.0
    @IBOutlet weak var scoresListLabel: UILabel!
    
    override func viewDidLoad() {        
        scoreLabel.text = "\(score) pts"
        view.backgroundColor = UIColor(red: 0.6, green: 0.88, blue: 0.97, alpha: 1.0)
        
        //save new score
        var defaults = NSUserDefaults.standardUserDefaults()
        var scores = [AnyObject]()
        if let storedScores = defaults.arrayForKey("score") {
            scores = storedScores
        }
        scores.append(score)
        defaults.setObject(scores, forKey: "score")
        defaults.synchronize()
        
        //display high scores
        var sortedscores = scores as AnyObject as! [Double]
        sortedscores.sort(>)
        displaySortedScores(sortedscores)
    }
    
    func displaySortedScores(scores: [Double]) {
        var count = 3
        var listText = ""
        
        for s in scores {
            if count == 0 {
                break
            }
            
            listText += "\n\(s)"
            
            count--
        }
        
        while count > 0 {
            listText += "\n"
            count--
        }
        
        scoresListLabel.text = "High Scores:" + listText
    }
}
