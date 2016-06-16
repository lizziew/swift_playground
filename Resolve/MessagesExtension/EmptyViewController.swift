//
//  EmptyViewController.swift
//  Resolve
//
//  Created by Elizabeth Wei on 6/16/16.
//  Copyright © 2016 Elizabeth Wei. All rights reserved.
//

import UIKit

class EmptyViewController: UIViewController {
    static let storyboardIdentifier = "EmptyViewController"
    
    @IBOutlet weak var instructionLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColorFromHex(rgbValue: 0x88d8b0)
        
        instructionLabel.backgroundColor = UIColorFromHex(rgbValue: 0xffcc5c)
        instructionLabel.layer.masksToBounds = true
        instructionLabel.layer.cornerRadius = 8
    }

    func UIColorFromHex(rgbValue:UInt32, alpha:Double=1.0)->UIColor {
        let red = CGFloat((rgbValue & 0xFF0000) >> 16)/256.0
        let green = CGFloat((rgbValue & 0xFF00) >> 8)/256.0
        let blue = CGFloat(rgbValue & 0xFF)/256.0
        
        return UIColor(red:red, green:green, blue:blue, alpha:CGFloat(alpha))
    }
}
