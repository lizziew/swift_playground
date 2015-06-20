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

class GameViewController: UIViewController, GKGameCenterControllerDelegate, GKTurnBasedMatchmakerViewControllerDelegate, GKLocalPlayerListener {
    var currentMatch = GKTurnBasedMatch()
    
    @IBOutlet var TurnLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        findOtherPlayer()
    }
    
    func beginRound() {
        let player = GKLocalPlayer.localPlayer()
        self.TurnLabel.text = player.alias + "'s turn"
        
        let scene = GameScene()
        scene.size = self.view.bounds.size
        if let skView = self.view as? SKView{
            skView.presentScene(scene)
        }
    }
    
    func findOtherPlayer() {
        let matchRequest = GKMatchRequest()
        matchRequest.minPlayers = 2
        matchRequest.maxPlayers = 2
        
        let matchmakerViewController = GKTurnBasedMatchmakerViewController(matchRequest: matchRequest)
        matchmakerViewController.turnBasedMatchmakerDelegate = self
        self.presentViewController(matchmakerViewController, animated: true, completion: nil)
    }
    
    func turnBasedMatchmakerViewController(viewController: GKTurnBasedMatchmakerViewController!, didFindMatch match: GKTurnBasedMatch!) {
        self.dismissViewControllerAnimated(true, completion: nil)
        
        currentMatch = match
        
        if match.currentParticipant.player.playerID == GKLocalPlayer.localPlayer().playerID {
            println("we are the current player")
            beginRound()
        } else {
            println("we are not current player")
            // Someone else is the current player.
        }
        
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
    
    func player(player: GKPlayer!, receivedTurnEventForMatch match: GKTurnBasedMatch!, didBecomeActive: Bool) {
        //turn based match has updated. we may now be the current player.
    }
    
    func player(player: GKPlayer!, matchEnded match: GKTurnBasedMatch!) {
        //match has ended
        for participant in match.participants as! [GKTurnBasedParticipant] {
            println("\(participant.player.alias)'s outcome: \(participant.matchOutcome)")
        }
    }
    
    func endTurn(match: GKTurnBasedMatch, gameData: NSData, nextParticipants: [GKTurnBasedParticipant]) {
        match.endTurnWithNextParticipants(nextParticipants, turnTimeout: 2000.0, matchData: gameData) { (error) in
        }
    }
    
    func endMatch(match: GKTurnBasedMatch, finalGameData: NSData) {
        match.endMatchInTurnWithMatchData(finalGameData, completionHandler: {
            (error) in
        })
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}
