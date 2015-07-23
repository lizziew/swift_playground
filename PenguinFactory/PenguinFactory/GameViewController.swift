//
//  GameViewController.swift
//  PenguinFactory
//
//  Created by Elizabeth Wei on 7/21/15.
//  Copyright (c) 2015 Elizabeth Wei. All rights reserved.
//

import UIKit

class GameViewController: UIViewController, UIDynamicAnimatorDelegate {
    var timer: NSTimer?
    
    @IBOutlet weak var gameView: UIView!
    
    lazy var animator: UIDynamicAnimator = {
        let lazilyCreatedAnimator = UIDynamicAnimator(referenceView: self.gameView)
        lazilyCreatedAnimator.delegate = self
        return lazilyCreatedAnimator
    }()
    
    let eggBehavior = PenguinBehavior()
    
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
    
    func addEgg(timer: NSTimer) {
        println("add egg!")
        
        let eggSize = gameView.bounds.size.width / 5
        let eggFrame = CGRect(origin: CGPoint(x: gameView.bounds.size.width/2 - eggSize/2, y: 0.0), size: CGSize(width: eggSize, height: eggSize))
        let eggView = UIImageView(frame: eggFrame)
        eggView.image = UIImage(named: "egg")!
        eggView.contentMode = UIViewContentMode.ScaleAspectFit
        
        let eggLabelFrame = CGRect(origin: CGPoint(x: gameView.bounds.size.width/2 - eggSize/2, y: 0.0), size: CGSize(width: eggSize, height: eggSize))
        let eggLabel = UILabel(frame: eggLabelFrame)
        eggLabel.textColor = UIColor.random
        eggLabel.backgroundColor = UIColor.clearColor()
        eggLabel.text = getRandomColorName()
        eggLabel.textAlignment = NSTextAlignment.Center
        
        eggBehavior.addEgg(eggView)
        eggBehavior.addEgg(eggLabel)
    }
    
    func chooseColor(button: UIButton) {
        println(button.backgroundColor)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        animator.addBehavior(eggBehavior)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.timer = NSTimer.scheduledTimerWithTimeInterval(3.0, target: self, selector: "addEgg:", userInfo: nil, repeats: true)
        
        //scoreboard
        let scoreboardHeight = gameView.bounds.size.height / 3
        let scoreboardWidth = gameView.bounds.size.width / 5
        
        let scoreboardFrame = CGRect(origin: CGPoint(x: 0, y : gameView.bounds.size.height/2 - scoreboardHeight/2), size: CGSize(width: scoreboardWidth, height: scoreboardHeight))
        let scoreboardView = UIImageView(frame: scoreboardFrame)
        scoreboardView.image = UIImage(named: "scoreboard")!
        scoreboardView.contentMode = UIViewContentMode.ScaleAspectFit
        gameView.addSubview(scoreboardView)
        
        //lives
        let livesHeight = scoreboardHeight * 0.3
        let livesWidth = scoreboardWidth * 0.3
        let livesFrame = CGRect(origin: CGPoint(x: scoreboardFrame.size.width/20, y: gameView.bounds.size.height/2 - livesHeight/2), size: CGSize(width: livesWidth, height: livesHeight))
        let livesView = UIView(frame: livesFrame)
        livesView.backgroundColor = UIColor.blackColor()
        gameView.addSubview(livesView)
        
        //console
        let consoleHeight = gameView.bounds.size.height / 2
        let consoleWidth = gameView.bounds.size.width / 3
        
        let consoleFrame = CGRect(origin: CGPoint(x: gameView.bounds.size.width - consoleWidth, y : gameView.bounds.size.height/2 - consoleHeight/2), size: CGSize(width: consoleWidth, height: consoleHeight))
        let consoleView = UIImageView(frame: consoleFrame)
        consoleView.image = UIImage(named: "console")!
        consoleView.contentMode = UIViewContentMode.ScaleAspectFit
        gameView.addSubview(consoleView)
        
        //color buttons
        let buttonHeight = gameView.bounds.size.width / 10
        let buttonWidth = gameView.bounds.size.width / 10
        let buttonSize = CGSize(width: buttonWidth, height: buttonHeight)
        var buttonOrigin = CGPoint(x: gameView.bounds.size.width - buttonWidth * 1.1, y: gameView.bounds.size.height/2 - consoleHeight * 0.3)
        
        var buttons = [UIButton]()
        for i in 0..<colors.count {
            var button = UIButton(frame: CGRect(origin: buttonOrigin, size: buttonSize))
            button.backgroundColor = colors[i].value
            button.addTarget(self, action: "chooseColor:", forControlEvents: UIControlEvents.TouchUpInside)
            buttons.append(button)
            gameView.addSubview(button)
            
            buttonOrigin.y += (1.1 * buttonHeight)
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

private extension UIColor {
    class var random: UIColor {
        switch arc4random()%5 {
        case 0: return UIColor.redColor()
        case 1: return UIColor.orangeColor()
        case 2: return UIColor.blueColor()
        case 3: return UIColor.greenColor()
        case 4: return UIColor.purpleColor()
        default: return UIColor.blackColor()
        }
    }
}
