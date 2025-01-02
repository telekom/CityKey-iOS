//
//  SCDataPrivacyViewController.swift
//  SmartCity
//
//  Created by Michael on 01.02.20.
//  Copyright © 2020 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import UIKit
import WebKit

class SCDataPrivacyViewController: UIViewController {

    var presenter: SCDataPrivacyPresenting!

    @IBOutlet weak var stackView: UIStackView!

    @IBOutlet weak var topWebView: SCWebView!
    @IBOutlet weak var bottomWebView: SCWebView!

//    @IBOutlet weak var saveBtn: SCCustomButton!
    @IBOutlet weak var settingsBtn: SCCustomButton!

    @IBOutlet weak var topSeparator: UIView!

    @IBOutlet weak var appVersionLblTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var appVersionLblHeightConstraint: NSLayoutConstraint!

    @IBOutlet weak var topWebviewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomWebviewHeightConstraint: NSLayoutConstraint!

    @IBOutlet weak var appVersionLbl: UILabel!

    var showSettingPoup: Bool = false
    var topWebViewContent: String = ""
    var bottomWebViewContent: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupAccessibilityIDs()
        self.shouldNavBarTransparent = false
        self.presenter.setDisplay(self)
        self.presenter.viewDidLoad()

        self.settingsBtn.customizeBlueStyle()
        self.settingsBtn.setTitle(LocalizationKeys.SCDataPrivacy.dialogDpnNoticeSettingsBtn.localized(), for: .normal)

        appVersionLbl.adjustsFontForContentSizeCategory = true
        appVersionLbl.font = UIFont.SystemFont.regular.forTextStyle(style: .subheadline, size: 14, maxSize: (UIScreen.main.bounds.size.width) == 320 ? 20 : 25)
        setupUI()
        SCDataUIEvents.registerNotifications(for: self, on: UIContentSizeCategory.didChangeNotification, with: #selector(handleDynamicTypeChange))

    }

    func setupUI() {
        settingsBtn.titleLabel?.adjustsFontForContentSizeCategory = true
        settingsBtn.titleLabel?.font = UIFont.SystemFont.regular.forTextStyle(style: .body, size: 15, maxSize: 22)
        topWebView.webView.navigationDelegate = self
        bottomWebView.webView.navigationDelegate = self
        topWebView.webView.scrollView.contentInsetAdjustmentBehavior = UIScrollView.ContentInsetAdjustmentBehavior.never
        bottomWebView.webView.scrollView.contentInsetAdjustmentBehavior = UIScrollView.ContentInsetAdjustmentBehavior.never
    }

    @objc private func handleDynamicTypeChange(notification: NSNotification) {
        presenter.prepareAndRefreshUI()
        setupUI()
    }

    // setup accessibility ids for automated testing
    private func setupAccessibilityIDs() {
        self.appVersionLbl.accessibilityIdentifier = "lbl_app_version"
        self.navigationController?.navigationBar.accessibilityIdentifier = "nvbr"
        self.navigationItem.titleView?.accessibilityIdentifier = "nvitem_title"
        self.navigationItem.rightBarButtonItem?.accessibilityIdentifier = "nvitem_btn_right"
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.refreshNavigationBarStyle()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }

    @IBAction func closeBtnWasPressed(_ sender: Any) {
        self.presenter.closeBtnWasPressed()
    }

    @IBAction func settingsButtonPressed(_ sender: Any) {
        presenter.settingsButtonPressed()
    }

    func showPushNotificationOffMessage(messageTitle: String, withMessage: String) {
        let alertController = UIAlertController(title: messageTitle as String, message: withMessage as String, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: LocalizationKeys.SCDataPrivacy.m001MoengageDialogPushBtnCancel.localized(),
                                         style: .cancel) { (_: UIAlertAction!) in

        }
        alertController.addAction(cancelAction)

        let OKAction = UIAlertAction(title: LocalizationKeys.SCDataPrivacy.m001MoengageDialogPushBtnSettings.localized(),
                                     style: .default) { (_: UIAlertAction!) in

            if let url = URL(string: UIApplication.openSettingsURLString) {

                // this would be the path to the privacy settings
                // but it seems like we cant distinguish
                // "app permission disabled" from "location services disabled"
                // let url = URL(string: "App-Prefs:root=Privacy&path=LOCATION") {

                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
        alertController.addAction(OKAction)
        self.present(alertController, animated: true, completion: nil)
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        topWebView.webView.scrollView.contentInset = UIEdgeInsets.zero
        bottomWebView.webView.scrollView.contentInset = UIEdgeInsets.zero
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        presenter.prepareAndRefreshUI()
    }
}
