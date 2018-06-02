//
//  ViewController.swift
//  TestTextView
//
//  Created by 坂本貴宏 on 2018/03/07.
//  Copyright © 2018年 坂本貴宏. All rights reserved.
//

import UIKit
import URLEmbeddedView
import SafariServices
import AVKit
import AVFoundation
import Photos
import TLPhotoPicker


class ViewController: UIViewController, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, TLPhotosPickerViewControllerDelegate {

    @IBOutlet weak var textView: UITextView!
    
    @IBOutlet weak var titleTextView: UITextView!
    
    let orgTextField = UITextField()
    
    let backView = UIView()
    
    var textInSelectImage = UIImage()
    var textInSelectMovie = UIImage()
    
    var videoURL: URL?
    
    var selectedImage = UIImageView()
    
    let selectTextInImage = UIView()
    
    var textSize: CGRect!
    
    static var nowCapturePhoro = UIImage()
    
    var images = [UIImage]()
    
    var selectedAssets = [TLPHAsset]()
    
    let mesionTextField = UITextField()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        titleTextView.isScrollEnabled = false
        self.textView.delegate = self
        self.titleTextView.delegate = self
        
        addToolBar()
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        titleTextView.text = "タイトルを入力"
        titleTextView.textColor = UIColor.darkGray
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        textView.isScrollEnabled = true
        if titleTextView.textColor == UIColor.darkGray {
            titleTextView.text = ""
            titleTextView.textColor = UIColor.black
        }
    }
    
    
    func textViewDidChange(_ textView: UITextView) {
        let size:CGSize = titleTextView.sizeThatFits(titleTextView.frame.size)
        titleTextView.frame.size.height = size.height
        
        view.layoutIfNeeded()
        self.textView.frame.origin.y = titleTextView.frame.height + 100
        
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        print("タイトル未編集")
        if titleTextView.text.isEmpty {
            titleTextView.text = "タイトルを入力"
            titleTextView.textColor = UIColor.darkGray
        }
    }
    
    // TextViewのテキストを選択できるかどうか falseだと選択できないおーー
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
//        if textSize.height >= 150 {
//            return false
//        }
        return true
    }
    
    
    // TextViewのテキストにカーソル合わせたタイミングで呼ばれるおーー
    func textViewDidChangeSelection(_ textView: UITextView) {
        selectTextInImage.removeFromSuperview()
        let location = textView.selectedRange.location
        let length = textView.selectedRange.length
        print(location)
        print(length)
        let textRange: UITextRange? = self.textView.selectedTextRange
        if textRange == nil {return}
        //print(textRange)
        textSize = self.textView.caretRect(for: (textRange?.start)!)
            print(textSize)
            if textSize.height >= 150 {
                //selectTextInImage = UIView()
                selectTextInImage.frame = CGRect(x: textSize.origin.x - self.textInSelectImage.size.width, y: textSize.origin.y, width: self.textInSelectImage.size.width, height: textSize.size.height)
                selectTextInImage.layer.borderColor = UIColor.green.cgColor
                selectTextInImage.layer.borderWidth = 4
                selectTextInImage.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.4)
                textView.tintColor = UIColor.clear
                self.textView.addSubview(selectTextInImage)
                print("\(selectTextInImage.frame)" + " ⬅ 画像のサイズ確認")
                
            } else {
                print("No Selected")
                textView.tintColor = UIColor.blue
                selectTextInImage.removeFromSuperview()
//                self.textView.isEditable = true
//                self.textView.isSelectable = true
            }
    }
    
    
    // アルバムから画像取得するおーー
    func dismissPhotoPicker(withTLPHAssets: [TLPHAsset]) {
        self.selectedAssets = withTLPHAssets
        print("\(self.selectedAssets.count)" + "枚の画像選択したおー")
//        let testString = self.textView.text + "\n\n\n"
//        let toAttributedString = NSAttributedString(string: testString)
        
        for img in self.selectedAssets {
            self.images.append(img.fullResolutionImage!)
        }
            
                for oneImage in self.images {
                    self.textInSelectImage = self.resizeUIImageByWidth(image: oneImage, width: Double(self.view.frame.width - 20))
                    print(self.textView.selectedRange)
                    print(self.textInSelectImage)
                    let testString = self.textView.attributedText
                    let lineSpace = NSAttributedString(string: "\n\n\n")
                    
                    //画像が取得できたことを示すために何らかのUIの更新を行う(ボタンを使用可能にするなど)事が多い
                    let stringAttributes: [NSAttributedStringKey : Any] = [
                        .font : UIFont.systemFont(ofSize: 14.0)
                    ]
                    //let strTextViewText = NSAttributedString(string: testString, attributes: stringAttributes)
                    let selectedImage = NSTextAttachment()
                    selectedImage.image = self.textInSelectImage
                    selectedImage.bounds = CGRect(x: 0, y: -4, width: self.textInSelectImage.size.width, height: self.textInSelectImage.size.height)
                    let strImage = NSAttributedString(attachment: selectedImage)
                    let testABCString: [NSAttributedStringKey: Any] = [.strokeColor: UIColor.blue, .strokeWidth: -10]
                
                    
                    let str = NSMutableAttributedString()
                    str.append(testString!)
                    str.append(lineSpace)
//                    str.append(NSAttributedString(string: self.textView.text, attributes: attributes))
                    str.append(strImage)
                    
//                    let str2 = NSMutableAttributedString(attributedString: strImage)
//                   // str2.append(strImage)
//
//                    str2.addAttributes(testABCString, range: NSRange(location: 0,length: 1))
//                   // str2.setAttributes(testABCString, range: self.textView.selectedRange)
                
                    
                    //str.insert(self.textView.attributedText, at: self.textView.selectedRange.location)
                    //str.insert(strImage, at: self.textView.selectedRange.location)
                    self.textView.attributedText = str
                   
//                    print(self.textView.caretRect(for: (self.textView.selectedTextRange!.start)))
//                    print(self.textView.selectedRange.location)
                   // print(self.textView.attributedText)
                    
                    
                    // 入力中のところから装飾した場合に使用。これの処理以降に装飾される
                    //self.textView.typingAttributes = [NSAttributedStringKey.font.rawValue: UIFont.systemFont(ofSize: 14)]
                
            }
        
        self.images.removeAll()
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func addToolBar() {
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.tintColor = UIColor(red: 76/255, green: 217/255, blue: 100/255, alpha: 1)
        
        let jayZButton = UIBarButtonItem(barButtonSystemItem: .camera, target: self, action: #selector(self.cameraMode))
        
        let spaceButton1 = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.fixedSpace, target: nil, action: nil)
        spaceButton1.width = 20
        
        let beyoncéButton = UIBarButtonItem(barButtonSystemItem: .play, target: self, action: #selector(self.movieMode))
        
        let spaceButton2 = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.fixedSpace, target: nil, action: nil)
        spaceButton2.width = 20
        
        
        let drakeButton = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(self.orgMode))
        
        let spaceButton3 = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.fixedSpace, target: nil, action: nil)
        spaceButton3.width = 120
        
        let editButton = UIBarButtonItem(title: "@", style: .plain, target: self, action: #selector(self.smallTextMode))//UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(self.smallTextMode))
       
        
        let spaceButton4 = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.fixedSpace, target: nil, action: nil)
        spaceButton4.width = 10
        
        let editButton2 = UIBarButtonItem(title: "#", style: .plain, target: self, action: #selector(self.noarmalTextMode))//UIBarButtonItem(barButtonSystemItem: .bookmarks, target: self, action: #selector(self.noarmalTextMode))
        
        let spaceButton5 = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.fixedSpace, target: nil, action: nil)
        spaceButton5.width = 10
        
        let editButton3 = UIBarButtonItem(title: "T", style: .plain, target: self, action: #selector(self.bigTextMode))//UIBarButtonItem(barButtonSystemItem: .reply, target: self, action: #selector(self.bigTextMode))
        
        
        toolBar.setItems([jayZButton, spaceButton1, beyoncéButton, spaceButton2, drakeButton, spaceButton3, editButton, spaceButton4, editButton2, spaceButton4, editButton3], animated: false)
        toolBar.isUserInteractionEnabled = true
        toolBar.sizeToFit()
        
        textView.inputAccessoryView = toolBar
    }
    
    @objc func cameraMode(){
        // view.endEditing(true)
        makePhotoLibrary(isCameraOrVideoMode: false)
    }
    
    @objc func movieMode(){
        // view.endEditing(true)
        makePhotoLibrary(isCameraOrVideoMode: true)
       
    }
    
    @objc func orgMode(){
        makeOrgView()
    }
    
    @objc func smallTextMode(){
        mesionTextField.frame = CGRect(x: self.view.frame.origin.x + 20, y: self.view.center.y / 4, width: self.view.frame.width - 40, height: 50)
        mesionTextField.backgroundColor = UIColor.groupTableViewBackground
        mesionTextField.placeholder = "@username"
        mesionTextField.layer.cornerRadius = 6
        
        let backView = makeMesionBackView()
        backView.addSubview(mesionTextField)
        
        //textView.typingAttributes = [NSAttributedStringKey.font.rawValue: UIFont.boldSystemFont(ofSize: (textView.font?.pointSize)!)]
        //self.textView.resignFirstResponder()
        
    }
    
    @objc func noarmalTextMode() {
        textView.typingAttributes = [NSAttributedStringKey.font.rawValue: UIFont.systemFont(ofSize: 18)]
        
    }
    
    @objc func bigTextMode() {
        textView.typingAttributes = [NSAttributedStringKey.font.rawValue: UIFont.systemFont(ofSize: 25)]
        
    }
    
    
    func previewImageFromVideo(_ url:URL) -> UIImage? {
        print("動画からサムネイルを生成する")
        let asset = AVURLAsset(url:url)
        print(asset)
        let imageGenerator = AVAssetImageGenerator(asset:asset)
        print(imageGenerator)
        imageGenerator.appliesPreferredTrackTransform = true
       // var time = asset.duration
        //time.value = min(time.value,2)
        do {
            let imageRef = try imageGenerator.copyCGImage(at: asset.duration, actualTime: nil)
            return UIImage(cgImage: imageRef)
        } catch {
            return nil
        }
    }
    
   func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
    if info[UIImagePickerControllerMediaURL] != nil {
        if let videoURLTest = info[UIImagePickerControllerMediaURL] as? URL {
            print(videoURLTest)
            self.textInSelectImage = previewImageFromVideo(videoURLTest)!
            self.textInSelectImage = resizeUIImageByWidth(image: self.textInSelectImage, width: Double(self.view.frame.width - 20))
            
            let stringAttributes: [NSAttributedStringKey : Any] = [
                .font : UIFont.systemFont(ofSize: 14.0)
            ]
            let strTextViewText2 = NSAttributedString(string: self.textView.text, attributes: stringAttributes)
            let selectedImage2 = NSTextAttachment()
            selectedImage2.image = self.textInSelectImage
            selectedImage2.bounds = CGRect(x: 0, y: -4, width: self.textInSelectImage.size.width, height: self.textInSelectImage.size.height)
            let strImage2 = NSAttributedString(attachment: selectedImage2)
            
            let str2 = NSMutableAttributedString()
            str2.append(strTextViewText2)
            str2.append(strImage2)
            
            self.textView.attributedText = str2
            self.textView.typingAttributes = [NSAttributedStringKey.font.rawValue: UIFont.systemFont(ofSize: 14)]
            picker.dismiss(animated: true, completion: nil)
        //imagePickerController.dismiss(animated: true, completion: nil)
        } else {
            print("エラー")
        }
    } else {
        print("エラー")
    }
    
    
        if info[UIImagePickerControllerOriginalImage] != nil {
            if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
                //後で使うためにその画像をインスタンス変数に保存
                //self.pickedImage = image
                self.textInSelectImage = resizeUIImageByWidth(image: image, width: Double(self.view.frame.width - 20))
            
                //画像が取得できたことを示すために何らかのUIの更新を行う(ボタンを使用可能にするなど)事が多い
                let stringAttributes: [NSAttributedStringKey : Any] = [
                    .font : UIFont.systemFont(ofSize: 14.0)
                ]
                let strTextViewText = NSAttributedString(string: self.textView.text, attributes: stringAttributes)
                let selectedImage = NSTextAttachment()
                selectedImage.image = self.textInSelectImage
                selectedImage.bounds = CGRect(x: 0, y: -4, width: self.textInSelectImage.size.width, height: self.textInSelectImage.size.height)
                let strImage = NSAttributedString(attachment: selectedImage)
                
                let str = NSMutableAttributedString()
                str.append(strTextViewText)
                str.append(strImage)
                
                self.textView.attributedText = str
                self.textView.typingAttributes = [NSAttributedStringKey.font.rawValue: UIFont.systemFont(ofSize: 14)]
                
            }
        }
        
        picker.dismiss(animated: true, completion: nil)
//        let textRange = self.textView.selectedRange
//        print(textRange)
//        print(self.textView.selectedTextRange)
    
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
    
    
    
    func makeOrgView() {
        makeMesionBackView()
        
        let orgBackView = UIView()
        orgBackView.frame.size.width = self.view.frame.width
        orgBackView.frame.size.height = 100
        orgBackView.backgroundColor = UIColor.white
        orgBackView.center.y = makeMesionBackView().center.y - 120
        makeMesionBackView().addSubview(orgBackView)
        
        
        orgTextField.frame.size.width = orgBackView.frame.size.width - 40
        orgTextField.frame.size.height = orgBackView.frame.height / 3
        orgTextField.center.y = orgBackView.frame.origin.y - 125//orgBackView.center.y - 175
        print(orgTextField.frame.size.height)
        orgTextField.center.x = orgBackView.center.x
        orgTextField.backgroundColor = UIColor.groupTableViewBackground
        orgTextField.placeholder = "http://"
        orgBackView.addSubview(orgTextField)
        
       
        let submitButton = UIButton()
        submitButton.frame.size.width = orgBackView.frame.size.width / 2
        submitButton.frame.size.height = orgTextField.frame.size.height
        submitButton.center.x = orgBackView.frame.size.width / 2*1.5 //- 60
        submitButton.center.y = orgBackView.frame.size.height - 20
        submitButton.setTitle("登録", for: .normal)
        submitButton.setTitleColor(UIColor.lightGray, for: .normal)
        submitButton.addTarget(self, action: #selector(self.setOrg), for: .touchUpInside)
        submitButton.layer.cornerRadius = 6
        submitButton.layer.borderWidth = 1
        submitButton.layer.borderColor = UIColor.lightGray.cgColor
        orgBackView.addSubview(submitButton)
        
    }
    
    func makePhotoLibrary(isCameraOrVideoMode: Bool) {
        let viewController = TLPhotosPickerViewController()
        viewController.delegate = self
        var configure = TLPhotosPickerConfigure()
        configure.allowedVideo = isCameraOrVideoMode
        configure.cancelTitle = "✖"
        configure.doneTitle = "完了"
        configure.usedPrefetch = true
        if isCameraOrVideoMode {configure.mediaType = .video}
        viewController.configure = configure
        self.present(viewController, animated: true, completion: nil)
    }
    
    func makeMesionBackView() -> UIView {
        backView.frame = self.view.frame
        backView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.6)
        self.view.addSubview(backView)
        return backView
    }
    
    @objc func setOrg() {
        let embeddedView = URLEmbeddedView()
        embeddedView.loadURL(orgTextField.text!)
        embeddedView.frame.size = CGSize(width: self.view.frame.width / 1.2, height: 100)
        embeddedView.center.x = self.view.center.x
        embeddedView.center.y = self.textView.frame.height + 10
        embeddedView.didTapHandler = { [weak self] embeddedView, URL in
            guard let URL = URL else { return }
            
            self?.present(SFSafariViewController(url: URL), animated: true, completion: nil)
        }
        
        textView.addSubview(embeddedView)
        
        textView.resignFirstResponder()
        backView.removeFromSuperview()
        
    }


}


