//
//  UIImage+Extension.swift
//  TestTextView
//
//  Created by 坂本貴宏 on 2018/04/10.
//  Copyright © 2018年 坂本貴宏. All rights reserved.
//

import UIKit

extension UIImage {
    func roundImage() -> UIImage {
        let minLength: CGFloat = min(self.size.width, self.size.height)
        let rectangleSize: CGSize = CGSize(width: minLength, height: minLength)
        UIGraphicsBeginImageContextWithOptions(rectangleSize, false, 0.0)
        
        UIBezierPath(roundedRect: CGRect(origin: .zero, size: rectangleSize), cornerRadius: minLength).addClip()
        self.draw(in: CGRect(origin: CGPoint(x: (minLength - self.size.width) / 2, y: (minLength - self.size.height) / 2), size: self.size))
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return resizeUIImageByWidth(image: newImage, width: 45)
        
    }
    
    func resizeUIImageByWidth(image: UIImage, width: Double) -> UIImage {
        // オリジナル画像のサイズから、アスペクト比を計算
        let aspectRate = image.size.height / image.size.width
        // リサイズ後のWidthをアスペクト比を元に、リサイズ後のサイズを取得
        let resizedSize = CGSize(width: width, height: width * Double(aspectRate))
        // リサイズ後のUIImageを生成して返却
        UIGraphicsBeginImageContext(resizedSize)
        image.draw(in: CGRect(x: 0, y: 0, width: resizedSize.width, height: resizedSize.height))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return resizedImage!
    }
}

