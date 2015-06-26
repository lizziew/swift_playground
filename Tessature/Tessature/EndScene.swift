//
//  EndScene.swift
//  Tessature
//
//  Created by Elizabeth Wei on 6/17/15.
//  Copyright (c) 2015 Elizabeth Wei. All rights reserved.
//

import Foundation
import SpriteKit

class EndScene: SKScene{
    var contentCreated = false
    
    override func didMoveToView(view: SKView) {
        if self.contentCreated == false {
            drawBackground()
            self.contentCreated = true
        }
    }
    
    func drawBackground() {
        backgroundColor = SKColor.whiteColor()
        scaleMode = SKSceneScaleMode.Fill
        
        changeButtonTitle(" Quit Round ", newButtonTitle: "Go Home")
        
        var gameOverText = SKLabelNode(text: "Round Over!")
        gameOverText.position = CGPointMake(size.width/2, size.height/2)
        gameOverText.fontColor = UIColor.blackColor()
        addChild(gameOverText)
        
        let button = UIButton(frame: CGRectMake(size.width * 0.5 - 100, size.height * 0.8 - 25, 200, 50))
        button.backgroundColor = UIColor.greenColor()
        button.setTitle("Play Again!", forState: UIControlState.Normal)
        button.addTarget(self, action: "goToGameScene", forControlEvents: UIControlEvents.TouchUpInside)
        
        self.view!.addSubview(button)
    }
    
    func goToGameScene() {
        removeButton("Play Again!")
        
        let gameScene = GameScene()
        gameScene.size = self.size
        self.view?.presentScene(gameScene)
    }
    
    func removeButton(buttonTitle: String) {
        let subviews = self.view!.subviews as! [UIView]
        for v in subviews {
            if let button = v as? UIButton {
                if button.currentTitle == buttonTitle {
                    button.removeFromSuperview()
                    break
                }
            }
        }
    }
    
    func changeButtonTitle(buttonTitle: String, newButtonTitle: String) {
        let subviews = self.view!.subviews as! [UIView]
        for v in subviews {
            if let button = v as? UIButton {
                if button.currentTitle == buttonTitle {
                    button.setTitle(newButtonTitle, forState: UIControlState.Normal)
                    break
                }
            }
        }
    }
}