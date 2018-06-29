//
//  UrlTextField.swift
//  TestTextView
//
//  Created by 坂本貴宏 on 2018/06/26.
//  Copyright © 2018年 坂本貴宏. All rights reserved.
//

import UIKit
import RegeributedTextView

class UrlTextField: UITextField {

    private let stringAttributes: [NSAttributedStringKey: Any] = [.underlineStyle: NSUnderlineStyle.styleSingle.rawValue, .underlineColor: UIColor(red: 0, green: 122/255, blue: 255/255, alpha: 1)]
    
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
    
    func pasteString() {
        if (UIPasteboard.general.string != nil && ((UIPasteboard.general.string?.range(of: "http")) != nil)) {
            self.text = UIPasteboard.general.string
        }
    }
    
    func previewUrlText(urlPreviewTextField: UrlTextField) {
        if !(self.text?.isEmpty)! {
            urlPreviewTextField.text = self.text
            urlPreviewTextField.textColor = UIColor(red: 0, green: 122/255, blue: 255/255, alpha: 1)
            let previewString = NSAttributedString(string: self.text!, attributes: stringAttributes)
            urlPreviewTextField.attributedText = previewString
        }
    }
    
    func optionalText(urlTextField: UrlTextField, urlPreviewTextField: UrlTextField) {
        urlPreviewTextField.textColor = UIColor(red: 0, green: 122/255, blue: 255/255, alpha: 1)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            if !(self.text?.isEmpty)! && !(urlTextField.text?.isEmpty)! {
                let previewString = NSAttributedString(string: self.text!, attributes: self.stringAttributes)
                urlPreviewTextField.attributedText = previewString
            } else if !(urlTextField.text?.isEmpty)! && (self.text?.isEmpty)! {
                let previewString = NSAttributedString(string: urlTextField.text!, attributes: self.stringAttributes)
                urlPreviewTextField.attributedText = previewString
            }
        }
    }
    
    func setUrlTextInTextView(textView: RegeributedTextView, urlPreviewTextField: UrlTextField, viewControlller: ViewController) {
        if (self.text?.isEmpty)! {
            let alert = UIAlertController(title: "URLを入力してください", message: nil, preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(action)
            viewControlller.present(alert, animated: true, completion: nil)
            textView.resignFirstResponder()
            return
        } else {
            guard let range = textView.selectedTextRange else {
                return
            }
            textView.replace(range, withText: " " + urlPreviewTextField.text! + " ")
            textView.addAttributes(urlPreviewTextField.text!, values: ["URL": self.text!], attributes: [.underline(UnderlineStyle.single), .underlineColor(UIColor(red: 0, green: 122/255, blue: 255/255, alpha: 1)), .textColor(UIColor(red: 0, green: 122/255, blue: 255/255, alpha: 1))])
        }
    }
}
