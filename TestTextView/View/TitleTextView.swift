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
    var m_labelForPlaceHolder:UILabel?
    
    // プレースホルダーの文言
    var m_strPlaceHolder:String?
    
    // プレースホルダーのテキストの色
    var m_colorForPlaceHolder:UIColor?
    
    func initialize() {
        NotificationCenter.default.addObserver(self, selector: #selector( self.TextChanged), name: NSNotification.Name.UITextViewTextDidChange, object: nil)
        
        m_labelForPlaceHolder = UILabel(frame: CGRect(x: 8, y: 8, width: self.bounds.size.width - 16, height: 0))
        m_labelForPlaceHolder?.numberOfLines = 0
        m_labelForPlaceHolder?.font = UIFont.systemFont(ofSize: 35.0)
        m_labelForPlaceHolder?.lineBreakMode = NSLineBreakMode.byCharWrapping
        
        // デフォルト設定
        self.placeHolder = "プレースホルダー"
        self.PlaceHolderColor = UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1)
        
        // 枠線をつける
//        self.layer.borderWidth = 2
//        self.layer.borderColor = UIColor.gray.cgColor
        
        self.addSubview(m_labelForPlaceHolder!)
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
            return m_colorForPlaceHolder
        }
        set {
            m_colorForPlaceHolder = newValue
            if nil == m_colorForPlaceHolder {
                m_colorForPlaceHolder = UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1)
            }
            m_labelForPlaceHolder?.textColor = m_colorForPlaceHolder
        }
    }
    var placeHolder:String? {
        get {
            return m_strPlaceHolder
        }
        set {
            m_strPlaceHolder = newValue
            if nil == m_strPlaceHolder {
                m_strPlaceHolder = ""
            }
            // frameをリセットする
            m_labelForPlaceHolder?.frame = CGRect(x: 8, y: 8, width: self.bounds.size.width - 16, height: 0)
            
            m_labelForPlaceHolder?.text = m_strPlaceHolder
            m_labelForPlaceHolder?.sizeToFit()
        }
    }
    
    
    // テキストが変更された際に呼ばれる
    @objc func TextChanged(niti:NSNotification) {
        if 0 == self.text.characters.count {
            m_labelForPlaceHolder?.isHidden = false
        }
        else {
            m_labelForPlaceHolder?.isHidden = true
        }
    }

}
