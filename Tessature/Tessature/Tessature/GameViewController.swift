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

var scene: GameScene!

class GameViewController: UIViewController {
    var gcEnabled = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let scene = GameScene()
        scene.size = self.view.bounds.size
        if let skView = self.view as? SKView{
            skView.presentScene(scene)
        }
 
        //self.authenticateLocalPlayer()
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
                        println("Welcome \(player.displayName)")
                        let skView = self.view as! SKView
                        skView.multipleTouchEnabled = false
                        
                        scene = GameScene(size: skView.bounds.size)
                        scene.scaleMode = .AspectFill
                        
                        let crossFade = SKTransition.crossFadeWithDuration(1.0)
                        
                        skView.presentScene(scene, transition: crossFade)
                    }
                })
            } else { //game center not enabled
                self.gcEnabled = false
            }
        }
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}
