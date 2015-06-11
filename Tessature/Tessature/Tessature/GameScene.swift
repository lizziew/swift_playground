//
//  GameScene.swift
//  Tessature
//
//  Created by Elizabeth Wei on 6/10/15.
//  Copyright (c) 2015 Elizabeth Wei. All rights reserved.
//

import SpriteKit

let dotRadius = CGFloat(10.0)
var prevDot = SKShapeNode()
var dots = [SKShapeNode]()
var edges = [Edge]()
var shapes = [Shape]()
var dotPositions = [CGPoint]()

struct Edge {
    var sourceDotIndex = -1
    var destinationDotIndex = -1
    var hasBeenDrawnByUser = false
    
    func getEdgeFrame() -> CGRect {
        let sourceDot = dots[self.sourceDotIndex].position
        let destinationDot = dots[self.destinationDotIndex].position
        
        var originX = min(sourceDot.x, destinationDot.x)
        var originY = min(sourceDot.y, destinationDot.y)
        
        var width = max(sourceDot.x, destinationDot.x) - originX
        var height = max(sourceDot.y, destinationDot.y) - originY
        
        if(width == 0) {
            width = dotRadius*2
            originX -= dotRadius
        }
        if(height == 0) {
            height = dotRadius*2
            originY -= dotRadius
        }
        
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
    var edgeIndexArray: [Int]
    
    init(edgeIndexArray:[Int]) {
        self.edgeIndexArray = edgeIndexArray
    }
    
    func hasBeenCompleted() -> Bool {
        for i in 0..<edgeIndexArray.count {
            if edges[edgeIndexArray[i]].hasBeenDrawnByUser == false {
                return false
            }
        }
        return true
    }
    
    func makeShapeNode() -> SKShapeNode {
        var bezierPath = UIBezierPath()
        bezierPath.moveToPoint(dotPositions[edges[edgeIndexArray[0]].sourceDotIndex])
        for i in 1..<edgeIndexArray.count {
            bezierPath.addLineToPoint(dotPositions[edges[edgeIndexArray[i]].sourceDotIndex])
        }
        bezierPath.addLineToPoint(dotPositions[edges[edgeIndexArray[0]].sourceDotIndex])
        
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
                        CGPoint(x: size.width * 0.8, y: size.height * 0.5),
                        CGPoint(x: size.width - dotRadius, y: dotRadius),
                        CGPoint(x: size.width * 0.5, y: dotRadius),
                        CGPoint(x: size.width - dotRadius, y: size.height * 0.5)]
        
        for position in dotPositions {
            var dot = SKShapeNode(circleOfRadius: dotRadius)
            dot.name = "dot"
            dot.fillColor = UIColor.blackColor()
            dot.position = position
            dots += [(dot)]
        }
        
        //make edges
        edges += [  Edge(sourceDotIndex: 0, destinationDotIndex: 1, hasBeenDrawnByUser: false),
                    Edge(sourceDotIndex: 1, destinationDotIndex: 2, hasBeenDrawnByUser: false),
                    Edge(sourceDotIndex: 2, destinationDotIndex: 3, hasBeenDrawnByUser: false),
                    Edge(sourceDotIndex: 3, destinationDotIndex: 0, hasBeenDrawnByUser: false),
                    Edge(sourceDotIndex: 0, destinationDotIndex: 5, hasBeenDrawnByUser: false),
                    Edge(sourceDotIndex: 5, destinationDotIndex: 4, hasBeenDrawnByUser: false),
                    Edge(sourceDotIndex: 4, destinationDotIndex: 6, hasBeenDrawnByUser: false),
                    Edge(sourceDotIndex: 6, destinationDotIndex: 3, hasBeenDrawnByUser: false)]
        
        //make shapes
        shapes += [ Shape(edgeIndexArray: [0,1,2,3]),
                    Shape(edgeIndexArray: [3,4,5,6,7])]
        
        //draw edges
        for edge in edges {
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
            
            for edgeIndex in 0..<edges.count {
                if(CGRectContainsPoint(edges[edgeIndex].getEdgeFrame(), location)) {
                    edges[edgeIndex].hasBeenDrawnByUser = true
                    
                    /*let rect = SKShapeNode(rect: edges[edgeIndex].getEdgeFrame())
                    rect.strokeColor = UIColor.redColor()
                    addChild(rect)*/
                    
                    addChild(edges[edgeIndex].makeEdgeNode(UIColor.blackColor()))
                    for shape in shapes {
                        if shape.hasBeenCompleted() {
                            addChild(shape.makeShapeNode())
                        }
                    }
                }
            }
        }
    }
}
