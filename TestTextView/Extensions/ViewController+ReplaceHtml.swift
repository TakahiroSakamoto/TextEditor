//
//  ViewController+ReplaceHtml.swift
//  TestTextView
//
//  Created by 坂本貴宏 on 2018/06/28.
//  Copyright © 2018年 坂本貴宏. All rights reserved.
//

import UIKit
import Fuzi

extension ViewController {
    func replaceHtmlString() {
        // リンクをHTML化
        if self.urlText.count > 0 {
            for i in self.urlText {
                if sumHtml.contains(i.url) && i.urlText == nil {
                    sumHtml = sumHtml.replacingOccurrences(of: i.url, with: "<a href=\"\(i.url)\">\(i.url)</a>")
                    sumHtml = sumHtml.replacingOccurrences(of: "<a href=\"<a href=\"\(i.url)\">\(i.url)</a>\"><a href=\"\(i.url)\">\(i.url)</a></a>", with: "<a href=\"\(i.url)\">\(i.url)</a>")
                } else if sumHtml.contains(i.urlText!) && i.url != "" {
                    sumHtml = sumHtml.replacingOccurrences(of: i.urlText!, with: "<a href=\"\(i.url)\">\(i.urlText!)</a>")
                }
            }
        }
        // メンションをHTML化
        if self.mensionUserName.count > 0 {
            for i in self.mensionUserName {
                sumHtml = sumHtml.replacingOccurrences(of: "@" + i, with: "<a href=\"https://pressblog.me/users/\(i)\">@\(i)</a>")
            }
        }
        sumHtml = sumHtml.replacingOccurrences(of: "<body>", with: "")
        sumHtml = sumHtml.replacingOccurrences(of: "</body>", with: "")
        sumHtml = "<body>" + sumHtml
        sumHtml = sumHtml + "</body>"
        if self.titleTextView.text != "" {
            sumHtml = "<html><h1>\(self.titleTextView.text!)</h1>" + sumHtml + "</html>"
        } else {
            sumHtml = "<html><h1>NO TITLE</h1>\n\n" + sumHtml + "</html>"
        }
        do {
            let test = try HTMLDocument(string: sumHtml, encoding: .utf8)
            self.titleText = test.title
        } catch let error {
            print(error)
        }
    }
}
