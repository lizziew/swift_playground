//
//  PenguinBehavior.swift
//  PenguinFactory
//
//  Created by Elizabeth Wei on 7/22/15.
//  Copyright (c) 2015 Elizabeth Wei. All rights reserved.
//

import UIKit

class PenguinBehavior: UIDynamicBehavior {
    let gravity = UIGravityBehavior()
    
    override init() {
        super.init()
        gravity.magnitude = 0.1
        addChildBehavior(gravity)
    }
    
    func addEgg(egg: UIView) {
        dynamicAnimator?.referenceView?.addSubview(egg)
        gravity.addItem(egg)
    }
    
    func removeEgg(egg: UIView) {
        gravity.removeItem(egg)
        egg.removeFromSuperview()
    }
}
