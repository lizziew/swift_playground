//
//  GameScene.swift
//  Tessature
//
//  Created by Elizabeth Wei on 6/10/15.
//  Copyright (c) 2015 Elizabeth Wei. All rights reserved.
//

import SpriteKit
import GameKit

let dotRadius = CGFloat(10.0)

var edges = [Edge]()
var shapes = [Shape]()

var dotPositions = [CGPoint]()

struct Edge {
    var sourceDotIndex = -1
    var destinationDotIndex = -1
    var hasBeenDrawnByUser = false
    
    func getEdgeFrame() -> CGRect {
        let sourceDot = dotPositions[self.sourceDotIndex]
        let destinationDot = dotPositions[self.destinationDotIndex]
        
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
    var isComplete = false
    
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
    
    func makeShapeNode(playerColor: UIColor) -> SKShapeNode {
        var bezierPath = UIBezierPath()
        
        var shapeOutline = [CGPoint]()
        shapeOutline += [dotPositions[edges[edgeIndexArray[0]].sourceDotIndex]]
        for edgeIndex in 1..<edgeIndexArray.count {
            shapeOutline += [getOtherPoint(shapeOutline[shapeOutline.count-1], currentEdge: edges[edgeIndexArray[edgeIndex]])]
        }
        
        bezierPath.moveToPoint(shapeOutline[0])
        for i in 1..<shapeOutline.count {
            bezierPath.addLineToPoint(shapeOutline[i])
        }
        bezierPath.closePath()
        
        var shape = SKShapeNode(path: bezierPath.CGPath)
        shape.fillColor = playerColor
        shape.alpha = 0.5
        return shape
    }
}

class GameScene: SKScene, GKLocalPlayerListener {
    var contentCreated = false
    var numberOfCompletedShapes = 0
    var match = GKMatch()
    
    var thisPlayerName = GKLocalPlayer.localPlayer().alias
    var thisPlayerColor = UIColor.whiteColor()
    var thisPlayerLabel = UILabel()
    var thisPlayerScore = 0
    
    var otherPlayer = GKPlayer()
    var otherPlayerName = "" 
    var otherPlayerColor = UIColor.whiteColor() 
    var otherPlayerLabel = UILabel()
    var otherPlayerScore = 0
    
    var turnLabel = UILabel()
    
    override func didMoveToView(view: SKView) {
        if self.contentCreated == false {
            drawBackground()
            self.contentCreated = true
        }
    }
    
    func clearRound() {
        dotPositions = []
        shapes = []
        edges = []
    }
    
    func drawBackground(){
        clearRound()
        
        backgroundColor = SKColor.whiteColor()
        scaleMode = SKSceneScaleMode.Fill
        drawLabels()
        
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
        
        var dots = [SKShapeNode]()
        for position in dotPositions {
            var dot = SKShapeNode(circleOfRadius: dotRadius)
            dot.name = "dot"
            dot.fillColor = UIColor.blackColor()
            dot.strokeColor = UIColor.blackColor()
            dot.position = position
            dots += [(dot)]
        }
        
        //make edges
        if edges.count == 0 {
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
        }

        //make shapes
        if shapes.count == 0 {
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
        }

        for edge in edges {
            addChild(edge.makeEdgeNode(UIColor.grayColor()))
        }
        
        //loadUpdatedMatchData()
        
        //draw dots
        for dot in dots{
            addChild(dot)
        }
    }
    
    func drawLabels() {
        thisPlayerLabel = UILabel(frame: CGRectMake(15, size.height * 0.9 - 40, 150, 60))
        thisPlayerLabel.text = "\(thisPlayerName)\n\(thisPlayerScore)"
        thisPlayerLabel.textColor = UIColor.whiteColor()
        thisPlayerLabel.textAlignment = NSTextAlignment.Center
        thisPlayerLabel.numberOfLines = 0
        thisPlayerLabel.backgroundColor = thisPlayerColor
        
        otherPlayerLabel = UILabel(frame: CGRectMake(size.width - 165, size.height * 0.9 - 40, 150, 60))
        otherPlayerLabel.text = "\(otherPlayerName)\n\(otherPlayerScore)"
        otherPlayerLabel.textColor = UIColor.whiteColor()
        otherPlayerLabel.textAlignment = NSTextAlignment.Center
        otherPlayerLabel.numberOfLines = 0
        otherPlayerLabel.backgroundColor = otherPlayerColor
        
        turnLabel = UILabel(frame: CGRectMake(0, size.height * 0.9 - 70, size.width, 20))
        turnLabel.textAlignment = NSTextAlignment.Center
        
        turnLabel.text = "TBD"
//        if isThisPlayerTurn {
//            turnLabel.text = "Your Turn"
//        }
//        else {
//            turnLabel.text = "Their Turn"
//        }
        
        self.view!.addSubview(thisPlayerLabel)
        self.view!.addSubview(otherPlayerLabel)
        self.view!.addSubview(turnLabel)
    }
    
    override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
//        if !isThisPlayerTurn {
//            return
//        }
        
        for touch: AnyObject in touches {
            let location = touch.locationInNode(self)
            
            for edgeIndex in 0..<edges.count {
                if(edges[edgeIndex].distanceToEdge(location) < 16 && !edges[edgeIndex].hasBeenDrawnByUser) {
                    edges[edgeIndex].hasBeenDrawnByUser = true
                    addChild(edges[edgeIndex].makeEdgeNode(UIColor.blackColor()))
                    
                    for shapeIndex in 0..<shapes.count {
                        if shapes[shapeIndex].isComplete == false && shapes[shapeIndex].hasBeenCompleted() {
                            addChild(shapes[shapeIndex].makeShapeNode(thisPlayerColor))
                            numberOfCompletedShapes++
                            shapes[shapeIndex].isComplete = true
                        }
                    }
                    
                    if shapes.count == numberOfCompletedShapes {
                        println("Round over")
                        
                        let crossFade = SKTransition.crossFadeWithDuration(2.0)
                    
                        let endScene = EndScene()
                        endScene.size = self.size
                        self.view?.presentScene(endScene, transition: crossFade)
                    }
                    
                    break
                }
            }
        }
        
        advanceTurn()
    }
    
    func updateMatchData() {
        var dictionary = [NSString: [Int]]()
        
        var shapeData = [Int](count: shapes.count, repeatedValue: 0)
        for shapeIndex in 0..<shapes.count {
            if(shapes[shapeIndex].isComplete) {
                shapeData[shapeIndex] = 1
            }
        }
        
        var edgeData = [Int](count: edges.count, repeatedValue: 0)
        for edgeIndex in 0..<edges.count {
            if(edges[edgeIndex].hasBeenDrawnByUser) {
                edgeData[edgeIndex] = 1
            }
        }
        
        dictionary["shapes"] = shapeData
        dictionary["edges"] = edgeData
        
        var error: NSError?
        let jsonData = NSJSONSerialization.dataWithJSONObject(dictionary, options: NSJSONWritingOptions.PrettyPrinted, error: &error)
        match.sendDataToAllPlayers(jsonData, withDataMode: GKMatchSendDataMode.Unreliable, error: &error)
    }
    
    func advanceTurn() {
        println("advance turn")
        updateMatchData() 
        
        if turnLabel.text == "Your Turn" {
            turnLabel.text = "Their Turn"
        }
        else {
            turnLabel.text = "Your Turn"
        }
    }
    
    func dataReceived(data: NSData) {
        println("dealing with data")
        var error: NSError?
        var updatedMatchData: [NSString : [Int]] = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: &error) as! [NSString: [Int]]
        
        if(updatedMatchData["edges"] != nil) {
            var edgeData = updatedMatchData["edges"]!
            for edgeIndex in 0..<edgeData.count {
                if(edgeData[edgeIndex] == 1) {
                    edges[edgeIndex].hasBeenDrawnByUser = true
                    self.addChild(edges[edgeIndex].makeEdgeNode(UIColor.blackColor()))
                }
            }
        }
        
        if(updatedMatchData["shapes"] != nil) {
            var shapeData = updatedMatchData["shapes"]!
            for shapeIndex in 0..<shapeData.count {
                if(shapeData[shapeIndex] == 1) {
                    shapes[shapeIndex].isComplete = true
                    self.addChild(shapes[shapeIndex].makeShapeNode(self.thisPlayerColor))
                }
            }
        }
    }
    
//    var isThisPlayerTurn: Bool {
//        get {
//            return GKLocalPlayer.localPlayer().playerID == match.currentParticipant.player.playerID
//        }
//    }
}
