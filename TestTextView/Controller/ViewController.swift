//
//  ViewController.swift
//  TestTextView
//
//  Created by 坂本貴宏 on 2018/03/07.
//  Copyright © 2018年 坂本貴宏. All rights reserved.
//

import UIKit
import Photos
import TLPhotoPicker
import SearchTextField
import RegeributedTextView
import Fuzi
import SystemConfiguration


 class ViewController: UIViewController, RegeributedTextViewDelegate {

    @IBOutlet weak var titleTextView: TitleTextView!
    let kSelectTextInImage = UIView()
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
    var textView: RegeributedTextView!
    // TextView内にある写真、動画をクリックした際に使用する
    var textInSelectImage = UIImage()
    // テキスト内の文字か画像かをカーソルサイズで判断する
    var textSize: CGRect!
    var images = [UIImage]()
    // カメラロールから取得するImage情報
    var selectedAssets = [TLPHAsset]()
    // メンションのアカウント名を配列にぶち込む
    var mensionUserName = [String]()
    // 複数画像アップロードにカーソルを位置を知っておくため
    var nowCursor: NSRange!
    var selectTextRange: UITextRange!
    // 文字列置換するために、リンク挿入のリンクと任意テキストを格納
    var urlText = [(url: String, urlText: String?)]()
    var titleText: String!
    var sumHtml: String!
    private var stringAttributes: [NSAttributedStringKey: Any]!
    // URLを入力する
    private var urlTextField: UrlTextField!
    private var urlOptionalTextField: UrlTextField!
    private var urlPreviewTextField: UrlTextField!
    // ポップアップのバックに表示するView
    private var urlBackView: UIView!
    private var postbackView: BackView!
    private var postMensionBackView: BackView!
    // メンション表示
    private var users: SearchTextFieldItem!
    static var searchField: UserSearchTextField!
    // キーボードのCGRect
    private var keyboardFrame: CGRect!
    private var i = 0
    private var timer: Timer?
    // 分割したTextをHTML化し、格納
    private var htmls = [String]()
    private var attachments = [(range: NSRange, image: UIImage)]()
    private var convertAttributeText: NSAttributedString!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.textView = RegeributedTextView()
        self.addToolBar()
        self.stringAttributes = [.underlineStyle: NSUnderlineStyle.styleSingle.rawValue, .underlineColor: UIColor(red: 0, green: 122/255, blue: 255/255, alpha: 1)]
        self.textView.delegate = self
        self.titleTextView.delegate = self
        self.titleTextView.placeHolder = "タイトルを入力"
        self.titleTextView.PlaceHolderColor = UIColor.darkGray
        self.titleTextView.font = UIFont.systemFont(ofSize: 28)
        self.titleTextView.isScrollEnabled = false
        self.view.addSubview(self.titleTextView)
        self.textView.becomeFirstResponder()
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillBeShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        self.textView.font = UIFont.systemFont(ofSize: 16)
        self.view.addSubview(self.textView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.textView.becomeFirstResponder()
        self.textView.typingAttributes = [NSAttributedStringKey.font.rawValue : UIFont.boldSystemFont(ofSize: 30)]
        self.sumHtml = ""
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func addToolBar() {
        self.kToolBar.barStyle = UIBarStyle.default
        self.kToolBar.isTranslucent = true
        self.kToolBar.tintColor = UIColor(red: 76/255, green: 217/255, blue: 100/255, alpha: 1)
        let cameraButton = UIBarButtonItem(image: UIImage(named: "camera")?.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(self.cameraMode))
        let movieButton = UIBarButtonItem(image: UIImage(named: "video")?.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(self.movieMode))
        let urlButton = UIBarButtonItem(image: UIImage(named: "link")?.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(self.urlMode))
        let spaceHighButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.fixedSpace, target: nil, action: nil)
        spaceHighButton.width = 120
        let mensionButton = UIBarButtonItem(image: UIImage(named: "mention")?.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(self.mensionMode))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.fixedSpace, target: nil, action: nil)
        spaceButton.width = 10
        let previewButton = UIBarButtonItem(image: UIImage(named: "eye")?.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(self.previewMode))
        self.kToolBar.setItems([cameraButton, spaceButton, movieButton, spaceButton, urlButton, spaceButton, mensionButton, spaceButton, spaceHighButton, previewButton], animated: false)
        self.kToolBar.isUserInteractionEnabled = true
        self.kToolBar.sizeToFit()
        self.textView.inputAccessoryView = self.kToolBar
    }
    
    @objc func cameraMode(){
        let tLPhotosPickerViewController = self.setPhotoLibrary(isCameraOrVideoMode: false)
        self.present(tLPhotosPickerViewController, animated: true, completion: nil)
    }
    
    @objc func movieMode(){
        let tLPhotosPickerViewController = self.setPhotoLibrary(isCameraOrVideoMode: true)
        self.present(tLPhotosPickerViewController, animated: true, completion: nil)
    }
    
    @objc func urlMode(){
        if self.postMensionBackView != nil {
            self.postMensionBackView.removeFromSuperview()
        }
        self.makeUrlView()
    }
    
    @objc func mensionMode(){
        if self.postbackView != nil {
            self.postbackView.removeFromSuperview()
        }
        ViewController.searchField = UserSearchTextField(frame: CGRect(x: self.view.frame.origin.x + 20, y: self.view.center.y / 4, width: self.view.frame.width - 40, height: 40))
        ViewController.searchField.setSerarchTextField(action: #selector(self.textFieldEditingChanged))
        self.postMensionBackView = BackView(frame: self.view.frame)
        self.postMensionBackView.setBackView(superView: self.view)
        self.postMensionBackView.addSubview(ViewController.searchField)
        self.setUpSampleSearchTextField()
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
        self.postbackView.setBackView(superView: self.view)
        self.urlBackView = UIView()
        self.urlBackView.frame.size.width = self.view.frame.width
        self.urlBackView.frame.size.height = 240
        self.urlBackView.backgroundColor = UIColor.white
        self.urlBackView.center.y = self.postbackView.center.y - 140
        self.postbackView.addSubview(self.urlBackView)
        self.urlTextField = UrlTextField(frame: CGRect(x: self.urlBackView.frame.origin.x+20, y: self.urlBackView.frame.height / 10, width: self.urlBackView.frame.size.width - 40, height: self.urlBackView.frame.height / 7))
        self.urlTextField.setTextField(placeholder: "http://", superView: self.urlBackView)
        self.urlTextField.addTarget(self, action: #selector(self.previewText), for: UIControlEvents.editingChanged)

        self.urlOptionalTextField = UrlTextField(frame: CGRect(x: self.urlBackView.frame.origin.x+20, y: self.urlBackView.frame.height / 3.5, width: self.urlBackView.frame.size.width - 40, height: self.urlBackView.frame.height / 7))
        self.urlOptionalTextField.setTextField(placeholder: "任意テキスト", superView: self.urlBackView)
        self.urlOptionalTextField.addTarget(self, action: #selector(self.previewText) , for: UIControlEvents.editingChanged)
        
        self.urlPreviewTextField = UrlTextField(frame: CGRect(x: self.urlBackView.frame.origin.x+20, y: self.urlBackView.frame.height/2.1, width: self.urlBackView.frame.size.width - 40, height: self.urlBackView.frame.height / 7))
        self.urlPreviewTextField.setTextField(placeholder: "", superView: self.urlBackView)
        
        let cancelButton = UrlButton(frame: CGRect(x: 0, y: self.urlBackView.frame.size.height - self.urlTextField.frame.size.height, width: self.urlBackView.frame.size.width / 2, height: self.urlTextField.frame.size.height))
        cancelButton.setUrlUnderButton(title: "キャンセル", action: #selector(self.cancelUrl), superView: self.urlBackView)
        let postButton = UrlButton(frame: CGRect(x: urlBackView.frame.width/2, y: self.urlBackView.frame.size.height - self.urlTextField.frame.size.height, width: self.urlBackView.frame.size.width / 2, height: self.urlTextField.frame.size.height))
        postButton.setUrlUnderButton(title: "入力", action: #selector(self.setUrl), superView: self.urlBackView)
        self.urlPreviewTextField.isEnabled = false
        self.urlTextField.pasteString()
        self.urlTextField.previewUrlText(urlPreviewTextField: self.urlPreviewTextField)
    }
    
    @objc func previewText() {
        self.urlOptionalTextField.optionalText(urlTextField: self.urlTextField, urlPreviewTextField: self.urlPreviewTextField)
    }
    
    @objc func setUrl() {
        self.urlTextField.setUrlTextInTextView(textView: self.textView, urlPreviewTextField: self.urlPreviewTextField, viewControlller: self)
        if !(self.urlOptionalTextField.text?.isEmpty)! && !(self.urlTextField.text?.isEmpty)! {
            self.urlText.append((url: self.urlTextField.text!, urlText: self.urlOptionalTextField.text!))
        } else if !(self.urlTextField.text?.isEmpty)! && (self.urlOptionalTextField.text?.isEmpty)! {
            self.urlText.append((url: self.urlTextField.text!, urlText: nil))
        }
        self.textView.resignFirstResponder()
        self.postbackView.removeFromSuperview()
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
    
    // html文字列形成
    func convertToHtml(){
        self.attachments = [(range: NSRange, image: UIImage)]()
        let range = NSRange(location: 0, length: self.textView.attributedText.length)
        self.textView.attributedText.enumerateAttribute(.attachment, in: range, options: [], using: { (value, range, stop) in
            if let attachment = value as? NSTextAttachment {
                if let image = attachment.image {
                    self.attachments.append((range, image))
                } else if let image = attachment.image(forBounds: attachment.bounds,
                                                       textContainer: nil,
                                                       characterIndex: range.location) {
                    self.attachments.append((range, image))
                }
            }
        })
        
        if self.attachments.count > 0 {
            var i = 0
            var j = 1
            let startRange = NSMakeRange(0, self.attachments[0].range.location)
            self.textToHtml(getRange: startRange)
            (j ..< self.attachments.count).forEach({ (nil) in
                let nextImageRange = NSMakeRange(attachments[i].range.location + 1, self.attachments[j].range.location - self.attachments[i].range.location - 1)
                let imageRange = NSMakeRange(self.attachments[i].range.location, 1)
                self.imageToHtml(getRange: imageRange, i: i)
                self.textToHtml(getRange: nextImageRange)
                
                i += 1
                j += 1
            })
            self.imageToHtml(getRange: NSMakeRange(self.attachments[i].range.location, 1), i: i)
            self.textToHtml(getRange: NSMakeRange(self.attachments[i].range.location + 1, self.textView.text.count - self.attachments[i].range.location - 1))
        } else {
            let oriRange = NSMakeRange(0, self.textView.text.count)
            textToHtml(getRange: oriRange)
        }
        
        self.sumHtml = self.htmls.joined()
        self.replaceHtmlString()
        // Font、FontSizeがぶっ壊れてしまうバグを解消
        self.convertAttributeText = self.sumHtml.convertHtml(withFont: UIFont(name: "Helvetica", size: 16), align: .left)
    }
 
    func textToHtml(getRange: NSRange) {
        let documentAttributes = [NSAttributedString.DocumentAttributeKey.documentType: NSAttributedString.DocumentType.html]
        let attT = self.textView.attributedText!
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
        let attT = self.textView.attributedText!
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
        self.postbackView.removeFromSuperview()
        self.urlTextField.text = ""
        self.urlOptionalTextField.text = ""
    }
    
    @objc func textFieldEditingChanged() {
    }
    
    func setUpSampleSearchTextField() {
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
        self.postMensionBackView.removeFromSuperview()
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
                    let y = (self.titleTextView.frame.height + self.titleTextView.frame.origin.y) + (self.keyboardFrame.size.height + self.kToolBar.frame.height)
                    let insertY = (self.view.bounds.height + 10) - y
                    textView.frame = CGRect(x: 0, y: self.titleTextView.frame.origin.y + self.titleTextView.frame.height + 30, width: self.view.frame.width, height: insertY)
                    i += 1
                } else {
                    // iPhoneX以外
                    let y = (self.titleTextView.frame.height + self.titleTextView.frame.origin.y) + (self.keyboardFrame.size.height + self.kToolBar.frame.height)
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

