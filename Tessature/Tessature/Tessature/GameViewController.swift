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

class GameViewController: UIViewController, GKGameCenterControllerDelegate, GKTurnBasedMatchmakerViewControllerDelegate {
    let scene = GameScene()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        matchWithOtherPlayer()
    }
    
    func beginRound(match: GKTurnBasedMatch, isTurnOfPlayer: Bool) {
        scene.size = self.view.bounds.size
        scene.match = match
        scene.otherPlayer = getOtherPlayer(match)!
        scene.otherPlayerName = scene.otherPlayer.player.alias
        
        scene.thisPlayerColor = UIColor.redColor()
        scene.otherPlayerColor = UIColor.blueColor()
        
        if let skView = self.view as? SKView{
            skView.presentScene(scene)
        }
    }
    
    func getOtherPlayer(match: GKTurnBasedMatch) -> GKTurnBasedParticipant? {
            for participant in match.participants {
                let participant = participant as! GKTurnBasedParticipant
                if(participant != match.currentParticipant) {
                    return participant
                }
            }
        println("ERROR: COULDN'T FIND OTHER PLAYER")
        return nil
    }

    func matchWithOtherPlayer() {
        let matchRequest = GKMatchRequest()
        matchRequest.minPlayers = 2
        matchRequest.maxPlayers = 2
        
        let matchmakerViewController = GKTurnBasedMatchmakerViewController(matchRequest: matchRequest)
        matchmakerViewController.turnBasedMatchmakerDelegate = self
        self.presentViewController(matchmakerViewController, animated: true, completion: nil)
    }
    
    func turnBasedMatchmakerViewController(viewController: GKTurnBasedMatchmakerViewController!, didFindMatch match: GKTurnBasedMatch!) {
        self.dismissViewControllerAnimated(true, completion: nil)
        
        let isTurnOfPlayer = match.currentParticipant.player.playerID == GKLocalPlayer.localPlayer().playerID
        
        beginRound(match, isTurnOfPlayer: isTurnOfPlayer)
    }
    
    func gameCenterViewControllerDidFinish(gameCenterViewController: GKGameCenterViewController!) {
            self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func turnBasedMatchmakerViewControllerWasCancelled(viewController: GKTurnBasedMatchmakerViewController!) {
            // The user closed the matchmaker without creating a match
            self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func turnBasedMatchmakerViewController(viewController: GKTurnBasedMatchmakerViewController!, didFailWithError error: NSError!) {
        //failed to find a match
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func turnBasedMatchmakerViewController(viewController: GKTurnBasedMatchmakerViewController!, playerQuitForMatch match: GKTurnBasedMatch!) {
            // We're quitting this game.
            
            self.dismissViewControllerAnimated(true, completion: nil)
            
            let matchData = match.matchData
            // Do something with the match data to reflect the fact that we're
            // quitting (e.g., give all of our buildings to someone else,
            // or remove them from the game)
            
            match.participantQuitInTurnWithOutcome(GKTurnBasedMatchOutcome.Quit,
                nextParticipants: match.participants, turnTimeout: 2000.0, matchData: matchData) { (error) in
                    // We've now finished telling Game Center that we've quit
            }
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}
