//
//  GameViewController.swift
//  PenguinFactory
//
//  Created by Elizabeth Wei on 7/21/15.
//  Copyright (c) 2015 Elizabeth Wei. All rights reserved.
//

import UIKit

class GameViewController: UIViewController, UIDynamicAnimatorDelegate {
    @IBOutlet weak var gameView: UIView!
    @IBOutlet weak var colorLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var timerLabel: UILabel!
    
    var timer: NSTimer?
    let timeInterval:NSTimeInterval = 0.05
    var timeRemaining:NSTimeInterval = 30.0
    
    func startTimer() {
        timer = NSTimer()
        timerLabel.text = timeString(timeRemaining)
        timer = NSTimer.scheduledTimerWithTimeInterval(timeInterval, target: self, selector: "endTimer:", userInfo: nil, repeats: true)
    }
    
    func endTimer(timer: NSTimer) {
        timeRemaining = timeRemaining - timeInterval
        if(timeRemaining <= 0) {
            timerLabel.textColor = UIColor.redColor()
            timerLabel.text = "TIME'S UP!"
            println("round over!")
            //segue to next screen
            timer.invalidate()
        }
        else {
            timerLabel.text = timeString(timeRemaining)
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
    
    func addAnimation(isCorrect: Bool) {
        let imageHeight = gameView.bounds.size.height / 5
        let imageWidth = gameView.bounds.size.width / 5
        let imageSize = CGSize(width: imageWidth, height: imageHeight)
        let imageOrigin = CGPoint(x: gameView.bounds.size.width/2 - imageWidth/2, y: gameView.bounds.size.height/2 - imageHeight/2)
        
        var correctImageView = UIImageView(frame: CGRect(origin: imageOrigin, size: imageSize))
        
        if(isCorrect) {
            correctImageView.image = UIImage(named: "checkmark")
        }
        else {
            correctImageView.image = UIImage(named: "wrong")
        }
        
        correctImageView.alpha = 0.7
        UIView.animateWithDuration(1.0, delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut, animations: { correctImageView.alpha = 0.0}, completion: nil)

        gameView.addSubview(correctImageView)
    }
    
    func chooseColor(button: UIButton) {
        if button.currentAttributedTitle!.string == currentColor {
            addWord()
            score++
            addAnimation(true)
        }
        else {
            score = score - 0.5
            addAnimation(false)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        timerLabel.text = timeString(timeRemaining)
        addWord()
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
