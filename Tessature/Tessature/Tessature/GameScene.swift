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
    
    func getOtherPoint(previousDot: CGPoint, currentEdge: Edge) -> CGPoint {
        let sourceDot = dotPositions[currentEdge.sourceDotIndex]
        let destinationDot = dotPositions[currentEdge.destinationDotIndex]
        if(previousDot == sourceDot) {
            return destinationDot
        }
        else {
            return sourceDot
        }
    }
    
    func makeShapeNode() -> SKShapeNode {
        var bezierPath = UIBezierPath()
        
        var shapeOutline = [CGPoint]()
        shapeOutline += [dotPositions[edges[edgeIndexArray[0]].sourceDotIndex]]
        for edgeIndex in 1..<edgeIndexArray.count {
            shapeOutline += [getOtherPoint(shapeOutline[shapeOutline.count-1], currentEdge: edges[edgeIndexArray[edgeIndex]])]
        }
        shapeOutline += [dotPositions[edges[edgeIndexArray[0]].sourceDotIndex]]
        
        for i in 0..<shapeOutline.count {
            println(shapeOutline[i])
        }
        
        bezierPath.moveToPoint(shapeOutline[0])
        for i in 1..<shapeOutline.count {
            bezierPath.addLineToPoint(shapeOutline[i])
        }
        
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
        dotPositions = [CGPoint(x: size.width * 0.5, y: size.height * 0.5),
                        CGPoint(x: size.width * 0.5, y: size.height * 0.75),
                        CGPoint(x: size.width * 0.65, y: size.height * 0.95),
                        CGPoint(x: size.width * 0.65, y: size.height * 0.7),
                        CGPoint(x: size.width * 0.9, y: size.height * 0.7),
                        CGPoint(x: size.width * 0.75, y: size.height * 0.5),
                        CGPoint(x: size.width * 0.9, y: size.height * 0.3),
                        CGPoint(x: size.width * 0.65, y: size.height * 0.3),
                        CGPoint(x: size.width * 0.65, y: size.height * 0.05),
                        CGPoint(x: size.width * 0.5, y: size.height * 0.25),
                        CGPoint(x: size.width * 0.35, y: size.height * 0.05),
                        CGPoint(x: size.width * 0.35, y: size.height * 0.3),
                        CGPoint(x: size.width * 0.1, y: size.height * 0.3),
                        CGPoint(x: size.width * 0.25, y: size.height * 0.5),
                        CGPoint(x: size.width * 0.1, y: size.height * 0.7),
                        CGPoint(x: size.width * 0.35, y: size.height * 0.7),
                        CGPoint(x: size.width * 0.35, y: size.height * 0.95),
                        CGPoint(x: size.width * 0.5, y: size.height - dotRadius),
                        CGPoint(x: size.width - dotRadius, y: size.height - dotRadius),
                        CGPoint(x: size.width - dotRadius, y: dotRadius),
                        CGPoint(x: dotRadius, y: dotRadius),
                        CGPoint(x: dotRadius, y: size.height - dotRadius)]
        
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
                    Edge(sourceDotIndex: 4, destinationDotIndex: 3, hasBeenDrawnByUser: false),
                    Edge(sourceDotIndex: 5, destinationDotIndex: 6, hasBeenDrawnByUser: false),
                    Edge(sourceDotIndex: 6, destinationDotIndex: 7, hasBeenDrawnByUser: false),
                    Edge(sourceDotIndex: 7, destinationDotIndex: 0, hasBeenDrawnByUser: false),
                    Edge(sourceDotIndex: 0, destinationDotIndex: 9, hasBeenDrawnByUser: false),
                    Edge(sourceDotIndex: 9, destinationDotIndex: 8, hasBeenDrawnByUser: false),
                    Edge(sourceDotIndex: 8, destinationDotIndex: 7, hasBeenDrawnByUser: false),
                    Edge(sourceDotIndex: 9, destinationDotIndex: 10, hasBeenDrawnByUser: false),
                    Edge(sourceDotIndex: 10, destinationDotIndex: 11, hasBeenDrawnByUser: false),
                    Edge(sourceDotIndex: 11, destinationDotIndex: 0, hasBeenDrawnByUser: false),
                    Edge(sourceDotIndex: 0, destinationDotIndex: 13, hasBeenDrawnByUser: false),
                    Edge(sourceDotIndex: 13, destinationDotIndex: 12, hasBeenDrawnByUser: false),
                    Edge(sourceDotIndex: 12, destinationDotIndex: 11, hasBeenDrawnByUser: false),//18
                    Edge(sourceDotIndex: 13, destinationDotIndex: 14, hasBeenDrawnByUser: false),
                    Edge(sourceDotIndex: 14, destinationDotIndex: 15, hasBeenDrawnByUser: false),
                    Edge(sourceDotIndex: 15, destinationDotIndex: 0, hasBeenDrawnByUser: false),
                    Edge(sourceDotIndex: 1, destinationDotIndex: 16, hasBeenDrawnByUser: false),
                    Edge(sourceDotIndex: 16, destinationDotIndex: 15, hasBeenDrawnByUser: false),
                    Edge(sourceDotIndex: 1, destinationDotIndex: 17, hasBeenDrawnByUser: false),
                    Edge(sourceDotIndex: 17, destinationDotIndex: 18, hasBeenDrawnByUser: false),
                    Edge(sourceDotIndex: 18, destinationDotIndex: 19, hasBeenDrawnByUser: false),
                    Edge(sourceDotIndex: 19, destinationDotIndex: 7, hasBeenDrawnByUser: false),
                    Edge(sourceDotIndex: 19, destinationDotIndex: 20, hasBeenDrawnByUser: false),
                    Edge(sourceDotIndex: 20, destinationDotIndex: 11, hasBeenDrawnByUser: false),//29
                    Edge(sourceDotIndex: 20, destinationDotIndex: 21, hasBeenDrawnByUser: false),
                    Edge(sourceDotIndex: 21, destinationDotIndex: 17, hasBeenDrawnByUser: false)]
        
        //make shapes
        shapes += [ Shape(edgeIndexArray: [0,1,2,3]),
                    Shape(edgeIndexArray: [3,4,5,6]),
                    Shape(edgeIndexArray: [4,7,8,9]),
                    Shape(edgeIndexArray: [9,10,11,12]),
                    Shape(edgeIndexArray: [10,13,14,15]),
                    Shape(edgeIndexArray: [15,16,17,18]),
                    Shape(edgeIndexArray: [16,19,20,21]),
                    Shape(edgeIndexArray: [0,21,23,22]),
                    Shape(edgeIndexArray: [8,7,5,6,2,1,24,25,26,27]),
                    Shape(edgeIndexArray: [24,22,23,20,19,17,18,29,30,31]),
                    Shape(edgeIndexArray: [27,28,29,14,13,11,12])]
        
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
            
            /*let node = self.nodeAtPoint(location)
            println(node.name)*/
            
            for edgeIndex in 0..<edges.count {
                if(CGRectContainsPoint(edges[edgeIndex].getEdgeFrame(), location)) {
                    edges[edgeIndex].hasBeenDrawnByUser = true
                    
                    let rect = SKShapeNode(rect: edges[edgeIndex].getEdgeFrame())
                    rect.strokeColor = UIColor.yellowColor()
                    addChild(rect)
                    
                    addChild(edges[edgeIndex].makeEdgeNode(UIColor.blackColor()))
                    for shape in shapes {
                        if shape.hasBeenCompleted() {
                            addChild(shape.makeShapeNode())
                        }
                    }
                    
                    break
                }
            }
        }
    }
}
