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
import SearchTextField
import RegeributedTextView
import BEMCheckBox
import Fuzi
import SystemConfiguration



 class ViewController: UIViewController, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, TLPhotosPickerViewControllerDelegate, RegeributedTextViewDelegate, BEMCheckBoxDelegate, UITextFieldDelegate {

    var textView: RegeributedTextView!
    
    @IBOutlet weak var titleTextView: TitleTextView!
    
    static var selfView: UIView!
    var selectedAt: Int!
    
    let playerViewController = AVPlayerViewController()
    
    // ORGのURLを入力する
    var orgTextField: UITextField!
    var orgOptionalTextField: UITextField!
    var orgPreviewTextField: UITextField!
    var embeddedView: URLEmbeddedView!
    
    // ポップアップのバックに表示するView
    let backView = UIView()
    let orgBackView = UIView()
    var postOgpbackView: UIView!
    var postMensionBackView: UIView!
    
    // TextView内にある写真、動画をクリックした際に使用する
    var textInSelectImage = UIImage()
    var textInSelectMovie = UIImage()
    
    
    //var selectedImage = UIImageView()
    let selectTextInImage = UIView()
    
    // テキスト内の文字か画像かをカーソルサイズで判断する
    var textSize: CGRect!
    
    var images = [UIImage]()
    var testImages = [UIImage]()
    
    // カメラロール
    var selectedAssets = [TLPHAsset]()
    
    let mesionTextField = UITextField()
    
    // メンション表示
    var users: SearchTextFieldItem!
    static var searchField: SearchTextField!
    
    // 複数画像アップロードにカーソルを位置を知っておくため
    var nowCursor: NSRange!
    var selectTextRange: UITextRange!
    
    var checkButton: BEMCheckBox!
    var checkboxLabel: UILabel!
    
    let toolBar = UIToolbar()
    
    // ビデオのURLを格納
    var videoURLs: [URL]? = []
    var videoImages: [(range: NSRange, image: UIImage, url: URL?)] = []
    var isVideo = false
    var isCheckInsertVideo = false
    
   // let scrollView = UIScrollView()
   // @IBOutlet weak var scrollView: UIScrollView!
    
    // キーボードのCGRect
    var keyboardFrame: CGRect!
    var i = 0
    
    static let isIphoneX: Bool = {
        guard #available(iOS 11.0, *),
            UIDevice.current.userInterfaceIdiom == .phone else {
                return false
        }
        let nativeSize = UIScreen.main.nativeBounds.size
        let (w, h) = (nativeSize.width, nativeSize.height)
        let (d1, d2): (CGFloat, CGFloat) = (1125.0, 2436.0)
        return (w == d1 && h == d2) || (w == d2 && h == d1)
    }()
    
    var timer: Timer?
    // 分割したTextをHTML化し、格納
    var htmls = [String]()
    var attachments = [(range: NSRange, image: UIImage)]()
    var convertAttributeText: NSAttributedString!
    
    // メンションのアカウント名を配列にぶち込む
    var mensionUserName = [String]()
    
    // 文字列置換するために、リンク挿入のリンクと任意テキストを格納
    var urlText = [(url: String, urlText: String?)]()
    var urlSubText: String!
    
    var titleText: String!
    
    var sumHtml: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textView = RegeributedTextView()
        ViewController.selfView = self.view
        addToolBar()
        
        self.textView.delegate = self
        self.titleTextView.delegate = self
        titleTextView.placeHolder = "タイトルを入力"
        titleTextView.PlaceHolderColor = UIColor.darkGray
        self.view.addSubview(titleTextView)
        titleTextView.font = UIFont.systemFont(ofSize: 28)
        titleTextView.isScrollEnabled = false
        
        
        self.textView.becomeFirstResponder()
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillBeShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        textView.font = UIFont.systemFont(ofSize: 16)
       // scrollView.contentSize = CGSize(width: self.view.frame.width, height: self.scrollView.frame.height + 100)
        print(textView.frame.maxY)
       // scrollView.backgroundColor = UIColor.darkGray
        self.view.addSubview(textView)
       // titleTextView.frame = CGRect(x: 0, y: self.textView.frame.origin.y - 6, width: self.view.frame.width, height: 54)
//        self.scrollView.addSubview(titleTextView)
//        self.scrollView.addSubview(textView)
       
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.textView.becomeFirstResponder()
       
        self.nowCursor = nil
        self.sumHtml = ""
        
    }
    
    
    func textViewDidChange(_ textView: UITextView) {
        let size:CGSize = titleTextView.sizeThatFits(titleTextView.frame.size)
        titleTextView.frame.size.height = size.height

        view.layoutIfNeeded()
        //タイトルが2行以上になる場合にtextViewの位置を変える
        self.textView.frame.origin.y = titleTextView.frame.height + titleTextView.frame.origin.y + 5
        
//        self.scrollView.contentSize = CGSize(width: self.view.frame.width, height: scrollView.frame.height + self.textView.frame.height)
//        var point = CGPoint(x: 0, y: scrollView.frame.origin.y + self.textView.frame.height)
//        self.scrollView.setContentOffset(point, animated: false)
        
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {

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
        selectedAt = textView.selectedRange.location
        selectTextInImage.removeFromSuperview()
      
        print(textView.selectedRange.location)
        print(textView.selectedRange.length)
        let textRange: UITextRange? = self.textView.selectedTextRange//selectTextRange
        if textRange == nil {return}
        //print(textRange)
        textSize = self.textView.caretRect(for: (textRange?.start)!)
            print("\(textSize)" + " ⬅ カーソル位置")
            if textSize.height >= 95 {
                print("背景挿入するよー")
                //selectTextInImage = UIView()
                selectTextInImage.frame = CGRect(x: textSize.origin.x - self.textInSelectImage.size.width + 1, y: textSize.origin.y - 2, width: self.textInSelectImage.size.width, height: textSize.size.height + 1)
                selectTextInImage.layer.borderColor = UIColor.green.cgColor
                selectTextInImage.layer.borderWidth = 4
                selectTextInImage.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.4)
                textView.tintColor = UIColor.clear
                self.textView.addSubview(selectTextInImage)
                print("\(selectTextInImage.frame)" + " ⬅ 画像のサイズ確認")
                
            } else {
                print("No Selected")
                textView.tintColor = UIColor(red: 0, green: 122/255, blue: 255/255, alpha: 1)
                selectTextInImage.removeFromSuperview()
//                self.textView.isEditable = true
//                self.textView.isSelectable = true
            }
    }
    
    // MOVからmp4に変換
    func convertVideo(inputURL: URL, outputURL: URL, handler: @escaping (_ exportSession: AVAssetExportSession) -> Void) {
        let asset: AVURLAsset = AVURLAsset(url: inputURL.absoluteURL, options: nil)
        let exportSession: AVAssetExportSession = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetPassthrough)!
        exportSession.outputURL = outputURL.absoluteURL
        exportSession.outputFileType = AVFileType.mp4
        exportSession.exportAsynchronously (completionHandler: {() -> Void in
            handler(exportSession)
        })
    }
    
    @objc func setVideoImage(notification: Notification) {
        print("通知きたーーー")
        print(self.images.count)
        if isVideo {
            for i in 0..<self.images.count {
                self.videoImages[i].url = self.videoURLs![i]
                print("\(self.videoImages[i])" + "3333333333333")
            }
            self.isVideo = false
        }
        
        self.images.removeAll()
    }
    
    
    // アルバムから画像取得するおーー
    func dismissPhotoPicker(withTLPHAssets: [TLPHAsset]) {
        self.selectedAssets = withTLPHAssets
        print("\(self.selectedAssets.count)" + "枚の画像選択したおー")
        self.nowCursor = self.textView.selectedRange
        selectTextRange = self.textView.selectedTextRange
        var insertUrl: URL!
        
        for img in self.selectedAssets.reversed() {
            self.images.append(img.fullResolutionImage!)
            //self.nowCursor = self.textView.selectedRange
            
            if isVideo {
             
                var writeURL: URL? = nil
                if #available(iOS 10.0, *) {
                    var url: URL? = nil
                    PHImageManager.default().requestAVAsset(forVideo: img.phAsset!, options: nil) { (avasset, audioMix, info) in
                        
                        
                        if let urlAsset = avasset as? AVURLAsset {
                            url = urlAsset.url
                             print(url)
                            self.videoURLs?.append(url!)
                            self.videoURLs?.reverse()
                        }else if let sandboxKeys = info?["PHImageFileSandboxExtensionTokenKey"] as? String, let path = sandboxKeys.components(separatedBy: ";").last {
                            url = URL(fileURLWithPath: path)
                            print(url)
                            self.videoURLs?.append(url!)
                            self.videoURLs?.reverse()
                        }
                        
                    }
                    
                    print("iOS10以上！")
                    writeURL = FileManager.default.temporaryDirectory.appendingPathComponent("\(img.originalFileName!)")
//                    self.videoURLs?.append(url!)
//                    self.videoURLs?.reverse()
                } else {
                    print("iOS10以下！")
                    writeURL = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true).appendingPathComponent("\(img.originalFileName!)")
                    self.videoURLs?.append(writeURL!)
                    self.videoURLs?.reverse()
                }
               
            } else {

            }
            
        }
        
            for oneImage in self.images {
                self.textInSelectImage = self.resizeUIImageByWidth(image: oneImage, width: Double(self.view.frame.width - 20))
                print("\(self.textView.selectedRange)" + " ⬅ カーソル位置だおーー")
                
                self.insertViewToImage(selectRange: nowCursor, selectTextRange: selectTextRange, url: nil)

                // 入力中のところから装飾した場合に使用。これの処理以降に装飾される
                //self.textView.typingAttributes = [NSAttributedStringKey.font.rawValue: UIFont.systemFont(ofSize: 14)]
            }
//        }
        
        if self.videoURLs! != [] {
            NotificationCenter.default.addObserver(self, selector: #selector(self.setVideoImage), name: NSNotification.Name(rawValue: "setVideoImage"), object: nil)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "setVideoImage"), object: nil)
        } else {
            
        }
        
        
        self.images.removeAll()
        self.textView.becomeFirstResponder()
        //self.isVideo = false
      
        // allowLossyConversion 変換中に必要に応じて文字を削除または置換できるかどうかを示します。
//        let encoded = sumHtml.data(using: String.Encoding.utf8, allowLossyConversion: true)!
//        let attributedOptions : [NSAttributedString.DocumentReadingOptionKey : Any] = [
//            .documentType : NSAttributedString.DocumentType.html,
//            ]
//        let attributedTxt = try! NSAttributedString(data: encoded, options: attributedOptions, documentAttributes: nil)
//        //textView.attributedText = attributedTxt
       // textView.attributedText = convertAttributeText
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func addToolBar() {
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.tintColor = UIColor(red: 76/255, green: 217/255, blue: 100/255, alpha: 1)
        
        let cameraButton = UIBarButtonItem(image: UIImage(named: "camera")?.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(self.cameraMode))
        
        let movieButton = UIBarButtonItem(image: UIImage(named: "video")?.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(self.movieMode))
        
        let ogpButton = UIBarButtonItem(image: UIImage(named: "link")?.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(self.ogpMode))
        
        let spaceButton3 = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.fixedSpace, target: nil, action: nil)
        spaceButton3.width = 120
        
        let mensionButton = UIBarButtonItem(image: UIImage(named: "mention")?.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(self.mensionMode))
        
        let spaceButton4 = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.fixedSpace, target: nil, action: nil)
        spaceButton4.width = 10

        let spaceButton5 = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.fixedSpace, target: nil, action: nil)
        spaceButton5.width = 13
        
        let previewButton = UIBarButtonItem(image: UIImage(named: "eye")?.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(self.previewMode))
        
        toolBar.setItems([cameraButton, spaceButton5, movieButton, spaceButton5, ogpButton, spaceButton4, mensionButton, spaceButton4, spaceButton3, previewButton], animated: false)
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
        self.isVideo = true
        self.isCheckInsertVideo = true
        makePhotoLibrary(isCameraOrVideoMode: true)
    }
    
    @objc func ogpMode(){
        if postMensionBackView != nil {
            postMensionBackView.removeFromSuperview()
        }
        makeOrgView()
    }
    
    @objc func mensionMode(){
        if postOgpbackView != nil {
            postOgpbackView.removeFromSuperview()
        }
        
        ViewController.searchField = SearchTextField.init(frame: CGRect(x: self.view.frame.origin.x + 20, y: self.view.center.y / 4, width: self.view.frame.width - 40, height: 40))
        ViewController.searchField.backgroundColor = UIColor.white
        ViewController.searchField.layer.cornerRadius = 6
        ViewController.searchField.placeholder = "ユーザー名を入力"
        ViewController.searchField.becomeFirstResponder()
        
        postMensionBackView = makeMesionBackView()
        postMensionBackView.addSubview(ViewController.searchField)
        setUpSampleSearchTextField()
        
    }
    
   class func makeMensionIndicator() -> UIActivityIndicatorView {
        let indicator = UIActivityIndicatorView()
        indicator.frame.origin = CGPoint(x: ViewController.searchField.frame.width - 20, y: ViewController.searchField.bounds.origin.y + 20)
        indicator.hidesWhenStopped = true
    
        ViewController.searchField.addSubview(indicator)
        indicator.activityIndicatorViewStyle = .white
        indicator.color = UIColor.lightGray
        return indicator
    }
    
    @objc func previewMode() {
        self.performSegue(withIdentifier: "toPreview", sender: nil)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toPreview" {
            self.convertToHtml()
            let previewViewController = segue.destination as! PreviewViewController
            previewViewController.convertAttributeText = self.convertAttributeText
            previewViewController.titleText = self.titleText
            previewViewController.testHTML = self.sumHtml
        }
    }
    
    // 動画からサムネイルを生成する
    func previewImageFromVideo(_ url:URL) -> UIImage? {
        let asset = AVURLAsset(url:url)
        let imageGenerator = AVAssetImageGenerator(asset:asset)
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
        postOgpbackView = makeMesionBackView()
        
        orgBackView.frame.size.width = self.view.frame.width
        orgBackView.frame.size.height = 240
        orgBackView.backgroundColor = UIColor.white
        orgBackView.center.y = postOgpbackView.center.y - 140
        postOgpbackView.addSubview(orgBackView)
        
        orgTextField = makeOrgTextField(placeholder: "http://", y:  orgBackView.frame.height / 6)
        orgOptionalTextField = makeOrgTextField(placeholder: "任意テキスト", y: orgTextField.frame.height + 50)
        orgOptionalTextField.addTarget(self, action: #selector(self.previewText) , for: UIControlEvents.editingChanged)
        orgTextField.addTarget(self, action: #selector(self.previewText), for: UIControlEvents.editingChanged)
        orgPreviewTextField = makeOrgTextField(placeholder: "", y: orgOptionalTextField.frame.height + 95)
        let cancelButton = makeOrgButton(x: orgBackView.center.x / 2, title: "キャンセル", action: #selector(self.cancelOrg))
        _ = makeOrgButton(x: orgBackView.frame.size.width / 2*1.5, title: "入力", action: #selector(self.setOrg))
        orgPreviewTextField.isEnabled = false
        
        checkboxLabel = makeOrgLabel(x: orgBackView.frame.origin.x + 50, y: cancelButton.frame.origin.y - 50)
        
        makeOrgCheckbox(x: orgBackView.frame.origin.x + 21, y: cancelButton.frame.origin.y - 38)
        
        if (UIPasteboard.general.string != nil && ((UIPasteboard.general.string?.range(of: "http")) != nil)) {
            orgTextField.text = UIPasteboard.general.string
        }
        
        if !(self.orgTextField.text?.isEmpty)! {
            self.orgPreviewTextField.text =
                self.orgTextField.text
            self.orgPreviewTextField.textColor = UIColor(red: 0, green: 122/255, blue: 255/255, alpha: 1)
            let stringAttributes: [NSAttributedStringKey: Any] = [.underlineStyle: NSUnderlineStyle.styleSingle.rawValue, .underlineColor: UIColor(red: 0, green: 122/255, blue: 255/255, alpha: 1)]
            let previewString = NSAttributedString(string: self.orgTextField.text!, attributes: stringAttributes)
            self.orgPreviewTextField.attributedText = previewString
            
        }
    }
    
    @objc func previewText() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            if !(self.orgOptionalTextField.text?.isEmpty)! && !(self.orgTextField.text?.isEmpty)! {
                print("任意テキスト出す〜")
                
                self.orgPreviewTextField.textColor = UIColor(red: 0, green: 122/255, blue: 255/255, alpha: 1)
                let stringAttributes: [NSAttributedStringKey: Any] = [.underlineStyle: NSUnderlineStyle.styleSingle.rawValue, .underlineColor: UIColor(red: 0, green: 122/255, blue: 255/255, alpha: 1)]
                let previewString = NSAttributedString(string: self.orgOptionalTextField.text!, attributes: stringAttributes)
                self.orgPreviewTextField.attributedText = previewString
            } else if !(self.orgTextField.text?.isEmpty)! && (self.orgOptionalTextField.text?.isEmpty)! {
                self.orgPreviewTextField.textColor = UIColor(red: 0, green: 122/255, blue: 255/255, alpha: 1)
                let stringAttributes: [NSAttributedStringKey: Any] = [.underlineStyle: NSUnderlineStyle.styleSingle.rawValue, .underlineColor: UIColor(red: 0, green: 122/255, blue: 255/255, alpha: 1)]
                let previewString = NSAttributedString(string: self.orgTextField.text!, attributes: stringAttributes)
                self.orgPreviewTextField.attributedText = previewString
            }
        }
    }
  
    
    func makeOrgLabel(x: CGFloat, y: CGFloat) -> UILabel {
        let label = UILabel()
        label.frame = CGRect(x: x, y: y, width: 100, height: 45)
        label.text = "埋め込み"
        label.textColor =
            UIColor.darkGray
        orgBackView.addSubview(label)
        return label
    }
    
    func makeOrgCheckbox(x: CGFloat, y: CGFloat) {
        checkButton = BEMCheckBox.init(frame: CGRect(x: x, y: y, width: 20, height: 20))
        checkButton.delegate = self
        checkButton.boxType = .square
        checkButton.onFillColor = UIColor(red: 0, green: 122/255, blue: 255/255, alpha: 1)
        checkButton.onCheckColor = UIColor.white
        orgBackView.addSubview(checkButton)
    }
    
    func makeOrgButton(x: CGFloat, title: String, action: Selector) -> UIButton {
        let button = UIButton()
        button.frame.size.width = orgBackView.frame.size.width / 2
        button.frame.size.height = orgTextField.frame.size.height
        button.center.x = x
        button.center.y = orgBackView.frame.size.height - 16
        button.setTitle(title, for: .normal)
        button.setTitleColor(UIColor.lightGray, for: .normal)
        button.addTarget(self, action: action, for: .touchUpInside)
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.lightGray.cgColor
        orgBackView.addSubview(button)
        return button
    }
    
    func makeMensionButton(x: CGFloat, y: CGFloat, title: String, action: Selector, view: UIView) -> UIButton {
        let button = UIButton()
        button.frame.size.width = ViewController.searchField.frame.size.width/2
        button.frame.size.height = ViewController.searchField.frame.size.height
        button.frame.origin.x = x
        button.frame.origin.y = y
        button.setTitle(title, for: .normal)
        button.setTitleColor(UIColor.lightGray, for: .normal)
        button.addTarget(self, action: action, for: .touchUpInside)
        button.layer.cornerRadius = 4
        button.layer.borderWidth = 1
        button.backgroundColor = UIColor.white
        button.tintColor = UIColor.gray
        button.layer.borderColor = UIColor.lightGray.cgColor
        view.addSubview(button)
        return button
    }
    
    func makeOrgTextField(placeholder: String, y: CGFloat) -> UITextField {
        let orgTextField = UITextField()
        orgTextField.frame.size.width = orgBackView.frame.size.width - 40
        orgTextField.frame.size.height = orgBackView.frame.height / 7
        orgTextField.center.y = y
        orgTextField.center.x = orgBackView.center.x
        orgTextField.backgroundColor = UIColor.groupTableViewBackground
        orgTextField.layer.cornerRadius = 6
        orgTextField.placeholder = placeholder
        orgBackView.addSubview(orgTextField)
        return orgTextField
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
        let view = UIView()
        view.frame = self.view.frame
        view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.6)
        self.view.addSubview(view)
        return view
    }
    
    // 埋め込みのチェックボックスをタップした際に呼ばれる
    func didTap(_ checkBox: BEMCheckBox) {
        if checkBox.on {
            self.checkboxLabel.textColor = UIColor(red: 0, green: 122/255, blue: 255/255, alpha: 1)
        } else {
            self.checkboxLabel.textColor = UIColor.black
        }
    }
    
    
    @objc func setOrg() {
        if (orgTextField.text?.isEmpty)! {
            let alert = UIAlertController(title: "URLを入力してください", message: nil, preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(action)
            present(alert, animated: true, completion: nil)
            textView.resignFirstResponder()
            return
        }
        
        if checkButton.on {
            embeddedView = URLEmbeddedView()
            embeddedView.tag = 1
            embeddedView.loadURL(self.orgTextField.text!) { error in
                print(error)
            }
            
            DispatchQueue.main.async {
                if self.embeddedView.isImageChack == false {
                    print("エラー画像ないｓだよ！！")
                } else {
                    print("休憩")
                }
            
            }
            
            
//            OGImageProvider.shared.loadImage(urlString: self.orgTextField.text!) { image, error in
//               print(image)
//                if image != nil {
//                    print("画像あるよー")
//                    self.embeddedView.loadURL(self.orgTextField.text!)
//                    self.embeddedView.frame.size = CGSize(width: self.view.frame.width / 1.2, height: 100)
//                    self.embeddedView.center.x = self.view.center.x
//                    self.embeddedView.center.y = self.textView.frame.height + 10
//
//                    // 0.8秒後に実行したい処理
//                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
//                        self.textInSelectImage = self.embeddedView.viewToImage(view: self.embeddedView)
//                        self.selectTextRange = self.textView.selectedTextRange
//                        self.insertViewToImage(selectRange: self.textView.selectedRange, selectTextRange: self.selectTextRange!)
//                    }
//
//                } else {
//                    print(error)
//                    print("生成するよーー")
//
//                    self.embeddedView = nil
//                }
//
//            }
            
            
            embeddedView.frame.size = CGSize(width: self.view.frame.width / 1.2, height: 100)
            embeddedView.center.x = self.view.center.x
            embeddedView.center.y = self.textView.frame.height - 40
            
            // 0.8秒後に実行したい処理
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                self.textInSelectImage = self.embeddedView.viewToImage(view: self.embeddedView)
                self.selectTextRange = self.textView.selectedTextRange
                self.insertViewToImage(selectRange: self.textView.selectedRange, selectTextRange: self.selectTextRange!, url: nil)
            }
           
            
            checkButton.setOn(false, animated: false)
        //}
           // OGP選択時にWebViewを開く
           // textView.addSubview(embeddedView)
//            embeddedView.didTapHandler = { [weak self] embeddedView, URL in
//                guard let URL = URL else { return }
//                print("WebView開くよー")
//                //self?.present(SFSafariViewController(url: URL), animated: true, completion: nil)
//                UIApplication.shared.open(URL, options: [:], completionHandler: nil)
//            }
        }
    else {
            if let range = self.textView.selectedTextRange {
                print("挿入するぞーーーーーー")
                self.textView.replace(range, withText: " " + self.orgPreviewTextField.text! + " ")
                self.textView.addAttributes(orgPreviewTextField.text!, values: ["URL": self.orgTextField.text!], attributes: [.underline(UnderlineStyle.single), .underlineColor(UIColor(red: 0, green: 122/255, blue: 255/255, alpha: 1)), .textColor(UIColor(red: 0, green: 122/255, blue: 255/255, alpha: 1))])
            }
        }
        
        if !(self.orgOptionalTextField.text?.isEmpty)! && !(self.orgTextField.text?.isEmpty)! {
            self.urlText.append((url: self.orgTextField.text!, urlText: self.orgOptionalTextField.text!))
            print("\(self.orgOptionalTextField.text!)" + "サブテキストありーーー")
        } else if !(self.orgTextField.text?.isEmpty)! && (self.orgOptionalTextField.text?.isEmpty)! {
            self.urlText.append((url: self.orgTextField.text!, urlText: nil))
            print("\(self.orgTextField.text!)" + "urlのみーー")
        }
        
        textView.resignFirstResponder()
        postOgpbackView.removeFromSuperview()
    }
    
    
    // テキストView内のリンクをタップした際にWebに遷移させる
    func regeributedTextView(_ textView: RegeributedTextView, didSelect text: String, values: [String : Any]) {
        self.textView.isScrollEnabled = false
        //self.textView.layoutManager.allowsNonContiguousLayout = false
//        let selectedText = text
//
//        if (textView.text.range(of: selectedText) != nil) {
//            self.textView.addAttribute(text, attribute: .backgroundColor(UIColor(red: 0, green: 20, blue: 255, alpha: 0.4)))
//
//             DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
//                self.textView.addAttribute(text, attribute: .backgroundColor(.clear))
//            }
//        }
        
        
        print("リンク or メンションをタップしたよー" + "\(self.textView.selectedRange)")
        
//        if let url = values["URL"] as? String {
//            UIApplication.shared.open(URL(string: url)!, options: [:], completionHandler: nil)
//        }
    }
    
    func insertViewToImage(selectRange: NSRange, selectTextRange: UITextRange, url: URL?) {
        let lineSpace = NSAttributedString(string: "\n\n\n")
        let selectedImage = NSTextAttachment()
        selectedImage.image = self.textInSelectImage
        let strImage = NSAttributedString(attachment: selectedImage)
        
        let textRange = selectTextRange
        let beginning = self.textView.beginningOfDocument
        let ending = self.textView.endOfDocument
        let startPosition = textRange.start
        let startPos = self.textView.offset(from: beginning, to: startPosition)
        let endPos = self.textView.offset(from: startPosition, to: ending)
        let oriRange = NSMakeRange(0, startPos)
        let oriRangeRight = NSMakeRange(selectRange.location, endPos)
        
        if self.isVideo {
            print("ビデオ保存するよー")
            print(self.images.count)
         
            self.videoImages.append((oriRangeRight, self.textInSelectImage, nil))
        } else {
            print("ビデオ保存できてないよー")
        }
        
        print("\(startPos)" + "startPosだよー")
        print("\(endPos)" + "endPosだよー")
        print("\(oriRangeRight)" + "oriRangeRightだよー")
        
        let str = NSMutableAttributedString()
        
        if self.textView.text.isEmpty {
            str.append(self.textView.attributedText)
            str.append(lineSpace)
            str.append(strImage)
        } else {
        str.append(self.textView.attributedText.attributedSubstring(from: oriRange))
            str.append(lineSpace)
            str.append(strImage)
            str.append(lineSpace)
            str.append(self.textView.attributedText.attributedSubstring(from: oriRangeRight))
        }
        self.textView.attributedText = str
        
    }
    
    // 下書き保存 & 自動保存のときに呼び出す
    func convertToHtml() -> [UIImage] {
        self.attachments = [(range: NSRange, image: UIImage)]()
        let range = NSRange(location: 0, length: textView.attributedText.length)
        self.textView.attributedText.enumerateAttribute(.attachment, in: range, options: [], using: { (value, range, stop) in
            if let attachment = value as? NSTextAttachment {
                if let image = attachment.image {
                    attachments.append((range, image))
                    print("\(range)" + "画像位置")
                } else if let image = attachment.image(forBounds: attachment.bounds,
                                                       textContainer: nil,
                                                       characterIndex: range.location) {
                    attachments.append((range, image))
                }
            }
        })
        
        if attachments.count > 0 {
            var i = 0
            let j = 1
            var num = 0
            let setNum = 3
            var isFirst = true
            let attT = textView.attributedText!
            let documentAttributes = [NSAttributedString.DocumentAttributeKey.documentType: NSAttributedString.DocumentType.html]
            let startRange = NSMakeRange(0, attachments[0].range.location)
            let htmlData = try! attT.data(from: startRange, documentAttributes: documentAttributes)
            let html = String(data: htmlData, encoding: .utf8)
            textToHtml(getRange: startRange)
            print(attachments.count)
            
            
            (j ..< attachments.count).forEach({ (nil) in
                print("画像表示")
                num = 0
                isFirst = true
                (num ..< self.videoImages.count).forEach({ (nil) in
                    print(attachments[i].range)
                    print(self.videoImages[num].range)
                    
                    if self.videoImages.count > 1 && i != 0 {
                        print("1以上かつnumが0じゃない")
                            if attachments[i].range.location == self.videoImages[num].range.location + setNum+4 {
                                let nextImageRange = NSMakeRange(attachments[i].range.location + 1, attachments[j].range.location - attachments[i].range.location - 1)
                                let imageRange = NSMakeRange(attachments[i].range.location, 1)
                                videoToHtml(getRange: imageRange, i: i)
                                textToHtml(getRange: nextImageRange)
                                print("カーソル位置が一致")
                            } else {
                                print("カーソル位置が一致していない。。")
                            }
                            num += 1
                        
                        
                    } else if self.videoImages.count > 1 && i == 0 && isFirst {
                        print("1以上かつnumが0のとき")
                        print(i)
                        if attachments[i].range.location == self.videoImages[num].range.location + setNum {
                            let nextImageRange = NSMakeRange(attachments[i].range.location + 1, attachments[j].range.location - attachments[i].range.location - 1)
                            let imageRange = NSMakeRange(attachments[i].range.location, 1)
                            videoToHtml(getRange: imageRange, i: i)
                            textToHtml(getRange: nextImageRange)
                            print("カーソル位置が一致")
                        } else {
                            print("カーソル位置が一致していない。。")
                        }
                        num += 1
                        isFirst = false
                    }
                    
                })
                i += 1
                
                if self.videoImages.count == 0 {
                    let nextImageRange = NSMakeRange(attachments[i].range.location + 1, attachments[j].range.location - attachments[i].range.location - 1)
                    let imageRange = NSMakeRange(attachments[i].range.location, 1)
                    imageToHtml(getRange: imageRange, i: i)
                    textToHtml(getRange: nextImageRange)
                    print("ここにはこない")
                   
                } else if self.videoImages.count > 1 {
                    print("ここにくるーー")
                    print(i)
//                    let nextImageRange = NSMakeRange(attachments[i + 1].range.location + 1, attachments[j].range.location - attachments[i].range.location - 1)
//                    let imageRange = NSMakeRange(attachments[i].range.location, 1)
                    videoToHtml(getRange: NSMakeRange(attachments[i].range.location, 1), i: i)
                    textToHtml(getRange: NSMakeRange(attachments[j-1].range.location + 1, self.textView.text.count - attachments[j-1].range.location - 1))
                    
                 
                }
                
            })
            
            
           //  画像がひとつだけ、プラス、最後の画像のところがvideoかどうかチェック
//            if isCheckInsertVideo  {
//                videoToHtml(getRange: NSMakeRange(attachments[i].range.location, 1), i: i)
//
//                textToHtml(getRange: NSMakeRange(attachments[j-1].range.location + 1, self.textView.text.count - attachments[j-1].range.location - 1))
//                print("最後の①枚Video")
//
//            } //else {
//                imageToHtml(getRange: NSMakeRange(attachments[i].range.location, 1), i: i)
//
//                textToHtml(getRange: NSMakeRange(attachments[j-1].range.location + 1, self.textView.text.count - attachments[j-1].range.location - 1))
//                print("最後の①枚Image")
//            }
//            // 画像がひとつだけなら以下を実行
//            imageToHtml(getRange: NSMakeRange(attachments[i-1].range.location, 1), i: i-1)
//
//            textToHtml(getRange: NSMakeRange(attachments[j-1].range.location + 1, self.textView.text.count - attachments[j-1].range.location - 1))

        } else {
            let oriRange = NSMakeRange(0, self.textView.text.count)
//            let oriRangeRight = NSMakeRange(attachments[0].range.location, self.textView.text.count - attachments[0].range.location)
            textToHtml(getRange: oriRange)
           // textToHtml(getRange: oriRangeRight)
        }
        
        isCheckInsertVideo = false
        
        sumHtml = self.htmls.joined()
        
        // リンクをHTML化
        if self.urlText.count > 0 {
            for i in self.urlText {
                print(i)
                
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
            sumHtml = "<html><title>\(self.titleTextView.text!)</title>" + sumHtml + "</html>"
        } else {
            sumHtml = "<title>NO TITLE</title>\n\n" + sumHtml
        }
        
        do {
            let test = try HTMLDocument(string: sumHtml, encoding: .utf8)
            self.titleText = test.title
            
        } catch {
            print("エラーよー")
        }
        
       print(sumHtml)
        
        // Font、FontSizeがぶっ壊れてしまうバグを解消
        convertAttributeText = sumHtml.convertHtml(withFont: UIFont(name: "Helvetica", size: 16), align: .left)
        print(convertAttributeText)
        
        self.videoURLs?.removeAll()
        return self.testImages
    }
    
    func textToHtml(getRange: NSRange) {
        let documentAttributes = [NSAttributedString.DocumentAttributeKey.documentType: NSAttributedString.DocumentType.html]
        let attT = textView.attributedText!
        let htmlData = try! attT.data(from: getRange, documentAttributes: documentAttributes)
        let html = String(data: htmlData, encoding: .utf8)
        do {
            let doc = try HTMLDocument(string: html!, encoding: .utf8)
           // print(doc.body?.rawXML)
             self.htmls.append((doc.body?.rawXML)!)
        } catch let error {
            print(error)
        }
    }
    
    func imageToHtml(getRange: NSRange, i: Int) {
        let documentAttributes = [NSAttributedString.DocumentAttributeKey.documentType: NSAttributedString.DocumentType.html]
        let attT = textView.attributedText!
        let htmlData = try! attT.data(from: getRange, documentAttributes: documentAttributes)
        print("だめだよ！")
        // 画像だけのHTML全体を取得
        let html = String(data: htmlData, encoding: .utf8)
        //print("\(html)" + "動画のHTMLだよー")
        do {
            let doc = try HTMLDocument(string: html!, encoding: .utf8)
            let changeString = "file:///Attachment.png"
           
            self.htmls.append((doc.body?.rawXML.replacingOccurrences(of: changeString, with: "data:image/png;base64,\(convertImageToBase64(image: self.attachments[i].image))"))!)
        } catch let error {
            print(error)
        }
    }
    
    func videoToHtml(getRange: NSRange, i: Int) {
        
        let documentAttributes = [NSAttributedString.DocumentAttributeKey.documentType: NSAttributedString.DocumentType.html]
        let attT = textView.attributedText!
        let htmlData = try! attT.data(from: getRange, documentAttributes: documentAttributes)
        // 画像だけのHTML全体を取得
        let html = String(data: htmlData, encoding: .utf8)
        print("\(html)" + "動画のHTMLだよー")
        do {
            let doc = try HTMLDocument(string: html!, encoding: .utf8)
            let changeString = "<img src=\"file:///Attachment.png\" alt=\"Attachment.png\">"
            
            self.htmls.append((doc.body?.rawXML.replacingOccurrences(of: changeString, with: "<video controls width=\"\(self.view.frame.width-5)\" height=\"450\"><source src=\"\(self.videoURLs![i].absoluteString)\"></video>"))!)
            print(doc.body?.rawXML.replacingOccurrences(of: changeString, with: "<video controls width=\"\(self.view.frame.width-5)\" height=\"450\"><source src=\"\(self.videoURLs![i].absoluteString)\"></video>"))
           
        } catch let error {
            print(error)
        }
    }
    
    func convertImageToBase64(image: UIImage) -> String{
        let imageData = UIImagePNGRepresentation(image)
        let stringImageData = imageData?.base64EncodedString(options: Data.Base64EncodingOptions.lineLength64Characters)
        //空白を+に変換する
        let base64String = stringImageData?.replacingOccurrences(of: " ", with: "+")
        return base64String!
    }
    
    
    @objc func cancelOrg() {
        postOgpbackView.removeFromSuperview()
        orgTextField.text = ""
        orgOptionalTextField.text = ""
    }
    
    @objc func textFieldEditingChanged() {
        UserManager.sharedInstance.users = []
//        UserManager.sharedInstance.fetchUsers(keyword: ViewController.searchField.text!)
       
    }
    
    func setUpSampleSearchTextField() {
        ViewController.searchField.delegate = self
        ViewController.searchField.addTarget(self, action: #selector(self.textFieldEditingChanged), for: .editingChanged)

        print("\(UserManager.sharedInstance.users.count)" + "メンションユーザー")
        
        ViewController.searchField.theme.font = UIFont.systemFont(ofSize: 16)
        ViewController.searchField.theme.bgColor = UIColor.white
        ViewController.searchField.theme.separatorColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 0.5)
        ViewController.searchField.theme.cellHeight = 50
        
        let cancelButton = self.makeMensionButton(x: ViewController.searchField.frame.origin.x, y: ViewController.searchField.frame.origin.y + ViewController.searchField.frame.height, title: "キャンセル", action: #selector(self.cancelMension), view: self.postMensionBackView)
        
        let submitButton = self.makeMensionButton(x: ViewController.searchField.center.x, y: ViewController.searchField.frame.origin.y + ViewController.searchField.frame.height, title: "入力", action: #selector(self.setMension), view: self.postMensionBackView)
        
        
        // returnキーを押したらの処理
        ViewController.searchField.itemSelectionHandler = { filteredResults, itemPosition in
            let item = filteredResults[itemPosition]
            print("Item at position \(itemPosition): \(item.title)")
            
            ViewController.searchField.text = item.title
            
            cancelButton.alpha = 1
            submitButton.alpha = 1
            
        }
        
        ViewController.searchField.userStoppedTypingHandler = {
            if let criteria = ViewController.searchField.text {
                self.timer?.invalidate()
                
                if criteria.characters.count > 1 {
                    self.timer = Timer.scheduledTimer(timeInterval: 0.8, target: self, selector: #selector(self.search), userInfo: criteria, repeats: false)
                    cancelButton.alpha = 0
                    submitButton.alpha = 0
                } else if criteria.characters.count == 0 {
                    cancelButton.alpha = 1
                    submitButton.alpha = 1
                }
            }
        }
    }
    
    @objc func search(_ timer:Timer) {
        UserManager.sharedInstance.fetchUsers(keyword: timer.userInfo as! String)
    }
    
    @objc func cancelMension() {
        postMensionBackView.removeFromSuperview()
        ViewController.searchField.text = ""
    }
    
    @objc func setMension() {
        self.postMensionBackView.removeFromSuperview()
        
        if let range = self.textView.selectedTextRange {
            self.textView.replace(range, withText: "@" + ViewController.searchField.text! + " ")
            self.textView.addAttribute(.mention, attribute: .textColor(UIColor(red: 0, green: 122/255, blue: 255/255, alpha: 1)))
        }
        self.mensionUserName.append(ViewController.searchField.text!)
    }

    @objc func keyboardWillBeShow(notification: NSNotification) {
        if let keyboardFrame = (notification.userInfo![UIKeyboardFrameEndUserInfoKey] as AnyObject).cgRectValue {
        self.keyboardFrame = keyboardFrame
            if i == 0 {
                if ViewController.isIphoneX {
                    print("iPhoneXだ！！")
                    let y = (titleTextView.frame.height + titleTextView.frame.origin.y) + (self.keyboardFrame.size.height + toolBar.frame.height)
                    let insertY = (self.view.bounds.height + 10) - y
                    textView.frame = CGRect(x: 0, y: self.titleTextView.frame.origin.y + self.titleTextView.frame.height + 30, width: self.view.frame.width, height: insertY)
                    print(textView.frame.maxY)
                   // self.scrollView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.textView.frame.maxY)
                    print(textView.frame.maxY)
                    self.textView.placeHolder = "本文を入力"
                    self.textView.PlaceHolderColor = UIColor.darkGray
                    i += 1
                } else {
                    print("iPhoneX以外だよーーー")
                    let y = (titleTextView.frame.height + titleTextView.frame.origin.y) + (self.keyboardFrame.size.height + toolBar.frame.height)
                    let insertY = (self.view.bounds.height + 38) - y
                    textView.frame = CGRect(x: 0, y: self.titleTextView.frame.origin.y + self.titleTextView.frame.height + 5, width: self.view.frame.width, height: insertY)
                    self.textView.placeHolder = "本文を入力"
                    self.textView.PlaceHolderColor = UIColor.darkGray
                    i += 1
                }
            } else {
                return
            }
       }
    }

}


