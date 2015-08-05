//
//  HelpViewController.swift
//  PenguinFactory
//
//  Created by Elizabeth Wei on 7/21/15.
//  Copyright (c) 2015 Elizabeth Wei. All rights reserved.
//

import UIKit

class HelpViewController: UIViewController {
    @IBOutlet weak var instructions: UILabel!
    
    override func viewDidLoad() {
        instructions.text = "Choose the color of the word that appears on the screen, not the word itself \n\n You earn 1 point if you're correct, and lose 0.5 points if you're wrong \n\n You have 30 seconds \n\n If you choose 5 in a row correctly, you get 5 extra seconds!"
    }
}
