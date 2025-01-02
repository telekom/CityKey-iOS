//
//  SCEditEMailFinishedVC.swift
//  SmartCity
//
//  Created by Michael on 29.03.19.
//  Copyright © 2019 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import UIKit

class SCEditEMailFinishedVC: UIViewController {

    public var presenter: SCEditEMailFinishedPresenting!

    @IBOutlet weak var notificationLabel: UILabel!
    @IBOutlet weak var notificationView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var resentLabel: UILabel!
    @IBOutlet weak var resentBtn: SCCustomButton!
    @IBOutlet weak var titleTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var finishBtn: SCCustomButton!
    @IBOutlet weak var closeBtn: UIBarButtonItem!

    
    @IBOutlet weak var successImageTopConstraint: NSLayoutConstraint!
    
    private var titleText : String = ""
    private var eMail : String = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupAccessibilityIDs()
        self.setupAccessibility()
        self.presenter.setDisplay(self)
        self.presenter.viewDidLoad()
   }
    
    // setup accessibility ids for automated testing
    private func setupAccessibilityIDs(){
        self.closeBtn.accessibilityIdentifier = "btn_close"
        self.notificationLabel.accessibilityIdentifier = "lbl_notification"
        self.titleLabel.accessibilityIdentifier = "lbl_title"
        self.detailLabel.accessibilityIdentifier = "lbl_detail"
        self.resentBtn.accessibilityIdentifier = "btn_resent"
        self.resentLabel.accessibilityIdentifier = "lbl_resent"
        self.finishBtn.accessibilityIdentifier = "btn_finish"
        self.navigationController?.navigationBar.accessibilityIdentifier = "nvbr"
        self.navigationItem.titleView?.accessibilityIdentifier = "nvitem_title"
    }
    
    private func setupAccessibility(){
        self.closeBtn.accessibilityTraits = .button
        self.closeBtn.accessibilityLabel = "accessibility_btn_close".localized()
        self.closeBtn.accessibilityLanguage = SCUtilities.preferredContentLanguage()
        
        // Dynamic font
        titleLabel.font = UIFont.SystemFont.regular.forTextStyle(style: .title3, size: 20, maxSize: nil)
        detailLabel.font = UIFont.SystemFont.regular.forTextStyle(style: .footnote, size: 14, maxSize: nil)
        resentLabel.font = UIFont.SystemFont.regular.forTextStyle(style: .footnote, size: 14, maxSize: nil)
    }
    
    @IBAction func resentBtnWasPressed(_ sender: Any) {
        self.presenter.retryWasPresssed()
    }
    
    @IBAction func finishBtnWasPressed(_ sender: Any) {
        self.presenter.finishWasPressed()
       
    }
    
    @IBAction func closeBtnWasPressed(_ sender: Any) {
        self.presenter.closeButtonWasPressed()
    }
    
}

extension SCEditEMailFinishedVC: SCEditEMailFinishedDisplaying {
    
    func setupNavigationBar(title: String){
        self.navigationItem.title = title
        // remove the Back button
        self.navigationItem.hidesBackButton = true
    }
    
    func setupUI(email : String){
        var titletext: String = "p_004_profile_email_changed_info_sent_mail".localized()
        titletext = titletext.replacingOccurrences(of: "%s", with: email)

        self.notificationLabel.adaptFontSize()
        self.notificationLabel.text = "p_004_profile_email_changed_info_sent_link".localized()
        self.titleLabel.adaptFontSize()
        let attributedString = NSMutableAttributedString(string: titletext)
        _ = attributedString.setAsBoldFont(textToFind: email, fontSize: self.titleLabel.font.pointSize)
        
        self.titleLabel.attributedText = attributedString
        self.detailLabel.adaptFontSize()
        self.detailLabel.text = "p_004_profile_email_changed_info_received".localized()
        self.resentLabel.adaptFontSize()
        self.resentLabel.text = "p_004_profile_email_changed_info_not_received".localized()
        self.resentBtn.setTitle(" " + "p_004_profile_email_changed_btn_resend".localized(), for: .normal)
        self.resentBtn.titleLabel?.adaptFontSize()
        self.resentBtn.titleLabel?.adaptFontSize()
        self.resentBtn.setImage(UIImage(named: "action_resend_email")?.maskWithColor(color: UIColor(named: "CLR_OSCA_BLUE")!), for: .normal)
        
        self.finishBtn.customizeBlueStyle()
        self.finishBtn.setTitle("p_001_profile_confirm_email_change_btn".localized(), for: .normal)
        self.finishBtn.titleLabel?.adaptFontSize()
        
        self.notificationView.isHidden = true
        
        self.successImageTopConstraint.constant = 40.0
        self.titleTopConstraint.constant = 140.0
        
        
        // remove the Back button
        self.view.setNeedsLayout()
        // Do any additional setup after loading the view.

        self.titleText = titletext
        self.eMail = email

    }

    func dismissView(completion: (() -> Void)? = nil) {
        self.dismiss(animated: true, completion: completion)
    }

    func popViewController() {
        self.navigationController?.popViewController(animated: true)
    }

    func displayResendFinished(){
        self.notificationView.isHidden = false
        self.successImageTopConstraint.constant = 70.0
        self.titleTopConstraint.constant = 170.0
        self.view.setNeedsLayout()
    }
    
    func dismiss(completion: (() -> Void)?) {
        self.dismiss(animated: true, completion: completion)
    }

}


