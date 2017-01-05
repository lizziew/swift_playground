//
//  TaskTableViewCell.swift
//  PlanForMe
//
//  Created by Elizabeth Wei on 1/1/17.
//  Copyright © 2017 Elizabeth Wei. All rights reserved.
//

import UIKit

class TaskTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var priorityLabel: UILabel!
    @IBOutlet weak var calendarView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        calendarView.layer.cornerRadius = calendarView.frame.size.width/2
        calendarView.clipsToBounds = true
        calendarView.layer.backgroundColor = UIColor.black.withAlphaComponent(0.5).cgColor
        
        self.selectionStyle = UITableViewCellSelectionStyle.none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
