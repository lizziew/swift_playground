//
//  StartViewController.swift
//  Tessature
//
//  Created by Elizabeth Wei on 6/12/15.
//  Copyright (c) 2015 Elizabeth Wei. All rights reserved.
//

import GameKit
import UIKit
import SpriteKit

var scene: GameScene!

class StartViewController: UIViewController {
    var gcEnabled = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if(!self.gcEnabled) {
            authenticatePlayer()
        }
    }

    func authenticatePlayer() {
        if let localPlayer = GKLocalPlayer.localPlayer() {
            localPlayer.authenticateHandler = {
                (GameViewController, error) in
                if GameViewController != nil {
                    self.presentViewController(GameViewController, animated: true, completion: nil)
                }
                else if localPlayer.authenticated {
                    println("authenticated!")
                    self.gcEnabled = true
                }
                else if let theError =  error {
                    println("Error! \(error)")
                    //self.playerFailedToAuthenticated(theError)
                }
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func backToStartScreen(segue: UIStoryboardSegue) {
        println("user quit round");
    }
}
