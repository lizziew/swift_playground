//
//  PollViewController.swift
//  Resolve
//
//  Created by Elizabeth Wei on 6/14/16.
//  Copyright © 2016 Elizabeth Wei. All rights reserved.
//

import UIKit

class PollViewController: UIViewController {
    static let storyboardIdentifier = "PollViewController"
    
    var pollType: String? = nil
    
    @IBOutlet weak var titleLabel: UILabel!
    
    let dateDP = UIDatePicker()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColorFromHex(rgbValue: 0x88d8b0)
        
        titleLabel.backgroundColor = UIColorFromHex(rgbValue: 0xffcc5c)
        titleLabel.layer.masksToBounds = true
        titleLabel.layer.cornerRadius = 8
        
//        dateDP.frame = CGRect(x: self.view.frame.midX - dateDP.frame.midX, y: self.view.frame.midY - dateDP.frame.midY, width: dateDP.frame.width, height: dateDP.frame.height)
        dateDP.frame = CGRect(x: self.view.frame.midX - dateDP.frame.midX, y: titleLabel.frame.origin.y + titleLabel.frame.size.height + 10, width: dateDP.frame.width, height: dateDP.frame.height)
        dateDP.timeZone = TimeZone.local()
        dateDP.backgroundColor = UIColorFromHex(rgbValue: 0xff6f69)
        dateDP.layer.masksToBounds = true
        dateDP.layer.cornerRadius = 8
        
        if pollType == "date" {
            presentDate()
        }
        else if pollType == "day" {
            presentDay()
        }
        else if pollType == "interval" {
            presentInterval()
        }
        else if pollType == "time" {
            presentTime()
        }
        else if pollType == "meal" {
            presentMeal()
        }
    }
    
    func presentDate() {
        titleLabel.text = "DATE"
        dateDP.datePickerMode = UIDatePickerMode.date
        self.view.addSubview(dateDP)
    }
    
    func onDidChangeDate(sender: UIDatePicker){
        print("GOT HERE")
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMM yyyy"
        let selectedDate = dateFormatter.string(from: sender.date)
        print(selectedDate)
    }
    
    func presentDay() {
        titleLabel.text = "DAY"
    }
    
    func presentInterval() {
        titleLabel.text = "INTERVAL"
    }
    
    func presentTime() {
        titleLabel.text = "TIME"
    }
    
    func presentMeal() {
        titleLabel.text = "MEAL"
    }
    
    func UIColorFromHex(rgbValue:UInt32, alpha:Double=1.0)->UIColor {
        let red = CGFloat((rgbValue & 0xFF0000) >> 16)/256.0
        let green = CGFloat((rgbValue & 0xFF00) >> 8)/256.0
        let blue = CGFloat(rgbValue & 0xFF)/256.0
        
        return UIColor(red:red, green:green, blue:blue, alpha:CGFloat(alpha))
    }
}
