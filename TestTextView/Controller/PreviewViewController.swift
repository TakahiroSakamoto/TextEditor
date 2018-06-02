//
//  PreviewViewController.swift
//  TestTextView
//
//  Created by 坂本貴宏 on 2018/05/13.
//  Copyright © 2018年 坂本貴宏. All rights reserved.
//

import UIKit
import RegeributedTextView
import Alamofire
import SwiftyJSON
import Fuzi

class PreviewViewController: UIViewController {
    var convertAttributeText: NSAttributedString!
    var titleText: String!
    var testHTML: String!

    @IBOutlet weak var textView: RegeributedTextView!
    let webView = UIWebView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        webView.frame = self.view.frame
        
        self.view.addSubview(webView)
        print(self.testHTML)
//        Alamofire.request("http", method: .get).responseString { (responce) in
//            guard let object = responce.result.value else {
//                print("取得できなかった")
//                return
//            }
//
//            do {
//                let stringHtml = try HTMLDocument(string: object, encoding: .utf8)
//                self.titleText = stringHtml.title
//            } catch {
//                print("エラーよーー")
//            }
//
//            self.convertAttributeText = object.convertHtml(withFont: UIFont(name: "Helvetica", size: 16), align: .left)
//        }
        
         webView.loadHTMLString(testHTML, baseURL: nil)
        
       // textView.attributedText = convertAttributeText
        textView.dataDetectorTypes = .link
        
      //  textView.addAttribute("\n", attribute: .backgroundColor(UIColor(red: 0, green: 20, blue: 255, alpha: 0.4)))
        //textView.textColor = UIColor(red: 0, green: 20, blue: 255, alpha: 0.4)
        
        textView.placeHolder = ""
        
        let titleAttibuteText = NSMutableAttributedString(string: titleText + "\n\n\n")
        //フォントサイズ、太字にする文字位置を設定
        titleAttibuteText.addAttribute(NSAttributedStringKey.font, value: UIFont.boldSystemFont(ofSize: 28), range: NSMakeRange(0, titleText.count))

        titleAttibuteText.append(self.textView.attributedText)
        //self.textView.attributedText = titleAttibuteText
        
        
        let attText = self.textView.attributedText
        let documentAttribues = [NSAttributedString.DocumentAttributeKey.documentType: NSAttributedString.DocumentType.html]
        let html = try! attText?.data(from: NSRange(location: 0, length: (attText?.length)!), documentAttributes: documentAttribues)
        let htmlString = String(data: html!, encoding: .utf8)
       //self.textView.attributedText = testConvert//htmlString
    }
    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//
//    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    
    }
    
}
