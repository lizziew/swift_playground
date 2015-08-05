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
    @IBOutlet weak var quitRoundButton: UIButton!
    
    @IBAction func showHelpPopover(sender: UIButton) {
        timer?.invalidate()
        
        var alert = UIAlertController(title: "😱Help😱", message:  "Choose the color of the word that appears on the screen, not the word itself \n\n You earn 1 point if you're correct, and lose 0.5 points if you're wrong \n\n You have 30 seconds \n\n If you choose 5 in a row correctly, you get 5 extra seconds!", preferredStyle: UIAlertControllerStyle.Alert)
        
        alert.addAction(UIAlertAction(title: "Resume", style: UIAlertActionStyle.Cancel, handler: { (action: UIAlertAction!) -> Void in
            self.timer = NSTimer.scheduledTimerWithTimeInterval(self.timeInterval, target: self, selector: "endTimer:", userInfo: nil, repeats: true)
        }))
        
        presentViewController(alert, animated: true, completion: nil)
    }
    
    var timer: NSTimer?
    let timeInterval:NSTimeInterval = 0.05
    var timeRemaining:NSTimeInterval = 30.0
    
    var bonusPoints:Int = 5 {
        didSet {
            if bonusPoints == 0 {
                timeRemaining = timeRemaining + 5.0
                addAnimation("bonus")
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
            if timeRemaining <= 10 {
                timerLabel.textColor = UIColor.redColor()
            }
        }
    }
    
    func timeString(time:NSTimeInterval) -> String {
        let seconds = Int(time) % 60
        let secondFraction = Int((time - Double(seconds)) * 10.0)
        return String(format:"%02i.%01i sec left",  seconds, secondFraction)
    }
    
    var score = 0.0 {
        didSet {
            scoreLabel.text = "\(score)"
        }
    }
    
    var currentColor = ""
    
    var colors = [Color(description: "Red", value: UIColor.redColor()), Color(description: "Orange", value: UIColor.orangeColor()), Color(description: "Blue", value: UIColor.blueColor()), Color(description: "Green", value: UIColor.greenColor()), Color(description: "Purple", value: UIColor.purpleColor())]
    
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
    
    func addWord() {
        colorLabel.text = getRandomColorName()
        colorLabel.textColor = getRandomColor()
    }
    
    func addAnimation(description: String) {
        let imageHeight = gameView.bounds.size.height / 5
        let imageWidth = gameView.bounds.size.width / 5
        let imageSize = CGSize(width: imageWidth, height: imageHeight)
        
        var imageOrigin = CGPoint(x: gameView.bounds.size.width/2 - imageWidth/2, y: gameView.bounds.size.height/2 - imageHeight/2)
        if description == "bonus" {
            imageOrigin = CGPoint(x: gameView.bounds.size.width/2 - imageWidth/2, y: gameView.bounds.size.height/2 - imageHeight)
        }
        
        var correctImageView = UIImageView(frame: CGRect(origin: imageOrigin, size: imageSize))
        
        var duration = 1.0
        
        if description == "right" {
            correctImageView.image = UIImage(named: "checkmark")
        }
        else if description == "wrong" {
            correctImageView.image = UIImage(named: "wrong")
        }
        else if description == "bonus" {
            correctImageView.image = UIImage(named: "bonus")
            duration = 2.0
        }
        
        correctImageView.alpha = 0.7
        UIView.animateWithDuration(duration, delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut, animations: { correctImageView.alpha = 0.0}, completion: nil)

        gameView.addSubview(correctImageView)
    }
    
    func chooseColor(button: UIButton) {
        if button.currentAttributedTitle!.string == currentColor {
            addWord()
            score++
            addAnimation("right")
            bonusPoints = bonusPoints - 1
        }
        else {
            score = score - 0.5
            addAnimation("wrong")
            bonusPoints = 5
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        timerLabel.text = timeString(timeRemaining)
        addWord()
        quitRoundButton.layer.cornerRadius = 10
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        startTimer()
    
        //color buttons
        let buttonHeight = gameView.bounds.size.height / 5
        let buttonWidth = gameView.bounds.size.width / 5
        let buttonSize = CGSize(width: buttonWidth, height: buttonHeight)
        var buttonOrigin = CGPoint(x: gameView.bounds.size.width - buttonWidth, y: 0)
        
        var buttons = [UIButton]()
        for i in 0..<colors.count {
            var button = UIButton(frame: CGRect(origin: buttonOrigin, size: buttonSize))
            button.backgroundColor = UIColor(white: 0.1, alpha: 0.2)
            button.layer.borderColor = UIColor.whiteColor().CGColor
            button.layer.borderWidth = 1
            button.layer.cornerRadius = 10
            button.showsTouchWhenHighlighted = true
            
            var attrs = [NSFontAttributeName: UIFont.systemFontOfSize(20.0)]
            var title = NSMutableAttributedString(string: colors[i].description, attributes: attrs)
            button.setAttributedTitle(title, forState: UIControlState.Normal)
            
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
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "unwindToMenu" {
            if let unwoundMVC = segue.destinationViewController as? MenuViewController {
                println("going back to menu") 
            }
        }
        else if segue.identifier == "endRoundSegue" {
            if let unwoundMVC = segue.destinationViewController as? EndViewController {
                unwoundMVC.score = score
            }
        }
    }
    
    @IBAction func quitRound() {
        timer?.invalidate()
        
        var alert = UIAlertController(title: "Game Paused", message: "If you quit, your score won't be saved!", preferredStyle: UIAlertControllerStyle.Alert)
        
        alert.addAction(UIAlertAction(title: "Resume", style: UIAlertActionStyle.Cancel, handler: { (action: UIAlertAction!) -> Void in
            self.timer = NSTimer.scheduledTimerWithTimeInterval(self.timeInterval, target: self, selector: "endTimer:", userInfo: nil, repeats: true)
        }))
        
        alert.addAction(UIAlertAction(title: "Quit", style: UIAlertActionStyle.Destructive, handler: { (action: UIAlertAction!) -> Void in
            self.performSegueWithIdentifier("unwindToMenu", sender: nil)
        }))
        
        presentViewController(alert, animated: true, completion: nil)
    }
}
