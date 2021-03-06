//
//  UserManager.swift
//  TestTextView
//
//  Created by 坂本貴宏 on 2018/04/20.
//  Copyright © 2018年 坂本貴宏. All rights reserved.
//

import UIKit
import SearchTextField
import Alamofire
import SwiftyJSON
import Foundation

class UserManager: NSObject {
    static let sharedInstance = UserManager()
    var users: [SearchTextFieldItem] = []
    private var keepAlive = true
    private var indicator: UIActivityIndicatorView!
    
    // ユーザーを取得して、配列にぶち込む
    func fetchUsers(keyword: String) {
        indicator = ViewController.makeMensionIndicator()
       
        indicator.startAnimating()
        Alamofire.request("https://pressblog.me/api/v2/insta_users/search_by_account_name?account_name=\(keyword)&limit=30", method: .get).responseJSON { (responce) in
            guard let object = responce.result.value else {
                self.keepAlive = false
                return
            }
            
            let json = JSON(object)
            json["insta_users"].forEach{ (_, json) in
                let url = URL(string: json["thumb_url"].string!)
                let imageData = try? Data(contentsOf: url!)
                
                if imageData == nil {
                     let user = SearchTextFieldItem(title: json["account_name"].string!, subtitle: json["nickname"].string, image: UIImage(named: "defaultProfileImage")?.roundImage())
                    UserManager.sharedInstance.users.append(user)
                } else {
                    let user = SearchTextFieldItem(title: json["account_name"].string!, subtitle: json["nickname"].string, image: UIImage(data: imageData!)?.roundImage())
                    UserManager.sharedInstance.users.append(user)
                }
                
            }
            ViewController.searchField.filterItems(UserManager.sharedInstance.users)
            self.keepAlive = false
            self.indicator.stopAnimating()
        }

    }
}
