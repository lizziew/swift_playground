//
//  GameScene.swift
//  Tessature
//
//  Created by Elizabeth Wei on 6/10/15.
//  Copyright (c) 2015 Elizabeth Wei. All rights reserved.
//

import SpriteKit

var prevDot = SKShapeNode()
var dots = [SKShapeNode]()
var shape = Shape(lines: [])
var dotPositions = [CGPoint]()

struct Edge {
    var sourceDotIndex = -1
    var destinationDotIndex = -1
    var hasBeenDrawnByUser = false
    
    func getEdgeFrame() -> CGRect {
        let sourceDot = dots[self.sourceDotIndex].position
        let destinationDot = dots[self.destinationDotIndex].position
        
        let originX = min(sourceDot.x, destinationDot.x)
        let originY = min(sourceDot.y, destinationDot.y)
        
        let width = max(sourceDot.x, destinationDot.x) - originX
        let height = max(sourceDot.y, destinationDot.y) - originY
        
        return CGRectMake(originX, originY, width, height)
    }
    
    func makeEdgeNode(color: UIColor) -> SKShapeNode {
        var bezierPath = UIBezierPath()
        bezierPath.moveToPoint(dotPositions[self.sourceDotIndex])
        bezierPath.addLineToPoint(dotPositions[self.destinationDotIndex])
        
        var line = SKShapeNode(path: bezierPath.CGPath)
        line.lineWidth = 5.0
        line.strokeColor = color
        line.name = "line"
        
        return line
    }
}

struct Shape {
    var lines: [Edge]
    
    init(lines:[Edge]) {
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
    
    func makeShapeNode() -> SKShapeNode {
        var bezierPath = UIBezierPath()
        bezierPath.moveToPoint(dotPositions[lines[0].sourceDotIndex])
        for i in 1..<lines.count {
            bezierPath.addLineToPoint(dotPositions[lines[i].sourceDotIndex])
        }
        bezierPath.addLineToPoint(dotPositions[lines[0].sourceDotIndex])
        
        var shape = SKShapeNode(path: bezierPath.CGPath)
        shape.fillColor = UIColor.redColor()
        return shape
    }
}

class GameScene: SKScene {
    override func didMoveToView(view: SKView) {
        UIGraphicsBeginImageContextWithOptions(size, true, 0.0)
        drawBackground()
    }
    
    func drawBackground(){
        backgroundColor = SKColor.whiteColor()
        
        //make dots
        dotPositions = [CGPoint(x: size.width * 0.5, y: size.height * 0.2),
                        CGPoint(x: size.width * 0.2, y: size.height * 0.5),
                        CGPoint(x: size.width * 0.5, y: size.height * 0.8),
                        CGPoint(x: size.width * 0.8, y: size.height * 0.5)]
      
        for position in dotPositions {
            var dot = SKShapeNode(circleOfRadius: 20.0)
            dot.name = "dot"
            dot.fillColor = UIColor.blackColor()
            dot.position = position
            dots += [(dot)]
        }
        
        //make lines
        var edges:[Edge] = []
        edges += [ Edge(sourceDotIndex: 0, destinationDotIndex: 1, hasBeenDrawnByUser: false),
                    Edge(sourceDotIndex: 1, destinationDotIndex: 2, hasBeenDrawnByUser: false),
                    Edge(sourceDotIndex: 2, destinationDotIndex: 3, hasBeenDrawnByUser: false),
                    Edge(sourceDotIndex: 3, destinationDotIndex: 0, hasBeenDrawnByUser: false)]
        
        //make shape
        shape = Shape(lines: edges)
        
        //draw lines
        for edge in shape.lines {
            addChild(edge.makeEdgeNode(UIColor.grayColor()))
        }
        
        //draw dots
        for dot in dots{
            addChild(dot)
        }
    }
    
    override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
        for touch: AnyObject in touches {
            let location = touch.locationInNode(self)
            
            for lineIndex in 0..<shape.lines.count {
                let line = shape.lines[lineIndex]
                if CGRectContainsPoint(line.getEdgeFrame(), location) {
                    shape.lines[lineIndex].hasBeenDrawnByUser = true
                    addChild(line.makeEdgeNode(UIColor.blackColor()))
                    if shape.hasBeenCompleted() {
                        addChild(shape.makeShapeNode())
                    }
                }
            }
        }
    }
}
