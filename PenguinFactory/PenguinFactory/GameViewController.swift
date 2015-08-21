//
//  GameViewController.swift
//  PenguinFactory
//
//  Created by Elizabeth Wei on 7/21/15.
//  Copyright (c) 2015 Elizabeth Wei. All rights reserved.
//

import UIKit

class GameViewController: UIViewController {
    @IBOutlet weak var gameView: UIView!
    @IBOutlet weak var colorLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var feedbackLabel: UILabel!
    @IBOutlet weak var quitRoundButton: UIButton!
    @IBOutlet weak var backgroundImage: UIImageView!
    
    var timer: NSTimer?
    let timeInterval:NSTimeInterval = 0.05
    var timeRemaining:NSTimeInterval = 20.0 
    
    var bonusPoints:Int = 5 {
        didSet {
            if bonusPoints == 0 {
                timeRemaining = timeRemaining + 5.0
                addFeedback("bonus")
                bonusPoints = 5
            }
        }
    }
    
    func startTimer() {
        timer = NSTimer()
        timerLabel.text = timeString(timeRemaining)
        timer = NSTimer.scheduledTimerWithTimeInterval(timeInterval, target: self, selector: "endTimer:", userInfo: nil, repeats: true)
    }
    
    func endTimer(timer: NSTimer) {
        timeRemaining = timeRemaining - timeInterval
        if(timeRemaining <= 0) {
            timer.invalidate()
            
            performSegueWithIdentifier("endRoundSegue", sender: nil)
        }
        else {
            timerLabel.text = timeString(timeRemaining)
        }
    }
    
    func timeString(time:NSTimeInterval) -> String {
        let seconds = Int(time) % 60
        let secondFraction = Int((time - Double(seconds)) * 10.0)
        return String(format:" %02i.%01i s left ",  seconds, secondFraction)
    }
    
    var score = 0.0 {
        didSet {
            if scoreLabel != nil {
                scoreLabel.text = "\(score)"
            }
        }
    }
    
    var currentColor = ""
    
    let colors = [Color(description: "Red", value: UIColor.redColor()), Color(description: "Orange", value: UIColor.orangeColor()), Color(description: "Blue", value: UIColor.blueColor()), Color(description: "Green", value: UIColor.greenColor()), Color(description: "Purple", value: UIColor.purpleColor())]
    
    struct Color {
        var description: String
        var value: UIColor
        
        init(description: String, value: UIColor) {
            self.description = description
            self.value = value
        }
    }
    
    func getRandomColorName() -> String {
        return colors[Int(arc4random()%5)].description
    }
    
    func getRandomColor() -> UIColor {
        var c = colors[Int(arc4random()%5)]
        currentColor = c.description
        return c.value
    }
    
    func getRandomBackgroundColor(textColor: UIColor) -> UIColor {
        var backgroundColors: [Color] = colors
        
        backgroundColors.removeAtIndex(findColor(backgroundColors, c: textColor))
        
        var backgroundColor = backgroundColors[Int(arc4random()%4)]
        
        return backgroundColor.value
    }
    
    func findColor(colors: [Color], c: UIColor) -> Int {
        for i in 0..<colors.count {
            if c == colors[i].value {
                return i
            }
        }
        return -1
    }
    
    func addWord() {
        colorLabel.text = getRandomColorName()
        colorLabel.textColor = getRandomColor()
        gameView.backgroundColor = getRandomBackgroundColor(colorLabel.textColor)
    }
    
    func addFeedback(description: String) {
        feedbackLabel.alpha = 1.0
        
        if description == "right" {
            feedbackLabel.text = "😋"
        }
        else if description == "wrong" {
            feedbackLabel.text = "😥"
        }
        else if description == "bonus" {
            feedbackLabel.textColor = UIColor.whiteColor()
            feedbackLabel.text = "+5 extra seconds!"
        }
        
        UIView.animateWithDuration(2.0, delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut, animations: { self.feedbackLabel.alpha = 0.0 }, completion: nil)
    }
    
    func chooseColor(button: UIButton) {
        if button.currentTitle! == currentColor {
            addWord()
            score++
            addFeedback("right")
            bonusPoints = bonusPoints - 1
        }
        else {
            score = score - 0.5
            addFeedback("wrong")
            bonusPoints = 5
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        timerLabel.text = timeString(timeRemaining)
        scoreLabel.text = "\(score)"
        feedbackLabel.text = ""
        addWord()
        quitRoundButton.layer.cornerRadius = 10
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        startTimer()
    
        //color buttons
        let buttonHeight = (0.9 * gameView.bounds.size.height) / 5
        let buttonWidth = (0.8 * gameView.bounds.size.width) / 5
        let buttonSize = CGSize(width: buttonWidth, height: buttonHeight)
        var buttonOrigin = CGPoint(x: gameView.bounds.size.width - 1.07 * buttonWidth, y: 0.4 * buttonHeight)
        
        var buttons = [UIButton]()
        
        var fontSize = CGFloat(20.0)
        if self.view.traitCollection.horizontalSizeClass == UIUserInterfaceSizeClass.Regular {
            fontSize = CGFloat(30.0)
        }

        for i in 0..<colors.count {
            var button = UIButton(frame: CGRect(origin: buttonOrigin, size: buttonSize))
            button.backgroundColor = UIColor.grayColor()
            button.layer.borderColor = UIColor.whiteColor().CGColor
            button.layer.borderWidth = 1
            button.layer.cornerRadius = 10
            button.showsTouchWhenHighlighted = true
            
            button.setTitle(colors[i].description, forState: UIControlState.Normal)
            button.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
            button.titleLabel!.font =  UIFont(name: "American Typewriter", size: fontSize)
            
            button.addTarget(self, action: "chooseColor:", forControlEvents: UIControlEvents.TouchUpInside)
            buttons.append(button)
            
            gameView.addSubview(button)
            
            buttonOrigin.y += buttonHeight
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.timer?.invalidate()
        self.timer = nil
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "unwindToMenu" {
            if let unwoundMVC = segue.destinationViewController as? MenuViewController {
                println("going back to menu") 
            }
        }
        else if segue.identifier == "endRoundSegue" {
            if let unwoundMVC = segue.destinationViewController as? EndViewController {
                unwoundMVC.score = score
                println(score)
            }
        }
        else if segue.identifier == "showPauseSegue" {
            if let unwoundMVC = segue.destinationViewController as? PauseViewController {
                timer?.invalidate()
                unwoundMVC.view.backgroundColor = UIColor(white: 1.0, alpha: 0.6)
                unwoundMVC.score = self.score
                unwoundMVC.timeRemaining = self.timeRemaining
                
                if UIDevice.currentDevice().systemVersion >= "8" {
                    //For iOS 8
                    self.definesPresentationContext = true
                    unwoundMVC.modalPresentationStyle = UIModalPresentationStyle.OverCurrentContext
                }
                else {
                    //For iOS 7
                    self.modalPresentationStyle = UIModalPresentationStyle.CurrentContext
                }
            }
        }
    }
}
