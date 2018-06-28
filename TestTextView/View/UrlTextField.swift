//
//  UrlTextField.swift
//  TestTextView
//
//  Created by 坂本貴宏 on 2018/06/26.
//  Copyright © 2018年 坂本貴宏. All rights reserved.
//

import UIKit

class UrlTextField: UITextField {

    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setTextField(placeholder: String, superView: UIView) {
        self.backgroundColor = UIColor.groupTableViewBackground
        self.layer.cornerRadius = 6
        self.placeholder = placeholder
        superView.addSubview(self)
    }
}
