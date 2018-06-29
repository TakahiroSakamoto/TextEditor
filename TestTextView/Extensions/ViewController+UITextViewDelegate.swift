//
//  ViewController+UITextFieldDelegate.swift
//  TestTextView
//
//  Created by 坂本貴宏 on 2018/06/28.
//  Copyright © 2018年 坂本貴宏. All rights reserved.
//

import UIKit

extension ViewController: UITextViewDelegate {
    
    // テキストが入力されるたびに何かしたいとき
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let textAsNSString = self.textView.text! as NSString
        // rangeの範囲をtestに置換する
        let replace = textAsNSString.replacingCharacters(in: range, with: text)
        let boldString = replace.range(of: "\n")
        if boldString != nil {
            let boldRange = NSRange(boldString!, in: replace)
            if boldRange.location <= range.location {
                self.textView.typingAttributes = [NSAttributedStringKey.font.rawValue : UIFont.systemFont(ofSize: 16.0)]
            } else {
                self.textView.typingAttributes = [NSAttributedStringKey.font.rawValue : UIFont.boldSystemFont(ofSize: 30)]
                self.titleText = replace
            }
        }
        return true
    }
    
    func textViewDidChange(_ textView: UITextView) {
        let size = self.titleTextView.sizeThatFits(titleTextView.frame.size)
        self.titleTextView.frame.size.height = size.height
        view.layoutIfNeeded()
        //タイトルが2行以上になる場合にtextViewの位置を変える
        self.textView.frame.origin.y = self.titleTextView.frame.height + self.titleTextView.frame.origin.y + 5
    }
    
    // TextViewのテキストにカーソル合わせたタイミングで呼ばれるおーー
    func textViewDidChangeSelection(_ textView: UITextView) {
        self.kSelectTextInImage.removeFromSuperview()
        guard let textRange = self.textView.selectedTextRange else {
            return
        }
        textSize = self.textView.caretRect(for: (textRange.start))
        if textSize.height >= 95 {
            kSelectTextInImage.frame = CGRect(x: textSize.origin.x - self.textInSelectImage.size.width + 1, y: textSize.origin.y - 2, width: self.textInSelectImage.size.width, height: textSize.size.height + 1)
            self.kSelectTextInImage.layer.borderColor = UIColor.green.cgColor
            self.kSelectTextInImage.layer.borderWidth = 4
            self.kSelectTextInImage.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.4)
            textView.tintColor = UIColor.clear
            self.textView.addSubview(kSelectTextInImage)
            
        } else {
            textView.tintColor = UIColor(red: 0, green: 122/255, blue: 255/255, alpha: 1)
            kSelectTextInImage.removeFromSuperview()
        }
    }
}
