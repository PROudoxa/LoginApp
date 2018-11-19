//
//  AppDefaults.swift
//  LoginScreenTestRB
//
//  Created by Alex Voronov on 18.11.18.
//  Copyright © 2018 Alex Voronov. All rights reserved.
//

import Foundation
import UIKit


enum StoryboardIds: String {
    
    case HomeViewController = "HomeViewController"
    case LoginViewController = "LoginViewController"
    case SignUpViewController = "SignUpViewController"
    case ForgotPasswordViewController = "ForgotPasswordViewController"
    
}

struct ViewBorders {
    static let cornerRadius: CGFloat = 8
    static let borderWidth: CGFloat = 2
}

struct Colors {
    
    static let lightBlueColor = UIColor(red: 66/255, green: 147/255, blue: 234/255, alpha: 1.0)
    static let darkGrayColor = UIColor(red: 44/255, green: 44/255, blue: 44/255, alpha: 1.0)
    static let grayColor = UIColor(red: 67/255, green: 68/255, blue: 68/255, alpha: 1.0)
    
}

