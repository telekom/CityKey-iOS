/*
Created by Michael on 07.12.18.
Copyright © 2018 Michael. All rights reserved.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    https://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
 
In accordance with Sections 4 and 6 of the License, the following exclusions apply:

    1. Trademarks & Logos – The names, logos, and trademarks of the Licensor are not covered by this License and may not be used without separate permission.
    2. Design Rights – Visual identities, UI/UX designs, and other graphical elements remain the property of their respective owners and are not licensed under the Apache License 2.0.
    3: Non-Coded Copyrights – Documentation, images, videos, and other non-software materials require separate authorization for use, modification, or distribution.

These elements are not considered part of the licensed Work or Derivative Works unless explicitly agreed otherwise. All elements must be altered, removed, or replaced before use or distribution. All rights to these materials are reserved, and Contributor accepts no liability for any infringing use. By using this repository, you agree to indemnify and hold harmless Contributor against any claims, costs, or damages arising from your use of the excluded elements.

SPDX-FileCopyrightText: 2025 Deutsche Telekom AG, Copyright © 2018 Michael
SPDX-License-Identifier: Apache-2.0 AND LicenseRef-Deutsche-Telekom-Brand
License-Filename: LICENSES/Apache-2.0.txt LICENSES/LicenseRef-Deutsche-Telekom-Brand.txt
*/

import UIKit
import WebKit
import Kingfisher

class SCServicesInfoDetailVC: UIViewController {

    @IBOutlet weak var photoCreditLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var closeBtn: UIBarButtonItem!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var accessibilityDetailView: UIView!
    var webviewHeightConstraint: NSLayoutConstraint?
    @IBOutlet weak var separatorView: UIView!
    var imageURL: SCImageURL?
    var navTitle: String = ""
    var details: String?
    var photoCredit: String?
    var tintColor: UIColor = UIColor(named: "CLR_OSCA_BLUE")!
    var beforeDismissCompletion: (() -> Void)?
    var lockedDueAuth: Bool = false
    var lockedDueResidence: Bool = false
    var buttons: [SCComponentDetailBtnAction]?
//    var isHtmlDetail : Bool = false
    var injector: (SCInjecting & SCAdjustTrackingInjection & SCWebContentInjecting)?
    var displayContentType: SCDisplayContentType = .service
    var serviceType: String?
    var serviceFunction: String?
    var webView: WKWebView!
    @IBOutlet weak var scrollView: UIScrollView!
    var itemServiceParams : [String:String]?

    private var activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        return activityIndicator
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.shouldNavBarTransparent = false

        self.photoCreditLabel.adaptFontSize()

        imageView.image = UIImage(named: imageURL!.absoluteUrlString())
        self.navigationItem.title = navTitle
        self.navigationItem.leftBarButtonItem = nil
        self.navigationItem.hidesBackButton = false

        self.photoCreditLabel.text = "  " + (self.photoCredit ?? "")
        self.photoCreditLabel.backgroundColor = self.photoCredit == nil ? UIColor.clear : UIColor(patternImage: UIImage(named: "darken_btm_large")!)

        if details != nil {
            setupWebView(imageReadyDetails: details!)
            self.setupAccessibility()
            updateAccessbiltiyElements(isHidden: true)
        }

        // set buttons
        setupServiceActionButtons()

        // initially stackView will be hidden
        stackView.isHidden = true
        setupActivityIndicator()

        self.setupAccessibilityIDs()
        self.setupAccessibility()
        updateAccessbiltiyElements(isHidden: true)
        handleDynamicTypeChange()
        SCDataUIEvents.registerNotifications(for: self,
                                             on: UIContentSizeCategory.didChangeNotification,
                                             with: #selector(handleDynamicTypeChange))
        scrollView.delaysContentTouches = false
    }

    @objc private func handleDynamicTypeChange() {
        setupServiceActionButtons()
        loadWebView(with: details!)
    }

    private func setupServiceActionButtons() {
        stackView.removeAllArrangedSubviews()

        // set buttons
        if let buttons = self.buttons {
            stackView.spacing = 10

            for action in buttons {
                let button = SCCustomButton(type: .custom)
                button.setTitle(action.title, for: .normal)
                button.titleLabel?.numberOfLines = 0
                button.titleLabel?.textAlignment = .center
                button.titleLabel?.font = UIFont.SystemFont.regular.forTextStyle(style: .body, size: 16, maxSize: 30)

                switch action.btnType {
                case .cityColorFull:
                    button.customizeCityColorStyle()
                case .cityColorLight:
                    button.customizeCityColorStyleLight()
                }

                let serviceButtonHeight = button.titleLabel?.text?.estimatedHeight(withConstrainedWidth: button.frame.width,
                                                                                   font: (button.titleLabel?.font)!) ?? GlobalConstants.kServiceDetailPageButtonHeight

                button.heightAnchor.constraint(greaterThanOrEqualToConstant: serviceButtonHeight <= GlobalConstants.kServiceDetailPageButtonHeight ? GlobalConstants.kServiceDetailPageButtonHeight : serviceButtonHeight).isActive = true
                button.widthAnchor.constraint(equalToConstant: 260.0).isActive = true
                // ServiceFunction = "Termine"
                button.addTargetClosure(closure: { [weak self] (_) in
                    guard let strongSelf = self else {
                        return
                    }
                    strongSelf.trackButtonTappedEvent(serviceType: strongSelf.serviceType,
                                                      serviceActionType: action.modelServiceAction?.actionType)
                    if strongSelf.serviceFunction == "mobility" {
                        strongSelf.navigationToMobilityService(action)
                    } else {
                        action.completion()
                    }
                })
                self.stackView.addArrangedSubview(button)
            }
        }
        self.setupAccessibility()
        updateAccessbiltiyElements(isHidden: true)
    }
    
    private func navigationToMobilityService(_ action: SCComponentDetailBtnAction) {
        guard let url = action.modelServiceAction?.iosUri, let injector = injector else {
            return
        }
        let mobilityVC = injector.getWebContentViewController(for: url,
                                                              title: navTitle,
                                                              insideNavCtrl: false,
                                                              itemServiceParams: itemServiceParams,
                                                              serviceFunction: serviceFunction)
        self.navigationItem.backButtonTitle = "navigation_bar_back".localized()
        self.navigationController?.pushViewController(mobilityVC, animated: true)
    }

    private func trackButtonTappedEvent(serviceType: String?, serviceActionType: String?) {
        var parameters = [String: String]()
        parameters[AnalyticsKeys.TrackedParamKeys.citySelected] = kSelectedCityName
        parameters[AnalyticsKeys.TrackedParamKeys.cityId] = kSelectedCityId
        parameters[AnalyticsKeys.TrackedParamKeys.userStatus] = SCAuth.shared.isUserLoggedIn() ? AnalyticsKeys.TrackedParamKeys.loggedIn : AnalyticsKeys.TrackedParamKeys.notLoggedIn
        parameters[AnalyticsKeys.TrackedParamKeys.serviceType] = serviceType ?? ""
        parameters[AnalyticsKeys.TrackedParamKeys.serviceActionType] = serviceActionType ?? ""
        injector?.trackEvent(eventName: AnalyticsKeys.EventName.webTileButtonTapped,
                            parameters: parameters)
    }

    private func setupWebView(imageReadyDetails: String) {
        webView = WKWebView(frame: .zero, configuration: webViewConfiguration())
        webView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(webView)
        webView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor,
                                         constant: 18.0).isActive = true
        webView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor,
                                          constant: -18.0).isActive = true
        webView.topAnchor.constraint(equalTo: separatorView.bottomAnchor, constant: 8.0).isActive = true
        webView.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 18.0).isActive = true
        webView.bottomAnchor.constraint(equalTo: stackView.topAnchor, constant: -20.0).isActive = true
        webviewHeightConstraint = webView.heightAnchor.constraint(equalToConstant: 53)
        webviewHeightConstraint?.isActive = true
        webView.isMultipleTouchEnabled = false
        webView.navigationDelegate = self
        webView.scrollView.isScrollEnabled = false
        webView.isOpaque = false
        webView.backgroundColor = .clear
        webView.scrollView.isScrollEnabled = false
        webView.scrollView.bounces = false
        webView.scrollView.showsVerticalScrollIndicator = false
        loadWebView(with: imageReadyDetails)
    }

    func webViewConfiguration() -> WKWebViewConfiguration {
        let configuration = WKWebViewConfiguration()
        configuration.userContentController = userContentController()
        return configuration
    }

    private func userContentController() -> WKUserContentController {
        let controller = WKUserContentController()
        controller.addUserScript(viewPortScript())
        controller.addUserScript(appearanceScript())
        return controller
    }

    private func appearanceScript() -> WKUserScript {
        let appearance = SCUtilities.getWebViewAppearanceJS(webViewBackgroundColor: UIColor(named: "CLR_BCKGRND"),
                                                            webViewFontColor: UIColor(named: "CLR_LABEL_TEXT_BLACK"))
        return WKUserScript(source: appearance, injectionTime: .atDocumentEnd, forMainFrameOnly: false)
    }

    private func viewPortScript() -> WKUserScript {
        let viewPortScript = """
            var meta = document.createElement('meta');
            meta.setAttribute('name', 'viewport');
            meta.setAttribute('content', 'width=\(UIScreen.main.bounds.size.width - 36.0)');
            meta.setAttribute('initial-scale', '1.0');
            meta.setAttribute('maximum-scale', '1.0');
            meta.setAttribute('minimum-scale', '1.0');
            document.getElementsByTagName('head')[0].appendChild(meta);
        """
        return WKUserScript(source: viewPortScript, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
    }

    private func loadWebView(with content: String) {
        let fontSize = SCUtilities.fontSize(for: UIApplication.shared.preferredContentSizeCategory)
        let fontSetting = """
        <span style=\"font-family:-apple-system; font-size: \(fontSize);
        color: \(UIColor(named: "CLR_ICON_TINT_BLACK")!.hexString)\"</span>
        """
        webView.loadHTMLString(fontSetting + content, baseURL: nil)

    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.refreshNavigationBarStyle()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: { [weak self] in
            self?.updateAccessbiltiyElements(isHidden: false)
            UIAccessibility.setFocusTo(self?.closeBtn)
        })
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.refreshNavigationBarStyle()
    }

    private func updateAccessbiltiyElements(isHidden: Bool) {
        self.navigationController?.navigationBar.accessibilityElementsHidden = isHidden
        self.view.accessibilityElementsHidden = isHidden
        self.stackView.accessibilityElementsHidden = isHidden
        self.tabBarController?.accessibilityElementsHidden = isHidden
    }

    // setup accessibility ids for automated testing
    private func setupAccessibilityIDs() {
        self.photoCreditLabel.accessibilityIdentifier = "lbl_photo_credit"
        self.imageView.accessibilityIdentifier = "img_symbol"
        self.closeBtn?.accessibilityIdentifier = "btn_close"
        self.navigationController?.navigationBar.accessibilityIdentifier = "nvbr"
        self.navigationItem.titleView?.accessibilityIdentifier = "nvitem_title"
    }

    private func setupAccessibility() {
        self.closeBtn?.accessibilityTraits = .button
        self.closeBtn?.isAccessibilityElement = true
        self.closeBtn?.accessibilityLabel = LocalizationKeys.SCServicesInfoDetailVC.accessibilityBtnClose.localized()
        self.closeBtn?.accessibilityLanguage = SCUtilities.preferredContentLanguage()
        self.photoCreditLabel.accessibilityElementsHidden = true
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }

    func setContent(navTitle: String, details: String?, imageURL: SCImageURL?,
                    photoCredit: String?, contentURL: URL?, tintColor: UIColor?,
                    lockedDueAuth: Bool? = false, lockedDueResidence: Bool? = false,
                    btnActions: [SCComponentDetailBtnAction]? = nil,
                    injector: SCInjecting & SCAdjustTrackingInjection & SCWebContentInjecting,
                    serviceType: String?, function: String? = nil,
                    itemServiceParams : [String:String]?,
                    beforeDismissCompletion: (() -> Void)? = nil) {

        self.navTitle = navTitle
        self.imageURL = imageURL
        self.photoCredit = photoCredit
        self.tintColor = tintColor ??  UIColor(named: "CLR_OSCA_BLUE")!
        self.lockedDueResidence = lockedDueResidence ?? false
        self.lockedDueAuth = lockedDueAuth ?? false
        self.beforeDismissCompletion = beforeDismissCompletion
        self.buttons = btnActions
        self.injector = injector
        self.serviceType = serviceType
        self.itemServiceParams = itemServiceParams
        self.serviceFunction = function

        if details != nil {
            let detailString = details!
            self.details = detailString
        } else {
            self.details = nil
        }
    }

    @objc func showTevisWebView() {
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            loadWebView(with: details!)
        }
    }

    private func setupActivityIndicator() {
        accessibilityDetailView.addSubview(activityIndicator)
        activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0.0).isActive = true
        activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 100.0).isActive = true
        activityIndicator.widthAnchor.constraint(equalToConstant: 30.0).isActive = true
        activityIndicator.heightAnchor.constraint(equalToConstant: 30.0).isActive = true
        webView.bringSubviewToFront(activityIndicator)
        handleActivityIndicator(show: true)
    }

    private func handleActivityIndicator(show: Bool) {
        activityIndicator.isHidden = !show
        if show {
            activityIndicator.startAnimating()
        } else {
            activityIndicator.stopAnimating()
        }
    }
}

extension SCServicesInfoDetailVC: WKNavigationDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction,
                 decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if navigationAction.navigationType == WKNavigationType.linkActivated,
           let url = navigationAction.request.url, UIApplication.shared.canOpenURL(url) {
            SCInternalBrowser.showURL(url, withBrowserType: .safari, title: title)
            decisionHandler(.cancel)
            return
        }
        decisionHandler(.allow)
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        let appearance = SCUtilities.getWebViewAppearanceJS(webViewBackgroundColor: UIColor(named: "CLR_BCKGRND"),
                                                            webViewFontColor: UIColor(named: "CLR_LABEL_TEXT_BLACK"))
        webView.evaluateJavaScript(appearance, completionHandler: nil)
        webView.evaluateJavaScript("document.documentElement.scrollHeight", completionHandler: { (height, _) in
            DispatchQueue.main.async {
                self.webviewHeightConstraint?.constant = height as! CGFloat
                self.stackView.isHidden = false
                self.handleActivityIndicator(show: false)
            }
        })
    }
}
