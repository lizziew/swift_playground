//
//  User.swift
//  Autolayout
//
//  Created by Elizabeth Wei on 7/3/15.
//  Copyright (c) 2015 Elizabeth Wei. All rights reserved.
//

import Foundation

struct User {
    let name: String
    let company: String
    let login: String
    let password: String
    
    static func login(login: String, password: String) -> User? {
        if let user = database[login] {
            if user.password == password {
                return user
            }
        }
        
        return nil
    }
    
    static let database: [String: User] = {
        var theDatabase = [String: User]()
        for user in [User(name: "Lizzie Wei", company: "Example Company", login: "ewei", password: "foo")] {
            theDatabase[user.login] = user
        }
        return theDatabase
    }()
}