//
//  UserSearchTextField.swift
//  TestTextView
//
//  Created by 坂本貴宏 on 2018/06/26.
//  Copyright © 2018年 坂本貴宏. All rights reserved.
//

import UIKit
import SearchTextField

class UserSearchTextField: SearchTextField {

    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setSerarchTextField(action: Selector) {
        self.backgroundColor = UIColor.white
        self.layer.cornerRadius = 6
        self.placeholder = "ユーザー名を入力"
        self.becomeFirstResponder()
        self.delegate = ViewController()
        self.addTarget(ViewController(), action: action, for: .editingChanged)
        self.theme.font = UIFont.systemFont(ofSize: 16)
        self.theme.bgColor = UIColor.white
        self.theme.separatorColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 0.5)
        self.theme.cellHeight = 50
    }
}
