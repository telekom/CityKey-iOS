//
//  SCUserInfoBoxDetailViewController.swift
//  SmartCity
//
//  Created by Michael on 08.12.19.
//  Copyright © 2019 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import UIKit


class SCUserInfoBoxDetailViewController: UIViewController {

    public var presenter: SCUserInfoBoxDetailPresenting!

    @IBOutlet weak var deleteBtn: UIBarButtonItem!
    @IBOutlet weak var categoryImageView: UIImageView!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var infoBoxDateLabel: UILabel!
    @IBOutlet weak var headlineLabel: SCTopAlignLabel!
    @IBOutlet weak var descriptionLabel: SCTopAlignLabel!
    
    @IBOutlet weak var detailLabel: UITextView!
    
    @IBOutlet weak var actIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var actionBtn: SCCustomButton!
    @IBOutlet weak var actionBtnHeightConstraint: NSLayoutConstraint!

    @IBOutlet weak var actionBtnTopConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var attachmentTitlteVIewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var attachmentTitleTopConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var attachmentViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var attachmentViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var linksTitleLabel: UILabel!
    
    private var attachmentTableVC : SCUserInfoBoxAttachmentTVC!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.shouldNavBarTransparent = false
        detailLabel.delegate = self
        
        self.adaptFontSizes()
        
        self.presenter.setDisplay(self)
        self.presenter.viewDidLoad()
        self.setupAccessibilityIDs()
        self.setupAccessibility()
        handleDynamicType()
        registerForNotifications()
    }
    
    private func registerForNotifications() {
        SCDataUIEvents.registerNotifications(for: self, on: UIContentSizeCategory.didChangeNotification, with: #selector(handleDynamicType))
    }
    
    @objc private func handleDynamicType() {
        deleteBtn.setTitleTextAttributes([NSAttributedString.Key.font: UIFont.SystemFont.regular.forTextStyle(style: .body, size: 13, maxSize: nil),
                                          NSAttributedString.Key.foregroundColor: kColor_cityColor],
                                         for: .normal)
        
        categoryLabel.adjustsFontForContentSizeCategory = true
        categoryLabel.font = UIFont.SystemFont.medium.forTextStyle(style: .body, size: 12, maxSize: nil)
        
        infoBoxDateLabel.adjustsFontForContentSizeCategory = true
        infoBoxDateLabel.font = UIFont.SystemFont.medium.forTextStyle(style: .body, size: 13, maxSize: 26)
        
        headlineLabel.adjustsFontForContentSizeCategory = true
        headlineLabel.font = UIFont.SystemFont.bold.forTextStyle(style: .body, size: 15, maxSize: nil)
        
        descriptionLabel.adjustsFontForContentSizeCategory = true
        descriptionLabel.font = UIFont.SystemFont.regular.forTextStyle(style: .body, size: 14, maxSize: nil)
        
        detailLabel.adjustsFontForContentSizeCategory = true
        let htmlAttributedString = NSMutableAttributedString(attributedString: detailLabel.attributedText)
        htmlAttributedString.replaceFont(with: UIFont.SystemFont.medium.forTextStyle(style: .body, size: (UIScreen.main.bounds.size.width) == 320 ? 14.0 : 16.0, maxSize: nil),
                                         color: UIColor(named: "CLR_LABEL_TEXT_BLACK")!)
        self.detailLabel.attributedText = htmlAttributedString
        
        actionBtn.titleLabel?.adjustsFontForContentSizeCategory = true
        actionBtn.titleLabel?.font = UIFont.SystemFont.regular.forTextStyle(style: .body, size: 18, maxSize: 32)
        linksTitleLabel.adjustsFontForContentSizeCategory = true
        linksTitleLabel.font = UIFont.SystemFont.bold.forTextStyle(style: .body, size: 15.0, maxSize: 24.0)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.presenter.viewDidLoad()
        self.refreshNavigationBarStyle()
    }

    
    // setup accessibility ids for automated testing
    private func setupAccessibilityIDs(){
        self.navigationController?.navigationBar.accessibilityIdentifier = "nvbr"
        self.navigationItem.titleView?.accessibilityIdentifier = "nvitem_title"
    }
    
    private func setupAccessibility(){
        self.deleteBtn.accessibilityTraits = .button
        self.deleteBtn.accessibilityLabel = "accessibility_btn_delete".localized()
        self.deleteBtn.accessibilityLanguage = SCUtilities.preferredContentLanguage()
        headlineLabel.accessibilityTraits = .header
    }

    private func adaptFontSizes() {
        self.actionBtn.titleLabel?.adaptFontSize()
        self.infoBoxDateLabel.adaptFontSize()
        self.descriptionLabel.adaptFontSize()
        self.headlineLabel.adaptFontSize()
        self.categoryLabel.adaptFontSize()
        //self.detailLabel.adaptFontSize()

    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        switch segue.destination {
            
        case let attachmentTableVC as SCUserInfoBoxAttachmentTVC:
            self.attachmentTableVC = attachmentTableVC
            self.attachmentTableVC.delegate = self
            
        default:
            break
        }
    }

     @IBAction func deleteBtnWasPressed(_ sender: Any) {
        self.presenter.deleteButtonWasPressed()
    }

    @IBAction func actionBtnWasPressed(_ sender: Any) {
        self.presenter.actionButtonWasPressed()
    }
}

// MARK: - SCUserInfoBoxDetailViewController
extension SCUserInfoBoxDetailViewController: SCUserInfoBoxDetailDisplaying {
    
    func setupUI(userInfoId : Int,
                 messageId: Int,
                 description: String,
                 details: String,
                 headline: String,
                 creationDate: Date,
                 category: String,
                 icon: String,
                 btnTitle: String?,
                 attachments : [SCUserInfoBoxAttachmentItem]) {
        self.navigationItem.title = title
        self.deleteBtn.title = "b_003_infobox_detailed_btn_delete".localized()
        self.deleteBtn.tintColor = kColor_cityColor
        self.deleteBtn.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: kColor_cityColor], for: .normal)
        
        if btnTitle != nil {
            self.actionBtn.customizeCityColorStyle()
            self.actionBtn.isHidden = false
            self.actionBtn.setTitle(btnTitle, for: .normal)
        } else {
            self.actionBtn.isHidden = true
            self.actionBtnTopConstraint.constant = 0.0
            self.actionBtnHeightConstraint.constant = 0.0
        }

        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd"
        self.infoBoxDateLabel.text =  formatter.string(from: creationDate)
        self.descriptionLabel.text = description
        self.headlineLabel.text = headline
        self.categoryLabel.text = category
        self.categoryImageView.load(from: SCImageURL(urlString: icon, persistence: false))
        
        if attachments.count == 0 {
            self.attachmentTitlteVIewHeightConstraint.constant = 0.0
            self.attachmentTitlteVIewHeightConstraint.constant = 0.0
            self.attachmentViewTopConstraint.constant = 0.0
            self.attachmentViewHeightConstraint.constant = 0.0
        } else {
            self.attachmentTableVC.refreshWithAttachments(attachments)
            self.attachmentViewHeightConstraint.constant = self.attachmentTableVC.estimatedTableHeight()
        }
        
         detailLabel.layoutManager.hyphenationFactor = 1.0
         self.detailLabel.attributedText = NSAttributedString(string: "")
         self.detailLabel.linkTextAttributes = [NSAttributedString.Key.foregroundColor: kColor_cityColor]

        DispatchQueue.main.async {
            let imageReadyDetails = "<head><style type=\"text/css\"> img{max-width: \(self.detailLabel.frame.size.width - 10.0) !important; width: auto; height: auto;} </style> </head><body> \(details) </body>"
            
            if let attrString =  imageReadyDetails.htmlAttributedString {
                let htmlAttributedString = NSMutableAttributedString(attributedString: attrString)
                htmlAttributedString.replaceFont(with: UIFont.SystemFont.medium.forTextStyle(style: .body,
                                                                                             size: (UIScreen.main.bounds.size.width) == 320 ? 14.0 : 16.0,
                                                                                             maxSize: nil),
                                                 color: UIColor(named: "CLR_LABEL_TEXT_BLACK")!)
                self.detailLabel.attributedText = htmlAttributedString
                self.detailLabel.linkTextAttributes = [NSAttributedString.Key.foregroundColor: kColor_cityColor]
            }
            self.detailLabel.setNeedsLayout()
            self.detailLabel.setNeedsUpdateConstraints()
            self.actIndicator.stopAnimating()
        }
    }
    
    
    func dismiss(completion: (() -> Void)?) {
        self.navigationController?.popViewController(animated: true)
        completion?()
    }
    
    func push(viewController: UIViewController) {
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    
}

extension SCUserInfoBoxDetailViewController : SCUserInfoBoxAttachmentTVCDelegate {
    func didSelectAttachment(name: String) {
        self.presenter.attachmentWasSelected(name : name)
    }
}

extension SCUserInfoBoxDetailViewController: UITextViewDelegate {

    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        if UIApplication.shared.canOpenURL(URL) {
            SCInternalBrowser.showURL(URL, withBrowserType: .safari, title: title)
            return false
        }

        return true
    }
}
