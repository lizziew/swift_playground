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

class GameViewController: UIViewController, GKMatchmakerViewControllerDelegate, GKMatchDelegate {
    let scene = GameScene()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        matchWithOtherPlayer()
    }

    func matchWithOtherPlayer() {
        println("trying to match")
        self.dismissViewControllerAnimated(false, completion: nil)
        
        let matchRequest = GKMatchRequest()
        matchRequest.minPlayers = 2
        matchRequest.maxPlayers = 2
        matchRequest.defaultNumberOfPlayers = 2
        
        let matchmakerViewController = GKMatchmakerViewController(matchRequest: matchRequest)
        matchmakerViewController.matchmakerDelegate = self
        self.presentViewController(matchmakerViewController, animated: true, completion: nil)
    }
    
    //GKMatchDelegate
    
    func match(match: GKMatch!, didReceiveData data: NSData!, fromRemotePlayer player: GKPlayer!) {
        println("received data")
        scene.dataReceived(data) 
    }
    
    //GKMatchmakerViewControllerDelegate
    
    func matchmakerViewController(viewController: GKMatchmakerViewController!, didFindMatch match: GKMatch!) {
        self.dismissViewControllerAnimated(true, completion: nil)
        
        scene.match = match
        match.delegate = self
        
        println("making match")
        
        if(match.expectedPlayerCount == 0) {
            scene.size = self.view.bounds.size
            scene.otherPlayer = getOtherPlayer(match)!
            scene.otherPlayerName = scene.otherPlayer.alias
            
            scene.thisPlayerColor = UIColor.redColor()
            scene.otherPlayerColor = UIColor.blueColor()
            
            if let skView = self.view as? SKView {
                skView.presentScene(scene)
            }
        }
    }
    
    func matchmakerViewController(viewController: GKMatchmakerViewController!, didFindHostedPlayers players: [AnyObject]!) {
        println("got here")
    }
    
    func getOtherPlayer(match: GKMatch) -> GKPlayer? {
        for player in match.players {
            let player = player as! GKPlayer
            if(player.playerID != GKLocalPlayer.localPlayer().playerID) {
                return player
            }
        }
        println("ERROR: COULDN'T FIND OTHER PLAYER")
        return nil
    }
    
    func matchmakerViewControllerWasCancelled(viewController: GKMatchmakerViewController!) {
        println("Cancelled")
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func matchmakerViewController(viewController: GKMatchmakerViewController!, didFailWithError error: NSError!) {
        println("Error!")
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    //GKGameCenterControllerDelegate
//    func gameCenterViewControllerDidFinish(gameCenterViewController: GKGameCenterViewController!) {
//        println("got here")
//        
//        self.dismissViewControllerAnimated(true, completion: nil)
//    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}
