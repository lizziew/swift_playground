//
//  CalendarTableViewCell.swift
//  PlanForMe
//
//  Created by Elizabeth Wei on 1/4/17.
//  Copyright © 2017 Elizabeth Wei. All rights reserved.
//

import UIKit

class CalendarTableViewCell: UITableViewCell {

    @IBOutlet weak var calendarLabel: UILabel!
    @IBOutlet weak var checkbox: UIButton!
    
    var tapAction: ((CalendarTableViewCell) -> Void)?
    
    @IBAction func check(_ sender: UIButton) {
        tapAction?(self)
    }
    
    var checked = true
    
    override func awakeFromNib() {
        super.awakeFromNib()
    
        self.selectionStyle = UITableViewCellSelectionStyle.none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
