//
//  ViewController+TLPhotosPickerViewControllerDelegate.swift
//  TestTextView
//
//  Created by 坂本貴宏 on 2018/06/28.
//  Copyright © 2018年 坂本貴宏. All rights reserved.
//

import UIKit
import TLPhotoPicker

extension ViewController: TLPhotosPickerViewControllerDelegate {
    // アルバムから画像取得する
    func dismissPhotoPicker(withTLPHAssets: [TLPHAsset]) {
        self.selectedAssets = withTLPHAssets
        self.nowCursor = self.textView.selectedRange
        self.selectTextRange = self.textView.selectedTextRange
        for img in self.selectedAssets.reversed() {
            self.images.append(img.fullResolutionImage!)
        }
        for oneImage in self.images {
            self.textInSelectImage = oneImage.resizeUIImageByWidth(image: oneImage, width: Double(self.view.frame.width - 20))
            self.insertViewToImage(selectRange: self.nowCursor, selectTextRange: self.selectTextRange, url: nil)
        }
        self.images.removeAll()
        self.textView.becomeFirstResponder()
    }
    
    func setPhotoLibrary(isCameraOrVideoMode: Bool) -> TLPhotosPickerViewController {
        let viewController = TLPhotosPickerViewController()
        viewController.delegate = self
        var configure = TLPhotosPickerConfigure()
        configure.allowedVideo = isCameraOrVideoMode
        configure.cancelTitle = "✖"
        configure.doneTitle = "完了"
        configure.usedPrefetch = true
        if isCameraOrVideoMode {configure.mediaType = .video}
        viewController.configure = configure
        return viewController
    }
}
