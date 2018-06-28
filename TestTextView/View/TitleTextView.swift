//
//  TitleTextView.swift
//  TestTextView
//
//  Created by 坂本貴宏 on 2018/04/23.
//  Copyright © 2018年 坂本貴宏. All rights reserved.
//

import UIKit

class TitleTextView: UITextView {

    // プレースホルダー用のラベル
    var labelForPlaceHolder:UILabel?
    
    // プレースホルダーの文言
    var strPlaceHolder:String?
    
    // プレースホルダーのテキストの色
    var colorForPlaceHolder:UIColor?
    
    func initialize() {
        NotificationCenter.default.addObserver(self, selector: #selector( self.TextChanged), name: NSNotification.Name.UITextViewTextDidChange, object: nil)
        
        labelForPlaceHolder = UILabel(frame: CGRect(x: 8, y: 8, width: self.bounds.size.width - 16, height: 0))
        labelForPlaceHolder?.numberOfLines = 0
        labelForPlaceHolder?.font = UIFont.systemFont(ofSize: 35.0)
        labelForPlaceHolder?.lineBreakMode = NSLineBreakMode.byCharWrapping
        
        // デフォルト設定
        self.placeHolder = "プレースホルダー"
        self.PlaceHolderColor = UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1)
        
        // 枠線をつける
//        self.layer.borderWidth = 2
//        self.layer.borderColor = UIColor.gray.cgColor
        
        self.addSubview(labelForPlaceHolder!)
    }
    
    init(frame:CGRect) {
        super.init(frame: frame, textContainer: nil)
        initialize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    var PlaceHolderColor:UIColor? {
        get {
            return colorForPlaceHolder
        }
        set {
            colorForPlaceHolder = newValue
            if nil == colorForPlaceHolder {
                colorForPlaceHolder = UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1)
            }
            labelForPlaceHolder?.textColor = colorForPlaceHolder
        }
    }
    var placeHolder:String? {
        get {
            return strPlaceHolder
        }
        set {
            strPlaceHolder = newValue
            if nil == strPlaceHolder {
                strPlaceHolder = ""
            }
            // frameをリセットする
            labelForPlaceHolder?.frame = CGRect(x: 8, y: 8, width: self.bounds.size.width - 16, height: 0)
            
            labelForPlaceHolder?.text = strPlaceHolder
            labelForPlaceHolder?.sizeToFit()
        }
    }
    
    
    // テキストが変更された際に呼ばれる
    @objc func TextChanged(niti:NSNotification) {
        if 0 == self.text.count {
            labelForPlaceHolder?.isHidden = false
        }
        else {
            labelForPlaceHolder?.isHidden = true
        }
    }

}
