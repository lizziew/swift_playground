//
//  HelpViewController.swift
//  PenguinFactory
//
//  Created by Elizabeth Wei on 7/21/15.
//  Copyright (c) 2015 Elizabeth Wei. All rights reserved.
//

import UIKit

class HelpViewController: UIViewController {
    var instructionsText: UILabel = UILabel()
    
    var text: [String] = ["Help", "Choose the color of the word that appears on the screen, not the word itself", "You earn 1 point if you're correct, and lose 0.5 points if you're wrong", "You have 15 seconds", "If you choose 5 in a row correctly, you get 5 extra seconds!"]
    
    var textIndex = 0 {
        didSet {
            if textIndex == 0 {
                backButton.backgroundColor = UIColor.grayColor()
            }
            else if textIndex == text.count-1 {
                forwardButton.backgroundColor = UIColor.grayColor()
            }
            else {
                backButton.backgroundColor = backColor
                forwardButton.backgroundColor = forwardColor
            }
            instructionsText.text = text[textIndex]
        }
    }
    
    @IBOutlet weak var backButton: UIButton!
    var backColor = UIColor()
    @IBOutlet weak var forwardButton: UIButton!
    var forwardColor = UIColor()
    
    @IBAction func goBack(sender: UIButton) {
        if textIndex != 0 {
            textIndex--
        }
    }
    
    @IBAction func goForward(sender: UIButton) {
        if textIndex != text.count-1 {
            textIndex++
        }
    }
    
    override func viewDidLoad() {
        backColor = backButton.backgroundColor!
        forwardColor = forwardButton.backgroundColor!
        
        backButton.backgroundColor = UIColor.grayColor()
        
        view.backgroundColor = UIColor(red: 0.6, green: 0.88, blue: 0.97, alpha: 1.0)
        instructionsText = UILabel(frame: CGRect(origin: CGPoint(x: 0.2 * self.view.bounds.width, y: 0.2 * self.view.bounds.height), size: CGSize(width: 0.55 * self.view.bounds.width, height: 0.7 * self.view.bounds.height)))
        instructionsText.numberOfLines = 3
        instructionsText.textAlignment = NSTextAlignment.Center
        instructionsText.font = UIFont(name: "American Typewriter", size: 50.0)
        instructionsText.adjustsFontSizeToFitWidth = true
//        instructionsText.layer.borderColor = UIColor.greenColor().CGColor
//        instructionsText.layer.borderWidth = 3.0
        
        instructionsText.text = text[textIndex]
        
        view.addSubview(instructionsText)
    }
}
