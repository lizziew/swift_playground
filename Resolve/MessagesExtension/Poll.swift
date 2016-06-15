//
//  Poll.swift
//  Resolve
//
//  Created by Elizabeth Wei on 6/14/16.
//  Copyright © 2016 Elizabeth Wei. All rights reserved.
//

import Foundation
import Messages

class Poll {
    var title: String
    
    var onlyOneVote: Bool
    
    var choices: [String]
    
    var numVotes: [Int]
    
    init(message: MSMessage?) {
        self.title = "default title"
        self.onlyOneVote = true
        self.choices = ["asdf"]
        self.numVotes = [1]
    }
}
