//
//  GameScene.swift
//  Tessature
//
//  Created by Elizabeth Wei on 6/10/15.
//  Copyright (c) 2015 Elizabeth Wei. All rights reserved.
//

import SpriteKit

struct Route {
    var sourceDotIndex = -1
    var destinationDotIndex = -1
    var hasBeenDrawnByUser = false
}

struct Shape {
    var lines: [Route]
    
    init(lines:[Route]) {
        self.lines = lines
    }
    
    func hasBeenCompleted() -> Bool {
        for line in lines {
            if line.hasBeenDrawnByUser == false {
                return false
            }
        }
        return true
    }
}

class GameScene: SKScene {
    var prevDot = SKShapeNode()
    var dots = [SKShapeNode]()
    var shape = Shape(lines: [])
    
    override func didMoveToView(view: SKView) {
        UIGraphicsBeginImageContextWithOptions(size, true, 0.0)
        drawBackground()
    }
    
    func drawBackground(){
        backgroundColor = SKColor.whiteColor()
        
        //make dots
        var dotPositions = [CGPoint(x: size.width * 0.5, y: size.height * 0.2),
                            CGPoint(x: size.width * 0.5, y: size.height * 0.8),
                            CGPoint(x: size.width * 0.2, y: size.height * 0.5),
                            CGPoint(x: size.width * 0.8, y: size.height * 0.5)]
      
        for position in dotPositions {
            var dot = SKShapeNode(circleOfRadius: 20.0)
            dot.name = "dot"
            dot.fillColor = UIColor.blackColor()
            dot.position = position
            dots += [(dot)]
        }
        
        //make lines
        var routes:[Route] = []
        routes += [ Route(sourceDotIndex: 0, destinationDotIndex: 3, hasBeenDrawnByUser: false),
                    Route(sourceDotIndex: 0, destinationDotIndex: 2, hasBeenDrawnByUser: false),
                    Route(sourceDotIndex: 1, destinationDotIndex: 2, hasBeenDrawnByUser: false),
                    Route(sourceDotIndex: 1, destinationDotIndex: 3, hasBeenDrawnByUser: false)]
        
        //make shape
        shape = Shape(lines: routes)
        
        //draw lines
        for route in shape.lines {
            var bezierPath = UIBezierPath()
            bezierPath.moveToPoint(dotPositions[route.sourceDotIndex])
            bezierPath.addLineToPoint(dotPositions[route.destinationDotIndex])
            
            var line = SKShapeNode(path: bezierPath.CGPath)
            line.lineWidth = 5.0
            line.strokeColor = UIColor.grayColor()
            line.name = "line"
            addChild(line)
        }
        
        //draw dots
        for dot in dots{
            addChild(dot)
        }
    }

    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        let touch = touches.first as! UITouch
        let touchLocation = touch.locationInNode(self)
        
        let node = self.nodeAtPoint(touchLocation)
        if(node.name == "dot") {
            prevDot = node as! SKShapeNode
            println("touched first dot!")
        }
    }
    
    override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
        let touch = touches.first as! UITouch
        let touchLocation = touch.locationInNode(self)
        
        let node = self.nodeAtPoint(touchLocation)
        if(node.name == "dot") {
            drawLine(prevDot, destDot: node as! SKShapeNode)
            println("touched second dot!")
        }
    }

    func drawLine(srcDot: SKShapeNode, destDot: SKShapeNode) {
        /*var route = UIBezierPath()
        route.moveToPoint(srcDot)
        route.addLineToPoint(destDot)
        
        var line = SKShapeNode(path: route.CGPath)
        line.lineWidth = 5.0
        line.strokeColor = UIColor.blackColor()
        addChild(line)*/
    }
}
