//
//  ViewController.swift
//  TestTextView
//
//  Created by 坂本貴宏 on 2018/03/07.
//  Copyright © 2018年 坂本貴宏. All rights reserved.
//

import UIKit
import SafariServices
import AVKit
import AVFoundation
import Photos
import TLPhotoPicker
import SearchTextField
import RegeributedTextView
import Fuzi
import SystemConfiguration



 class ViewController: UIViewController, UITextViewDelegate, TLPhotosPickerViewControllerDelegate, RegeributedTextViewDelegate, UITextFieldDelegate {

    @IBOutlet weak var titleTextView: TitleTextView!
    
    private let kSelectTextInImage = UIView()
    // キーボード上のツールバー
    private let kToolBar = UIToolbar()
    // iPhoneXかどうかチェック
    static let kIsIphoneX: Bool = {
        guard #available(iOS 11.0, *),
            UIDevice.current.userInterfaceIdiom == .phone else {
                return false
        }
        let nativeSize = UIScreen.main.nativeBounds.size
        let (w, h) = (nativeSize.width, nativeSize.height)
        let (d1, d2): (CGFloat, CGFloat) = (1125.0, 2436.0)
        return (w == d1 && h == d2) || (w == d2 && h == d1)
    }()
    
    private var textView: RegeributedTextView!
    // URLを入力する
    private var urlTextField: UrlTextField!
    private var urlOptionalTextField: UrlTextField!
    private var urlPreviewTextField: UrlTextField!
    // ポップアップのバックに表示するView
    private var urlBackView: UIView!
    private var postbackView: BackView!
    private var postMensionBackView: BackView!
    // TextView内にある写真、動画をクリックした際に使用する
    private var textInSelectImage = UIImage()
    // テキスト内の文字か画像かをカーソルサイズで判断する
    private var textSize: CGRect!
    private var images = [UIImage]()
    // カメラロールから取得するImage情報
    private var selectedAssets = [TLPHAsset]()
    // メンション表示
    private var users: SearchTextFieldItem!
    static var searchField: SearchTextField!
    // 複数画像アップロードにカーソルを位置を知っておくため
    private var nowCursor: NSRange!
    private var selectTextRange: UITextRange!
    // キーボードのCGRect
    private var keyboardFrame: CGRect!
    private var i = 0
    private var timer: Timer?
    // 分割したTextをHTML化し、格納
    private var htmls = [String]()
    private var attachments = [(range: NSRange, image: UIImage)]()
    private var convertAttributeText: NSAttributedString!
    // メンションのアカウント名を配列にぶち込む
    private var mensionUserName = [String]()
    // 文字列置換するために、リンク挿入のリンクと任意テキストを格納
    private var urlText = [(url: String, urlText: String?)]()
    private var titleText: String!
    private var sumHtml: String!
    private var stringAttributes: [NSAttributedStringKey: Any]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textView = RegeributedTextView()
        addToolBar()
        self.stringAttributes = [.underlineStyle: NSUnderlineStyle.styleSingle.rawValue, .underlineColor: UIColor(red: 0, green: 122/255, blue: 255/255, alpha: 1)]
        self.textView.delegate = self
        self.titleTextView.delegate = self
        titleTextView.placeHolder = "タイトルを入力"
        titleTextView.PlaceHolderColor = UIColor.darkGray
        titleTextView.font = UIFont.systemFont(ofSize: 28)
        titleTextView.isScrollEnabled = false
        self.view.addSubview(titleTextView)
        self.textView.becomeFirstResponder()
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillBeShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        textView.font = UIFont.systemFont(ofSize: 16)
        self.view.addSubview(textView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.textView.becomeFirstResponder()
        self.textView.typingAttributes = [NSAttributedStringKey.font.rawValue : UIFont.boldSystemFont(ofSize: 30)]
        self.sumHtml = ""
    }
    
    func textViewDidChange(_ textView: UITextView) {
        let size = titleTextView.sizeThatFits(titleTextView.frame.size)
        titleTextView.frame.size.height = size.height
        view.layoutIfNeeded()
        //タイトルが2行以上になる場合にtextViewの位置を変える
        self.textView.frame.origin.y = titleTextView.frame.height + titleTextView.frame.origin.y + 5
    }
    
    // TextViewのテキストにカーソル合わせたタイミングで呼ばれるおーー
    func textViewDidChangeSelection(_ textView: UITextView) {
        kSelectTextInImage.removeFromSuperview()
        guard let textRange = self.textView.selectedTextRange else {
            return
        }
        textSize = self.textView.caretRect(for: (textRange.start))
        if textSize.height >= 95 {
            kSelectTextInImage.frame = CGRect(x: textSize.origin.x - self.textInSelectImage.size.width + 1, y: textSize.origin.y - 2, width: self.textInSelectImage.size.width, height: textSize.size.height + 1)
            kSelectTextInImage.layer.borderColor = UIColor.green.cgColor
            kSelectTextInImage.layer.borderWidth = 4
            kSelectTextInImage.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.4)
            textView.tintColor = UIColor.clear
            self.textView.addSubview(kSelectTextInImage)
            
        } else {
            textView.tintColor = UIColor(red: 0, green: 122/255, blue: 255/255, alpha: 1)
            kSelectTextInImage.removeFromSuperview()
        }
    }
    
    // アルバムから画像取得する
    func dismissPhotoPicker(withTLPHAssets: [TLPHAsset]) {
        self.selectedAssets = withTLPHAssets
        self.nowCursor = self.textView.selectedRange
        selectTextRange = self.textView.selectedTextRange
        for img in self.selectedAssets.reversed() {
            self.images.append(img.fullResolutionImage!)
        }
        for oneImage in self.images {
            self.textInSelectImage = oneImage.resizeUIImageByWidth(image: oneImage, width: Double(self.view.frame.width - 20))
            self.insertViewToImage(selectRange: nowCursor, selectTextRange: selectTextRange, url: nil)
        }
        self.images.removeAll()
        self.textView.becomeFirstResponder()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func addToolBar() {
        kToolBar.barStyle = UIBarStyle.default
        kToolBar.isTranslucent = true
        kToolBar.tintColor = UIColor(red: 76/255, green: 217/255, blue: 100/255, alpha: 1)
        let cameraButton = UIBarButtonItem(image: UIImage(named: "camera")?.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(self.cameraMode))
        let movieButton = UIBarButtonItem(image: UIImage(named: "video")?.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(self.movieMode))
        let urlButton = UIBarButtonItem(image: UIImage(named: "link")?.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(self.urlMode))
        let spaceHighButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.fixedSpace, target: nil, action: nil)
        spaceHighButton.width = 120
        let mensionButton = UIBarButtonItem(image: UIImage(named: "mention")?.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(self.mensionMode))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.fixedSpace, target: nil, action: nil)
        spaceButton.width = 10
        let previewButton = UIBarButtonItem(image: UIImage(named: "eye")?.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(self.previewMode))
        
        kToolBar.setItems([cameraButton, spaceButton, movieButton, spaceButton, urlButton, spaceButton, mensionButton, spaceButton, spaceHighButton, previewButton], animated: false)
        kToolBar.isUserInteractionEnabled = true
        kToolBar.sizeToFit()
        textView.inputAccessoryView = kToolBar
    }
    
    @objc func cameraMode(){
        makePhotoLibrary(isCameraOrVideoMode: false)
    }
    
    @objc func movieMode(){
        makePhotoLibrary(isCameraOrVideoMode: true)
    }
    
    @objc func urlMode(){
        if postMensionBackView != nil {
            postMensionBackView.removeFromSuperview()
        }
        makeUrlView()
    }
    
    @objc func mensionMode(){
        if postbackView != nil {
            postbackView.removeFromSuperview()
        }
    
        ViewController.searchField = SearchTextField.init(frame: CGRect(x: self.view.frame.origin.x + 20, y: self.view.center.y / 4, width: self.view.frame.width - 40, height: 40))
        ViewController.searchField.backgroundColor = UIColor.white
        ViewController.searchField.layer.cornerRadius = 6
        ViewController.searchField.placeholder = "ユーザー名を入力"
        ViewController.searchField.becomeFirstResponder()
        
        self.postMensionBackView = BackView(frame: self.view.frame)
        postMensionBackView.setBackView(superView: self.view)
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
            previewViewController.titleText = self.titleText
            previewViewController.testHTML = self.sumHtml
        }
    }
    
    func makeUrlView() {
        self.postbackView = BackView(frame: self.view.frame)
        postbackView.setBackView(superView: self.view)
        urlBackView = UIView()
        urlBackView.frame.size.width = self.view.frame.width
        urlBackView.frame.size.height = 240
        urlBackView.backgroundColor = UIColor.white
        urlBackView.center.y = postbackView.center.y - 140
        postbackView.addSubview(urlBackView)
        self.urlTextField = UrlTextField(frame: CGRect(x: urlBackView.frame.origin.x+20, y: urlBackView.frame.height / 10, width: urlBackView.frame.size.width - 40, height: urlBackView.frame.height / 7))
        urlTextField.setTextField(placeholder: "http://", superView: urlBackView)
        urlTextField.addTarget(self, action: #selector(self.previewText), for: UIControlEvents.editingChanged)
        
        self.urlOptionalTextField = UrlTextField(frame: CGRect(x: urlBackView.frame.origin.x+20, y: urlBackView.frame.height / 3.5, width: urlBackView.frame.size.width - 40, height: urlBackView.frame.height / 7))
        urlOptionalTextField.setTextField(placeholder: "任意テキスト", superView: urlBackView)
        urlOptionalTextField.addTarget(self, action: #selector(self.previewText) , for: UIControlEvents.editingChanged)
        
        self.urlPreviewTextField = UrlTextField(frame: CGRect(x: urlBackView.frame.origin.x+20, y: urlBackView.frame.height/2.1, width: urlBackView.frame.size.width - 40, height: urlBackView.frame.height / 7))
        urlPreviewTextField.setTextField(placeholder: "", superView: urlBackView)
        
        let cancelButton = UrlButton(frame: CGRect(x: 0, y: urlBackView.frame.size.height - urlTextField.frame.size.height, width: urlBackView.frame.size.width / 2, height: urlTextField.frame.size.height))
        cancelButton.setUrlUnderButton(title: "キャンセル", action: #selector(self.cancelUrl), superView: urlBackView)
        let postButton = UrlButton(frame: CGRect(x: urlBackView.frame.width/2, y: urlBackView.frame.size.height - urlTextField.frame.size.height, width: urlBackView.frame.size.width / 2, height: urlTextField.frame.size.height))
        postButton.setUrlUnderButton(title: "入力", action: #selector(self.setUrl), superView: urlBackView)
        urlPreviewTextField.isEnabled = false
        
        if (UIPasteboard.general.string != nil && ((UIPasteboard.general.string?.range(of: "http")) != nil)) {
            urlTextField.text = UIPasteboard.general.string
        }
        if !(self.urlTextField.text?.isEmpty)! {
            self.urlPreviewTextField.text = self.urlTextField.text
            self.urlPreviewTextField.textColor = UIColor(red: 0, green: 122/255, blue: 255/255, alpha: 1)
            let previewString = NSAttributedString(string: self.urlTextField.text!, attributes: stringAttributes)
            self.urlPreviewTextField.attributedText = previewString
        }
    }
    
    @objc func previewText() {
        self.urlPreviewTextField.textColor = UIColor(red: 0, green: 122/255, blue: 255/255, alpha: 1)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            if !(self.urlOptionalTextField.text?.isEmpty)! && !(self.urlTextField.text?.isEmpty)! {
                let previewString = NSAttributedString(string: self.urlOptionalTextField.text!, attributes: self.stringAttributes)
                self.urlPreviewTextField.attributedText = previewString
            } else if !(self.urlTextField.text?.isEmpty)! && (self.urlOptionalTextField.text?.isEmpty)! {
                let previewString = NSAttributedString(string: self.urlTextField.text!, attributes: self.stringAttributes)
                self.urlPreviewTextField.attributedText = previewString
            }
        }
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
    
    
    @objc func setUrl() {
        if (urlTextField.text?.isEmpty)! {
            let alert = UIAlertController(title: "URLを入力してください", message: nil, preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(action)
            present(alert, animated: true, completion: nil)
            textView.resignFirstResponder()
            return
        } else {
            guard let range = self.textView.selectedTextRange else {
                return
            }
            self.textView.replace(range, withText: " " + self.urlPreviewTextField.text! + " ")
            self.textView.addAttributes(urlPreviewTextField.text!, values: ["URL": self.urlTextField.text!], attributes: [.underline(UnderlineStyle.single), .underlineColor(UIColor(red: 0, green: 122/255, blue: 255/255, alpha: 1)), .textColor(UIColor(red: 0, green: 122/255, blue: 255/255, alpha: 1))])
        }
        if !(self.urlOptionalTextField.text?.isEmpty)! && !(self.urlTextField.text?.isEmpty)! {
            self.urlText.append((url: self.urlTextField.text!, urlText: self.urlOptionalTextField.text!))
        } else if !(self.urlTextField.text?.isEmpty)! && (self.urlOptionalTextField.text?.isEmpty)! {
            self.urlText.append((url: self.urlTextField.text!, urlText: nil))
        }
        textView.resignFirstResponder()
        postbackView.removeFromSuperview()
    }
    
    // テキストView内のリンクをタップした際にWebに遷移させる
    func regeributedTextView(_ textView: RegeributedTextView, didSelect text: String, values: [String : Any]) {
        self.textView.isScrollEnabled = false
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
        self.nowCursor = oriRangeRight
    }
    
    // 下書き保存 & 自動保存のときに呼び出す
    func convertToHtml(){
        self.attachments = [(range: NSRange, image: UIImage)]()
        let range = NSRange(location: 0, length: textView.attributedText.length)
        self.textView.attributedText.enumerateAttribute(.attachment, in: range, options: [], using: { (value, range, stop) in
            if let attachment = value as? NSTextAttachment {
                if let image = attachment.image {
                    attachments.append((range, image))
                } else if let image = attachment.image(forBounds: attachment.bounds,
                                                       textContainer: nil,
                                                       characterIndex: range.location) {
                    attachments.append((range, image))
                }
            }
        })
        
        if attachments.count > 0 {
            var i = 0
            var j = 1
            let startRange = NSMakeRange(0, attachments[0].range.location)
            
            textToHtml(getRange: startRange)
            (j ..< attachments.count).forEach({ (nil) in
                let nextImageRange = NSMakeRange(attachments[i].range.location + 1, attachments[j].range.location - attachments[i].range.location - 1)
                let imageRange = NSMakeRange(attachments[i].range.location, 1)
                imageToHtml(getRange: imageRange, i: i)
                textToHtml(getRange: nextImageRange)
                
                i += 1
                j += 1
            })
            imageToHtml(getRange: NSMakeRange(attachments[i].range.location, 1), i: i)
            textToHtml(getRange: NSMakeRange(attachments[j-1].range.location + 1, self.textView.text.count - attachments[j-1].range.location - 1))
        } else {
            let oriRange = NSMakeRange(0, self.textView.text.count)
            textToHtml(getRange: oriRange)
        }
        
        sumHtml = self.htmls.joined()
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
        // Font、FontSizeがぶっ壊れてしまうバグを解消
        convertAttributeText = sumHtml.convertHtml(withFont: UIFont(name: "Helvetica", size: 16), align: .left)
    }
    
    // テキストが入力されるたびに何かしたいとき
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let textAsNSString = self.textView.text! as NSString
        // rangeの範囲をtestに置換する
        let replace = textAsNSString.replacingCharacters(in: range, with: text)
        let boldString = replace.range(of: "\n")
        if boldString != nil {
            let boldRange = NSRange(boldString!, in: replace)
            if boldRange.location <= range.location {
                self.textView.typingAttributes = [NSAttributedStringKey.font.rawValue : UIFont.systemFont(ofSize: 16.0)]
            } else {
                self.textView.typingAttributes = [NSAttributedStringKey.font.rawValue : UIFont.boldSystemFont(ofSize: 30)]
                self.titleText = replace
            }
        }
        return true
    }
 
    func textToHtml(getRange: NSRange) {
        let documentAttributes = [NSAttributedString.DocumentAttributeKey.documentType: NSAttributedString.DocumentType.html]
        let attT = textView.attributedText!
        let htmlData = try! attT.data(from: getRange, documentAttributes: documentAttributes)
        let html = String(data: htmlData, encoding: .utf8)
        do {
            let doc = try HTMLDocument(string: html!, encoding: .utf8)
            self.htmls.append((doc.body?.rawXML)!)
        } catch let error {
            print(error)
        }
    }
    
    func imageToHtml(getRange: NSRange, i: Int) {
        let documentAttributes = [NSAttributedString.DocumentAttributeKey.documentType: NSAttributedString.DocumentType.html]
        let attT = textView.attributedText!
        let htmlData = try! attT.data(from: getRange, documentAttributes: documentAttributes)
        // 画像だけのHTML全体を取得
        let html = String(data: htmlData, encoding: .utf8)
        do {
            let doc = try HTMLDocument(string: html!, encoding: .utf8)
            let changeString = "file:///Attachment.png"
           
            self.htmls.append((doc.body?.rawXML.replacingOccurrences(of: changeString, with: "data:image/png;base64,\(self.attachments[i].image.convertImageToBase64())"))!)
        } catch let error {
            print(error)
        }
    }
    
    @objc func cancelUrl() {
        postbackView.removeFromSuperview()
        urlTextField.text = ""
        urlOptionalTextField.text = ""
    }
    
    @objc func textFieldEditingChanged() {
        UserManager.sharedInstance.users = []
    }
    
    func setUpSampleSearchTextField() {
        ViewController.searchField.delegate = self
        ViewController.searchField.addTarget(self, action: #selector(self.textFieldEditingChanged), for: .editingChanged)
        ViewController.searchField.theme.font = UIFont.systemFont(ofSize: 16)
        ViewController.searchField.theme.bgColor = UIColor.white
        ViewController.searchField.theme.separatorColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 0.5)
        ViewController.searchField.theme.cellHeight = 50
        
        let cancelButton = MensionButton(frame: CGRect(x: ViewController.searchField.frame.origin.x, y: ViewController.searchField.frame.origin.y + ViewController.searchField.frame.height, width: ViewController.searchField.frame.size.width/2, height: ViewController.searchField.frame.size.height))
        cancelButton.setMension(title: "キャンセル", action: #selector(self.cancelMension), superView: self.postMensionBackView)
        let postButton = MensionButton(frame: CGRect(x: ViewController.searchField.center.x, y: ViewController.searchField.frame.origin.y + ViewController.searchField.frame.height, width: ViewController.searchField.frame.size.width/2, height: ViewController.searchField.frame.size.height))
        postButton.setMension(title: "入力", action: #selector(self.setMension), superView: self.postMensionBackView)
        // returnキーを押したらの処理
        ViewController.searchField.itemSelectionHandler = { filteredResults, itemPosition in
            let item = filteredResults[itemPosition]
            ViewController.searchField.text = item.title
            cancelButton.alpha = 1
            postButton.alpha = 1
        }
        
        ViewController.searchField.userStoppedTypingHandler = {
            guard let criteria =  ViewController.searchField.text else {
                return
            }
            self.timer?.invalidate()
            if criteria.count > 1 {
                self.timer = Timer.scheduledTimer(timeInterval: 0.8, target: self, selector: #selector(self.search), userInfo: criteria, repeats: false)
                cancelButton.alpha = 0
                postButton.alpha = 0
            } else if criteria.count == 0 {
                cancelButton.alpha = 1
                postButton.alpha = 1
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
                if ViewController.kIsIphoneX {
                    // iPhoneX
                    let y = (titleTextView.frame.height + titleTextView.frame.origin.y) + (self.keyboardFrame.size.height + kToolBar.frame.height)
                    let insertY = (self.view.bounds.height + 10) - y
                    textView.frame = CGRect(x: 0, y: self.titleTextView.frame.origin.y + self.titleTextView.frame.height + 30, width: self.view.frame.width, height: insertY)
                    i += 1
                } else {
                    // iPhoneX以外
                    let y = (titleTextView.frame.height + titleTextView.frame.origin.y) + (self.keyboardFrame.size.height + kToolBar.frame.height)
                    let insertY = (self.view.bounds.height + 38) - y
                    textView.frame = CGRect(x: 0, y: self.titleTextView.frame.origin.y + self.titleTextView.frame.height + 5, width: self.view.frame.width, height: insertY)
                    i += 1
                }
            } else {
                return
            }
            self.textView.placeHolder = "本文を入力"
            self.textView.PlaceHolderColor = UIColor.darkGray
        }
    }
}

