//
//  GameScene.swift
//  Tessature
//
//  Created by Elizabeth Wei on 6/10/15.
//  Copyright (c) 2015 Elizabeth Wei. All rights reserved.
//

import SpriteKit

let dotRadius = CGFloat(10.0)

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
    
    func dotProduct(vector1: CGPoint, vector2: CGPoint) -> CGFloat {
        return vector1.x * vector2.x + vector1.y * vector2.y
    }
    
    func vectorLength(vector: CGPoint) -> CGFloat {
        return sqrt(vector.x * vector.x + vector.y * vector.y)
    }
    
    func distanceToEdge(point: CGPoint) -> CGFloat {
        let sourceDot = dotPositions[self.sourceDotIndex]
        let destinationDot = dotPositions[self.destinationDotIndex]
        
        var vector1 = CGPointMake(sourceDot.x - destinationDot.x, sourceDot.y - destinationDot.y)
        let vector1Length = vectorLength(vector1)
        vector1.x /= vector1Length
        vector1.y /= vector1Length
        
        let vector2 = CGPointMake(point.x - destinationDot.x, point.y - destinationDot.y)
        
        let dot1 = dotProduct(vector1, vector2: vector2)
        
        if(dot1 < 0 || dot1 > vector1Length) {
            return CGFloat.max
        }
        
        let closestPoint = CGPointMake(destinationDot.x + dot1 * vector1.x, destinationDot.y + dot1 * vector1.y)
        
        return vectorLength(CGPointMake(point.x - closestPoint.x, point.y - closestPoint.y))
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
        removeAllChildren()
        deleteStartOverButton()
        
        backgroundColor = SKColor.whiteColor()
        
        let diagramHeight = 0.8 * size.height
        let labelHeight = size.height - diagramHeight
        
        //make dots
        dotPositions = [CGPoint(x: size.width * 0.5, y: diagramHeight * 0.5 + labelHeight),
                        CGPoint(x: size.width * 0.5, y: diagramHeight * 0.75 + labelHeight),
                        CGPoint(x: size.width * 0.65, y: diagramHeight * 0.95 + labelHeight),
                        CGPoint(x: size.width * 0.65, y: diagramHeight * 0.7 + labelHeight),
                        CGPoint(x: size.width * 0.9, y: diagramHeight * 0.7 + labelHeight),
                        CGPoint(x: size.width * 0.75, y: diagramHeight * 0.5 + labelHeight),
                        CGPoint(x: size.width * 0.9, y: diagramHeight * 0.3 + labelHeight),
                        CGPoint(x: size.width * 0.65, y: diagramHeight * 0.3 + labelHeight),
                        CGPoint(x: size.width * 0.65, y: diagramHeight * 0.1 + labelHeight),
                        CGPoint(x: size.width * 0.5, y: diagramHeight * 0.25 + labelHeight),
                        CGPoint(x: size.width * 0.35, y: diagramHeight * 0.1 + labelHeight),
                        CGPoint(x: size.width * 0.35, y: diagramHeight * 0.3 + labelHeight),
                        CGPoint(x: size.width * 0.1, y: diagramHeight * 0.3 + labelHeight),
                        CGPoint(x: size.width * 0.25, y: diagramHeight * 0.5 + labelHeight),
                        CGPoint(x: size.width * 0.1, y: diagramHeight * 0.7 + labelHeight),
                        CGPoint(x: size.width * 0.35, y: diagramHeight * 0.7 + labelHeight),
                        CGPoint(x: size.width * 0.35, y: diagramHeight * 0.95 + labelHeight),
                        CGPoint(x: size.width * 0.5, y: diagramHeight - dotRadius + labelHeight),
                        CGPoint(x: size.width - dotRadius, y: diagramHeight - dotRadius + labelHeight),
                        CGPoint(x: size.width - dotRadius, y: dotRadius*2 + labelHeight),
                        CGPoint(x: dotRadius, y: dotRadius*2 + labelHeight),
                        CGPoint(x: dotRadius, y: diagramHeight - dotRadius + labelHeight)]
        
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
                    Edge(sourceDotIndex: 12, destinationDotIndex: 11, hasBeenDrawnByUser: false),
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
                    Edge(sourceDotIndex: 20, destinationDotIndex: 11, hasBeenDrawnByUser: false),
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
    
    func deleteStartOverButton() {
        let subviews = self.view!.subviews as! [UIView]
        for v in subviews {
            if let button = v as? UIButton {
                if button.currentTitle == "Start Over" {
                    button.removeFromSuperview()
                }
            }
        }
    }
    
    override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
        for touch: AnyObject in touches {
            let location = touch.locationInNode(self)
            
            for edgeIndex in 0..<edges.count {
                if(edges[edgeIndex].distanceToEdge(location) < 16) {
                    edges[edgeIndex].hasBeenDrawnByUser = true
                    addChild(edges[edgeIndex].makeEdgeNode(UIColor.blackColor()))
                    
                    for shapeIndex in 0..<shapes.count {
                        if shapes[shapeIndex].hasBeenCompleted() {
                            addChild(shapes[shapeIndex].makeShapeNode())
                            shapes.removeAtIndex(shapeIndex)
                            break
                        }
                    }
                    
                    if shapes.count == 0 {
                        removeAllChildren()
                        println("Round over")
                        
                        var gameOverText = SKLabelNode(text: "Round over!")
                        gameOverText.position = CGPointMake(size.width/2, size.height/2)
                        gameOverText.fontColor = UIColor.blackColor()
                        addChild(gameOverText)
                    
                        let button = UIButton(frame: CGRectMake(size.width * 0.5 - 100, size.height * 0.8 - 25, 200, 50))
                        button.backgroundColor = UIColor.greenColor()
                        button.setTitle("Start Over", forState: UIControlState.Normal)
                        button.addTarget(self, action: "drawBackground", forControlEvents: UIControlEvents.TouchUpInside)
                        
                    
                        self.view!.addSubview(button)
                    }
                    
                    break
                }
            }
        }
    }
}
