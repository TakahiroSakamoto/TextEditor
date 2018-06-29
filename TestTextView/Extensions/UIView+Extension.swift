//
//  UIView+Extension.swift
//  TestTextView
//
//  Created by 坂本貴宏 on 2018/04/17.
//  Copyright © 2018年 坂本貴宏. All rights reserved.
//

import UIKit

extension UIView {
    func viewToImage(view: UIView) -> UIImage {
        let rect = view.bounds
        
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        let context: CGContext = UIGraphicsGetCurrentContext()!
        
        view.layer.render(in: context)
        
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }
}
