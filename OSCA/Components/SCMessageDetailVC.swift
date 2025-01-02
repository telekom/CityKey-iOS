//
//  SCMessageDetailVC.swift
//  SmartCity
//
//  Created by Michael on 07.12.18.

//  Copyright © 2018 Michael. All rights reserved.
//

import UIKit
import WebKit

class SCMessageDetailVC: UIViewController {


    @IBOutlet weak var photoCreditLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var teaserLabel: SCTopAlignLabel!
    @IBOutlet weak var subtitleLabel: SCTopAlignLabel!
    @IBOutlet weak var linkBtn: UIButton!
    @IBOutlet weak var shareBtn: UIBarButtonItem!
    @IBOutlet weak var closeBtn: UIBarButtonItem!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var teaserTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var separatorTop: UIView!
    @IBOutlet weak var accessibilityDetailView: UIView!
    @IBOutlet weak var imageViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageViewHeightConstraint1: NSLayoutConstraint!
    @IBOutlet weak var subtitleTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var subtitleHeightConstraint: NSLayoutConstraint!

    @IBOutlet weak var failedImageView: UIView!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var retryButton: UIButton!
    @IBOutlet weak var failedImageViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var webViewContainer: SCWebView!
    @IBOutlet weak var webViewContainerHeightConstaint: NSLayoutConstraint!

    var imageURL : SCImageURL?
    var topBtnTitle : String?
    var bottomBtnTitle : String?
    var navTitle : String = ""
    var mtitle : String = ""
    var teaser : String = ""
    var subtitle : String = ""
    var details : String?
    var contentURL : URL?
    var photoCredit : String?
    var tintColor : UIColor = UIColor(named: "CLR_OSCA_BLUE")!
    var webview : WKWebView?
    var beforeDismissCompletion: (() -> Void)? = nil
    var lockedDueAuth : Bool = false
    var lockedDueResidence : Bool = false
    var buttons : [SCComponentDetailBtnAction]?
    var isHtmlDetail : Bool = false
    var injector: SCInjecting?
    var displayContentType : SCDisplayContentType = .news
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.shouldNavBarTransparent = false
        self.teaserLabel.adaptFontSize()
        self.subtitleLabel.adaptFontSize()
        self.titleLabel.adaptFontSize()
        self.linkBtn.titleLabel?.adaptFontSize()

        self.photoCreditLabel.adaptFontSize()
        
        self.errorLabel.adaptFontSize()
        self.errorLabel.text = "e_005_image_load_error".localized()
        self.retryButton.setTitle(" " + "e_002_page_load_retry".localized(), for: .normal)
        self.retryButton.setTitleColor(kColor_cityColor, for: .normal)
        self.retryButton.titleLabel?.adaptFontSize()
        self.retryButton.setImage(UIImage(named: "action_resend_email")?.maskWithColor(color: kColor_cityColor), for: .normal)
        
        self.launchImage()
        
        if contentURL == nil {
            self.shareBtn = nil
            self.navigationItem.rightBarButtonItem = nil
        }

        self.teaserLabel.text = teaser
        self.titleLabel.text = self.mtitle
        self.navigationItem.title = navTitle
        self.navigationItem.leftBarButtonItem = nil
        self.navigationItem.hidesBackButton = false
        
        // SMARTC-20031 Show subheadline on news detail page if available
        self.subtitleLabel.text = subtitle
        if self.subtitle.isEmpty{
            self.subtitleLabel.isHidden = true
            self.subtitleTopConstraint.constant = 0
            self.subtitleHeightConstraint.constant = 0
        } else {
            self.subtitleLabel.isHidden = false
        }

        if contentURL != nil {
            self.linkBtn.setTitle("h_003_home_articles_btn_more".localized(), for: .normal)
            self.linkBtn.isHidden = false
        } else {
            self.linkBtn.isHidden = true
        }

        self.linkBtn.setTitleColor(self.tintColor, for: .normal)
        self.linkBtn.titleLabel?.attributedText = "h_003_home_articles_btn_more".localized().applyHyphenation()

        // if there is no link and no title the we need to hide the
        // separartor and move up the teaser content
        if self.title?.count ?? 0 == 0 && self.linkBtn.isHidden == true {
            self.separatorTop.isHidden = true
            self.teaserTopConstraint.constant = 18
        }
        
        if self.displayContentType == .service{
            self.teaserLabel.isHidden = true
            self.teaserTopConstraint.constant = 0
            self.imageViewHeightConstraint.constant = 230
            self.imageViewHeightConstraint1.constant = 230
        }

        self.photoCreditLabel.text = "  " + (self.photoCredit ?? "")
        self.photoCreditLabel.backgroundColor = self.photoCredit == nil ? UIColor.clear : UIColor(patternImage: UIImage(named: "darken_btm_large")!)

        if details != nil {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
                self.loadWebView(with: self.details)
            })
            self.setupAccessibility()
        }

        // set buttons
        
        if let buttons = self.buttons {
            stackView.spacing = 10
            
            for action in buttons {
                let button = SCCustomButton(type: .custom)
                button.setTitle(action.title, for: .normal)
                
                switch action.btnType {
                case .cityColorFull:
                    button.customizeCityColorStyle()
                case .cityColorLight:
                    button.customizeCityColorStyleLight()
                }
                
                button.heightAnchor.constraint(equalToConstant: 50.0).isActive = true
                button.widthAnchor.constraint(equalToConstant: 260.0).isActive = true
                //ServiceFunction = "Termine"
                let termine = action.modelServiceAction?.iosUri.contains("termine") ?? false
                if termine {
                    button.addTarget(self, action: #selector(showTevisWebView), for:.touchUpInside)
                } else {
                    button.addTargetClosure(closure: { (button) in action.completion()})
                }
                self.stackView.addArrangedSubview(button)
            }
        }
        self.setupAccessibilityIDs()
        self.setupAccessibility()
        self.handleDynamicTypeChange()

        NotificationCenter.default.addObserver(self, selector: #selector(handleDynamicTypeChange), name: UIContentSizeCategory.didChangeNotification, object: nil)
        
        setupWebView()
    }
    private func setupWebView() {
        webViewContainer.webView.navigationDelegate = self
        webViewContainer.webView.scrollView.contentInsetAdjustmentBehavior = UIScrollView.ContentInsetAdjustmentBehavior.never
    }
    
    private func loadWebView(with content: String?) {
        guard let content = content else { return }
        let fontSize = SCUtilities.fontSize(for: UIApplication.shared.preferredContentSizeCategory)
        let fontSetting = "<span style=\"font-family:-apple-system; font-size: \(fontSize); color: \(UIColor(named: "CLR_ICON_TINT_BLACK")!.hexString)\"</span>"
        webViewContainer.webView.loadHTMLString(fontSetting + content, baseURL: nil)
    }
    
    @objc private func handleDynamicTypeChange() {
        // Dynamic font
        self.navigationItem.title = navTitle
        self.navigationItem.backButtonTitle = "navigation_bar_back".localized()

        self.photoCreditLabel.adjustsFontForContentSizeCategory = true
        self.photoCreditLabel.font = UIFont.SystemFont.bold.forTextStyle(style: .footnote, size: 13, maxSize: 20)
        self.titleLabel.adjustsFontForContentSizeCategory = true
        self.titleLabel.font = UIFont.SystemFont.medium.forTextStyle(style: .footnote, size: 12, maxSize: nil)
        self.teaserLabel.adjustsFontForContentSizeCategory = true
        self.teaserLabel.font = UIFont.SystemFont.bold.forTextStyle(style: .title3, size: 18, maxSize: nil)
        self.subtitleLabel.adjustsFontForContentSizeCategory = true
        self.subtitleLabel.font = UIFont.SystemFont.medium.forTextStyle(style: .subheadline, size: 16, maxSize: nil)
        self.errorLabel.adjustsFontForContentSizeCategory = true
        self.errorLabel.font = UIFont.SystemFont.regular.forTextStyle(style: .footnote, size: 13, maxSize: nil)
        
        self.linkBtn.titleLabel?.adjustsFontForContentSizeCategory = true
        self.linkBtn.titleLabel?.font = UIFont.SystemFont.regular.forTextStyle(style: .body, size: 14, maxSize: (UIScreen.main.bounds.size.width) == 320 ? 25 : 30)
        self.retryButton.titleLabel?.adjustsFontForContentSizeCategory = true
        self.retryButton.titleLabel?.font = UIFont.SystemFont.regular.forTextStyle(style: .body, size: 14, maxSize: 25)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.refreshNavigationBarStyle()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.refreshNavigationBarStyle()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        webViewContainer.webView.scrollView.contentInset = UIEdgeInsets.zero
    }

    // setup accessibility ids for automated testing
    private func setupAccessibilityIDs(){
        self.photoCreditLabel.accessibilityIdentifier = "lbl_photo_credit"
        self.imageView.accessibilityIdentifier = "img_symbol"
        self.titleLabel.accessibilityIdentifier = "lbl_title"
        self.teaserLabel.accessibilityIdentifier = "lbl_teaser"
        self.subtitleLabel.accessibilityIdentifier = "lbl_subtitle"
        self.linkBtn.accessibilityIdentifier = "btn_link"
        self.closeBtn?.accessibilityIdentifier = "btn_close"
        self.retryButton.accessibilityIdentifier = "btn_retry_error"
        self.navigationController?.navigationBar.accessibilityIdentifier = "nvbr"
        self.navigationItem.titleView?.accessibilityIdentifier = "nvitem_title"
    }

    private func setupAccessibility() {
        self.shareBtn?.accessibilityTraits = .button
        self.shareBtn?.accessibilityLabel = "accessibility_btn_share_news".localized()
        self.shareBtn?.accessibilityLanguage = SCUtilities.preferredContentLanguage()
        self.closeBtn?.accessibilityTraits = .button
        self.closeBtn?.accessibilityLabel = "accessibility_btn_close".localized()
        self.closeBtn?.accessibilityLanguage = SCUtilities.preferredContentLanguage()
        self.photoCreditLabel.accessibilityElementsHidden = true
        self.accessibilityDetailView.isAccessibilityElement = true
        
        // SMARTC-20031 Show subheadline on news detail page if available
        let accessibilityText = (self.teaserLabel.attributedText?.string ?? "") + ", " + (self.subtitleLabel.attributedText?.string  ?? "")

        self.accessibilityDetailView.accessibilityLanguage = "de-De"
        
        // if title contains date, the we will localize it for accessibility
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MMM yyyy"
        if let date =  dateFormatter.date(from: self.mtitle){
            let formatter = DateFormatter()
            formatter.dateStyle = .long
            formatter.timeStyle = .none
            self.titleLabel.accessibilityLabel = formatter.string(for: date)
        }
        self.subtitleLabel.accessibilityElementsHidden = true
        teaserLabel.accessibilityTraits = .header
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }

    func setContent(navTitle : String,
                    title : String,
                    teaser : String,
                    subtitle : String,
                    details : String?,
                    imageURL : SCImageURL?,
                    photoCredit : String?,
                    contentURL : URL?,
                    tintColor : UIColor?,
                    lockedDueAuth : Bool? = false,
                    lockedDueResidence : Bool? = false,
                    btnActions: [SCComponentDetailBtnAction]? = nil,
                    injector: SCInjecting,
                    beforeDismissCompletion :  (() -> Void)? = nil){
        
        self.navTitle = navTitle
        self.mtitle = title
        self.teaser = teaser
        self.subtitle = subtitle
        self.imageURL = imageURL
        self.contentURL = contentURL
        self.photoCredit = photoCredit
        self.tintColor = tintColor ??  UIColor(named: "CLR_OSCA_BLUE")!
        self.lockedDueResidence = lockedDueResidence ?? false
        self.lockedDueAuth = lockedDueAuth ?? false
        self.beforeDismissCompletion = beforeDismissCompletion
        self.buttons = btnActions
        self.injector = injector
        
        if contentURL == nil {
            self.shareBtn = nil
        }
        
        
        if details != nil {
            let detailString = details!
            self.details = detailString
        } else {
            self.details = nil
        }
    }
    
    @objc func showWebview() {
        if let contenturl = contentURL, UIApplication.shared.canOpenURL(contenturl){
            SCInternalBrowser.showURL(contenturl)
        }
    }
    
    @objc func showTevisWebView() {
    }
        
    @IBAction func closeBtnWasPressed(_ sender: Any) {
        self.executeCompletion(beforeDismissCompletion)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func shareBtnWasPressed(_ sender: Any) {
        //SCInjector().trackEvent(eventName: "ClickNewsShareBtn")

        if let contenturl = self.contentURL {
            let objectToShare = "\(teaser)\n\(contenturl)\n\n\("share_store_header".localized())\n"
            SCShareContent.share(objects: [objectToShare], emailTitle: teaser, sourceRect: nil)
        }
    }

    @IBAction func linkBtnWasPressed(_ sender: Any) {
        self.showWebview()
//        if let contentUrl = self.contentURL {
//            UIApplication.shared.open(contentUrl)
//        }
    }
    
    private func executeCompletion(_ completion: (() -> Void)? = nil) {
        
        if completion == nil {
            self.showUIAlert(with: "dialog_message_unsupported")
        } else {
            completion?()
        }
    }
    
    func noImageToShow(){
        self.imageView.isHidden = true
        self.imageViewHeightConstraint.constant = 0
        self.imageViewHeightConstraint1.constant = 0
        self.failedImageView.isHidden = true
        self.failedImageViewHeightConstraint.constant = 0
    }
    
    func loadImage(){
        if imageURL == nil || imageURL?.absoluteUrlString() == "" {
            self.noImageToShow()

        } else {
            self.imageView.isHidden = false
            self.failedImageView.isHidden = true
            self.imageView.contentMode = UIDevice.current.orientation.isLandscape ? .scaleAspectFit : .scaleAspectFill

            self.imageView.load(from: imageURL, maxWidth:self.imageView.bounds.size.width) { isImageLoaded in
                if !isImageLoaded{
                    self.imageView.isHidden = true
                    self.failedImageView.isHidden = false
                    self.failedImageViewHeightConstraint.constant = 300
                }else{
                    self.imageView.isHidden = false
                }
            }
        }
    }
    
    func launchImage(){
        self.failedImageView.isHidden = SCUtilities.isInternetAvailable()
        self.loadImage()
    }
    
    @IBAction func retryBtnWasPressed(_ sender: Any) {
        self.retryButtonWasPressed()
    }
    
    func retryButtonWasPressed(){
        if SCUtilities.isInternetAvailable(){
            self.failedImageView.isHidden = false
            self.launchImage()
            
        }else{
            SCUtilities.topViewController().showUIAlert(with: "dialog_retry_description".localized(), cancelTitle: "dialog_button_ok".localized(), retryTitle: "dialog_retry_retry_button".localized(), retryHandler: {self.retryButtonWasPressed()}, additionalButtonTitle: nil, additionButtonHandler: nil)
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: { [weak self] context in
            guard let strongSelf = self else {
                return
            }
            self?.imageView.contentMode = UIDevice.current.orientation.isLandscape ? .scaleAspectFit : .scaleAspectFill
        }, completion: nil)
    }
    
}

extension SCMessageDetailVC: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        let appearance = """
                var style = document.createElement('style');
                style.textContent = '* { background-color:
                \(UIColor(named: "CLR_WEB_VIEW_BCKGRND")!.hexDecimalString) !important;
                color: \(UIColor(named: "CLR_LABEL_TEXT_BLACK")!.hexDecimalString) !important; }';
                document.head.appendChild(style);
                """
        webView.evaluateJavaScript(appearance, completionHandler: nil)
        webView.evaluateJavaScript("document.documentElement.scrollHeight", completionHandler: { (height, _) in
            DispatchQueue.main.async { [weak self] in
                self?.webViewContainerHeightConstaint?.constant = height as! CGFloat
            }
        })
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction,
                 decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if navigationAction.navigationType == WKNavigationType.linkActivated,
           let url = navigationAction.request.url {
            if url.scheme == "mailto" || url.scheme == "tel" {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                if UIApplication.shared.canOpenURL(url) {
                    SCInternalBrowser.showURL(url, withBrowserType: .safari)
                }
            }
            decisionHandler(.cancel)
            return
        }
        decisionHandler(.allow)
    }
}
