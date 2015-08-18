//
//  HelpViewController.swift
//  PenguinFactory
//
//  Created by Elizabeth Wei on 7/21/15.
//  Copyright (c) 2015 Elizabeth Wei. All rights reserved.
//

import UIKit

class HelpViewController: UIViewController {
    
    override func viewDidLoad() {
        view.backgroundColor = UIColor(red: 0.6, green: 0.88, blue: 0.97, alpha: 1.0)
        var instructionsText = UILabel(frame: CGRect(origin: CGPoint(x: 0.2 * self.view.bounds.width, y: 0.32 * self.view.bounds.height), size: CGSize(width: 0.4 * self.view.bounds.width, height: 0.6 * self.view.bounds.height)))
        instructionsText.numberOfLines = 15
        instructionsText.textAlignment = NSTextAlignment.Center
        instructionsText.font = UIFont(name: "Baskerville", size: 25.0)
        instructionsText.adjustsFontSizeToFitWidth = true
        
        instructionsText.text = "~Help~ \n\n Choose the color of the word that appears on the screen, not the word itself \n\n You earn 1 point if you're correct, and lose 0.5 points if you're wrong \n\n You have 20 seconds \n\n If you choose 5 in a row correctly, you get 5 extra seconds!"
        view.addSubview(instructionsText)
    }
}
