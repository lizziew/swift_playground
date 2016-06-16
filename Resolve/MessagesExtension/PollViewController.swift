//
//  PollViewController.swift
//  Resolve
//
//  Created by Elizabeth Wei on 6/14/16.
//  Copyright © 2016 Elizabeth Wei. All rights reserved.
//

import UIKit

class PollViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    static let storyboardIdentifier = "PollViewController"
    
    var pollType: String? = nil
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var addOptButton: UIButton!
    
    @IBOutlet weak var optionsLabel: UILabel!
    @IBOutlet weak var optionsLabel2: UILabel!
    
    @IBOutlet weak var sendButton: UIButton!
    
    weak var delegate: PollViewControllerDelegate?
    
    var dateText = ""
    var pickerText = ""
    
    var currDateOptions = [Date]() {
        didSet {
            let dateFormatter = DateFormatter()
            if pollType == "date" {
                dateFormatter.dateFormat = "MMM dd yyyy"
            }
            else if pollType == "time" {
                dateFormatter.dateFormat = "HH:mm a"
            }
            
            var opts = ""
            var opts2 = ""
            
            if currDateOptions.count < 5 {
                for i in 0..<currDateOptions.count {
                    opts += dateFormatter.string(from: currDateOptions[i])
                    if i != currDateOptions.count-1 {
                        opts += "\n"
                    }
                }
            }
            else {
                for i in 0..<4 {
                    opts += dateFormatter.string(from: currDateOptions[i])
                    if i != 3 {
                        opts += "\n"
                    }
                }
                for i in 4..<currDateOptions.count {
                    opts2 += dateFormatter.string(from: currDateOptions[i])
                    if i != currDateOptions.count-1 {
                        opts2 += "\n"
                    }
                }
            }
            
            optionsLabel.text = opts
            optionsLabel2.text = opts2
        }
    }
    
    var currPickerOptions = [String]() {
        didSet {
            var opts = ""
            var opts2 = ""
            
            if currPickerOptions.count < 5 {
                for i in 0..<currPickerOptions.count {
                    opts += currPickerOptions[i]
                    if i != currPickerOptions.count-1 {
                        opts += "\n"
                    }
                }
            }
            else {
                for i in 0..<4 {
                    opts += currPickerOptions[i]
                    if i != 3 {
                        opts += "\n"
                    }
                }
                for i in 4..<currPickerOptions.count {
                    opts2 += currPickerOptions[i]
                    if i != currPickerOptions.count-1 {
                        opts2 += "\n"
                    }
                }
            }
            
            optionsLabel.text = opts
            optionsLabel2.text = opts2
        }
    }
    
    let dateDP = UIDatePicker()
    let picker = UIPickerView()
    
    var pickerData = [String]() {
        didSet {
            selectedPickerData = pickerData[0]
        }
    }
    var selectedPickerData = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColorFromHex(rgbValue: 0x88d8b0)
        
        titleLabel.backgroundColor = UIColorFromHex(rgbValue: 0xffcc5c)
        titleLabel.layer.masksToBounds = true
        titleLabel.layer.cornerRadius = 8
        
        addOptButton.backgroundColor = UIColorFromHex(rgbValue: 0xffcc5c)
        addOptButton.layer.masksToBounds = true
        addOptButton.layer.cornerRadius = 8
        
        sendButton.backgroundColor = UIColorFromHex(rgbValue: 0xffcc5c)
        sendButton.layer.masksToBounds = true
        sendButton.layer.cornerRadius = 8
        
        optionsLabel.backgroundColor = UIColorFromHex(rgbValue: 0xff6f69)
        optionsLabel.layer.masksToBounds = true
        optionsLabel.layer.cornerRadius = 8
        
        optionsLabel2.backgroundColor = UIColorFromHex(rgbValue: 0xff6f69)
        optionsLabel2.layer.masksToBounds = true
        optionsLabel2.layer.cornerRadius = 8
        
        dateDP.frame = CGRect(x: self.view.frame.midX - dateDP.frame.midX, y: self.view.frame.midY - dateDP.frame.midY, width: dateDP.frame.width, height: dateDP.frame.height)
        dateDP.timeZone = TimeZone.local()
        dateDP.backgroundColor = UIColorFromHex(rgbValue: 0xff6f69)
        dateDP.layer.masksToBounds = true
        dateDP.layer.cornerRadius = 8
        
        picker.frame = CGRect(x: self.view.frame.midX - picker.frame.midX, y: self.view.frame.midY - picker.frame.midY, width: picker.frame.width, height: picker.frame.height)
        picker.backgroundColor = UIColorFromHex(rgbValue: 0xff6f69)
        picker.layer.masksToBounds = true
        picker.layer.cornerRadius = 8
        picker.delegate = self
        picker.dataSource = self
        
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
    
    func presentDay() {
        titleLabel.text = "DAY"
        pickerData = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
        self.view.addSubview(picker)
    }
    
    func presentInterval() {
        titleLabel.text = "INTERVAL"
        pickerData = ["Morning", "Afternoon", "Evening", "Night"]
        self.view.addSubview(picker)
    }
    
    func presentTime() {
        titleLabel.text = "TIME"
        dateDP.datePickerMode = UIDatePickerMode.time
        self.view.addSubview(dateDP)
    }
    
    func presentMeal() {
        titleLabel.text = "MEAL"
        pickerData = ["Brunch", "Breakfast", "Lunch", "Dinner"]
        self.view.addSubview(picker)
    }
    
    @IBAction func addOpt(_ sender: UIButton) {
        if pollType == "date" {
            if currDateOptions.count < 8 {
                currDateOptions.append(dateDP.date)
            }
            else {
                let alert = UIAlertController(title: "Warning!", message: "Limited to 8 dates", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
        else if pollType == "time" {
            if currDateOptions.count < 8 {
                currDateOptions.append(dateDP.date)
            }
            else {
                let alert = UIAlertController(title: "Warning!", message: "Limited to 8 times", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
        else if pollType == "interval" {
            if currPickerOptions.count < 4 {
                currPickerOptions.append(selectedPickerData)
            }
            else {
                let alert = UIAlertController(title: "Warning!", message: "Limited to 4 intervals", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
        else if pollType == "day" {
            if currPickerOptions.count < 7 {
                currPickerOptions.append(selectedPickerData)
            }
            else {
                let alert = UIAlertController(title: "Warning!", message: "Limited to 7 days", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
        else if pollType == "meal" {
            if currPickerOptions.count < 4 {
                currPickerOptions.append(selectedPickerData)
            }
            else {
                let alert = UIAlertController(title: "Warning!", message: "Limited to 4 meals", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func sendPoll(_ sender: UIButton) {
        if pollType == "time" || pollType == "date" {
            let dateFormatter = DateFormatter()
            if pollType == "date" {
                dateFormatter.dateFormat = "MMM dd yyyy"
            }
            else if pollType == "time" {
                dateFormatter.dateFormat = "HH:mm a"
            }

            for i in 0..<currDateOptions.count {
                dateText += dateFormatter.string(from: currDateOptions[i])
                if i != currDateOptions.count-1 {
                    dateText += "\n"
                }
            }
            
            delegate?.pollViewControllerDidSelectSend(self)
        }
        else if pollType == "interval" || pollType == "day" || pollType == "meal" {
            for i in 0..<currPickerOptions.count {
                pickerText += currPickerOptions[i]
                if i != currPickerOptions.count-1 {
                    pickerText += "\n"
                }
            }
            delegate?.pollViewControllerDidSelectSend(self)
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedPickerData = pickerData[row]
    }
    
    func UIColorFromHex(rgbValue:UInt32, alpha:Double=1.0)->UIColor {
        let red = CGFloat((rgbValue & 0xFF0000) >> 16)/256.0
        let green = CGFloat((rgbValue & 0xFF00) >> 8)/256.0
        let blue = CGFloat(rgbValue & 0xFF)/256.0
        
        return UIColor(red:red, green:green, blue:blue, alpha:CGFloat(alpha))
    }
}

protocol PollViewControllerDelegate: class {
    func pollViewControllerDidSelectSend(_ controller: PollViewController)
}


