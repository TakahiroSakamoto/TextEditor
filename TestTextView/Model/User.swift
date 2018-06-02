//
//  User.swift
//  TestTextView
//
//  Created by 坂本貴宏 on 2018/04/20.
//  Copyright © 2018年 坂本貴宏. All rights reserved.
//

import UIKit

class User: NSObject {
    var account_name: String!
    var nickname: String!
    var thumb_url: String!
    
    init(account_name: String, nickname: String, thumb_url: String) {
        self.account_name = account_name
        self.nickname = nickname
        self.thumb_url = thumb_url
    }
}
