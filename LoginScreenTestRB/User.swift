//
//  User.swift
//  LoginScreenTestRB
//
//  Created by Alex Voronov on 16.11.18.
//  Copyright © 2018 Alex Voronov. All rights reserved.
//


class User {
    
    init(id: Int, firstName: String?, lastName: String?, avatar: String?) {
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.avatar = avatar
    }
    
    var id: Int
    var firstName: String?
    var lastName: String?
    var avatar: String?
}
