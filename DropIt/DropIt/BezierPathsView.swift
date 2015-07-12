//
//  BezierPathsView.swift
//  DropIt
//
//  Created by Elizabeth Wei on 7/11/15.
//  Copyright (c) 2015 Elizabeth Wei. All rights reserved.
//

import UIKit

class BezierPathsView: UIView {

    var bezierPaths = [String: UIBezierPath]()
    
    func setPath(path: UIBezierPath?, named name: String) {
        bezierPaths[name] = path
        setNeedsDisplay()
    }
    
    override func drawRect(rect: CGRect) {
        for(_, path) in bezierPaths {
            path.stroke()
        }
    }
}
