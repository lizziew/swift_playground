//
//  GameViewController.swift
//  Tessature
//
//  Created by Elizabeth Wei on 6/10/15.
//  Copyright (c) 2015 Elizabeth Wei. All rights reserved.
//

import UIKit
import SpriteKit
import GameKit

class GameViewController: UIViewController {
    var scene: GameScene!
    
    var gcEnabled = true
    var gcDefaultLeaderBoard = ""
    
    var score = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //self.authenticateLocalPlayer()
        
        let skView = view as! SKView
        skView.multipleTouchEnabled = false
        
        scene = GameScene(size: skView.bounds.size)
        scene.scaleMode = .AspectFill
        
        skView.presentScene(scene)
    }
    
    func authenticateLocalPlayer() {
        let player = GKLocalPlayer.localPlayer()
        
        player.authenticateHandler = {(GameViewController, error) -> Void in
            if((GameViewController) != nil) { //player not logged in -> show login
                self.presentViewController(GameViewController, animated: true, completion: nil)
            } else if (player.authenticated) { //player logged in -> load game center
                self.gcEnabled = true
                player.loadDefaultLeaderboardIdentifierWithCompletionHandler({ (leaderboardIdentifer: String!, error: NSError!) -> Void in
                    if error != nil {
                        println(error)
                    } else {
                        self.gcDefaultLeaderBoard = leaderboardIdentifer
                    }
                })
            } else { //game center not enabled
                self.gcEnabled = false
            }
            
        }
        
    }
    
    func submitScore() {
        var leaderboardID = "leaderboardid"
        var reportedScore = GKScore(leaderboardIdentifier: leaderboardID)
        reportedScore.value = Int64(score)
        
        let player = GKLocalPlayer.localPlayer()
        GKScore.reportScores([reportedScore], withCompletionHandler: { (error: NSError!) -> Void in
            if error != nil {
                println(error.localizedDescription)
            }
            else {
                println("score submitted successfully")
            }
        })
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}
