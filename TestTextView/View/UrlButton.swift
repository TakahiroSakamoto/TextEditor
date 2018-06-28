//
//  UrlButton.swift
//  TestTextView
//
//  Created by 坂本貴宏 on 2018/06/26.
//  Copyright © 2018年 坂本貴宏. All rights reserved.
//

import UIKit

class UrlButton: UIButton {

    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUrlUnderButton(title: String, action: Selector, superView: UIView) {
        self.setTitle(title, for: .normal)
        self.setTitleColor(UIColor.lightGray, for: .normal)
        self.addTarget(ViewController(), action: action, for: .touchUpInside)
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.lightGray.cgColor
        superView.addSubview(self)
    }
}
