//
//  BackView.swift
//  TestTextView
//
//  Created by 坂本貴宏 on 2018/06/26.
//  Copyright © 2018年 坂本貴宏. All rights reserved.
//

import UIKit

class BackView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setBackView(superView: UIView) {
        self.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.6)
        superView.addSubview(self)
    }
}
