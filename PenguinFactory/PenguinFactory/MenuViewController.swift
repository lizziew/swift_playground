//
//  MenuViewController.swift
//  PenguinFactory
//
//  Created by Elizabeth Wei on 7/21/15.
//  Copyright (c) 2015 Elizabeth Wei. All rights reserved.
//

import UIKit

class MenuViewController: UIViewController {
    @IBAction func goBack(segue: UIStoryboardSegue) {
        println("back to menu!")
    }
    
    override func viewDidLoad() {
        view.backgroundColor = UIColor(red: 0.6, green: 0.88, blue: 0.97, alpha: 1.0)
    }
}
