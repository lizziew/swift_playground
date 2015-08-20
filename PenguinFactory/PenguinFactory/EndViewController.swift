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
    
    override func viewDidLoad() {
        scoreLabel.text = "\(score) pts"
        view.backgroundColor = UIColor(red: 0.6, green: 0.88, blue: 0.97, alpha: 1.0)
    }
}
