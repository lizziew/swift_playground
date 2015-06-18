//
//  StartViewController.swift
//  Tessature
//
//  Created by Elizabeth Wei on 6/12/15.
//  Copyright (c) 2015 Elizabeth Wei. All rights reserved.
//

import UIKit

class StartViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func backToStartScreen(segue: UIStoryboardSegue) {
        println("user quit game");
    }
}
