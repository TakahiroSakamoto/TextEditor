//
//  PreviewViewController.swift
//  TestTextView
//
//  Created by 坂本貴宏 on 2018/05/13.
//  Copyright © 2018年 坂本貴宏. All rights reserved.
//

import UIKit
import Fuzi
import WebKit

class PreviewViewController: UIViewController {
    var convertAttributeText: NSAttributedString!
    var testHTML: String!
    var titleText: String!
    let indicator = UIActivityIndicatorView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let wkWebView = WKWebView(frame: self.view.frame)
        self.view.addSubview(wkWebView)
        testHTML = testHTML.replacingOccurrences(of: "<html>", with: "<html><meta name=\"viewport\" content=\"width=device-width, initial-scale=1\"><style> body { font-size: 130%; font-family: Helvetica} </style>")
        
        wkWebView.loadHTMLString(testHTML, baseURL: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    
    }
    
    func showIndicator() {
        indicator.activityIndicatorViewStyle = .whiteLarge
        indicator.center = self.view.center
        indicator.hidesWhenStopped = true
        self.view.addSubview(indicator)
        indicator.startAnimating()
    }
    
}
