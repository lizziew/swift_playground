//
//  VoteViewController.swift
//  Resolve
//
//  Created by Elizabeth Wei on 6/15/16.
//  Copyright © 2016 Elizabeth Wei. All rights reserved.
//

import UIKit

class VoteViewController: UIViewController {
    static let storyboardIdentifier = "VoteViewController"
    weak var delegate: VoteViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColorFromHex(rgbValue: 0x88d8b0)
    }

    func UIColorFromHex(rgbValue:UInt32, alpha:Double=1.0)->UIColor {
        let red = CGFloat((rgbValue & 0xFF0000) >> 16)/256.0
        let green = CGFloat((rgbValue & 0xFF00) >> 8)/256.0
        let blue = CGFloat(rgbValue & 0xFF)/256.0
        
        return UIColor(red:red, green:green, blue:blue, alpha:CGFloat(alpha))
    }
}

protocol VoteViewControllerDelegate: class {
    func voteViewControllerDidSelectVote(_ controller: VoteViewController)
}
