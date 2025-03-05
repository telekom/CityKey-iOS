/*
Created by Rutvik Kanbargi on 22/07/20.
Copyright © 2020 Deutsche Telekom AG - VTI Organization. All rights reserved.

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

SPDX-FileCopyrightText: 2025 Deutsche Telekom AG, Rutvik Kanbargi
SPDX-License-Identifier: Apache-2.0 AND LicenseRef-Deutsche-Telekom-Brand
License-Filename: LICENSES/Apache-2.0.txt LICENSES/LicenseRef-Deutsche-Telekom-Brand.txt
*/

import UIKit
import Kingfisher
import WebKit

protocol SCServiceDetailDisplaying: AnyObject, SCDisplaying {
    func showBadge(count: String)
    func push(viewController: UIViewController)
    func present(viewController: UIViewController)
    func showBtnActivityIndicator(_ show: Bool)
    func showStatusBtnActivityIndicator(show: Bool)
}

class SCServiceDetailViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var serviceBadgeDescriptionLabel: UILabel!
    @IBOutlet weak var badgeCountLabel: UILabel!
    @IBOutlet weak var serviceButton: SCCustomButton!
    @IBOutlet weak var iconArrowImageView: UIImageView!
    @IBOutlet weak var serviceBadgeView: UIView!
    @IBOutlet weak var serviceBadgeViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var serviceButtonHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var serviceStatusButtonHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var servicestatusButton: SCCustomButton!
    @IBOutlet weak var serviceActionStackView: UIStackView!
    @IBOutlet weak var containerView: UIView!
    var backButton: UIBarButtonItem?
    var presenter: SCServiceDetailPresenting?
    var webviewHeightConstraint: NSLayoutConstraint?
    @IBOutlet weak var scrollView: UIScrollView!

    private var activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        return activityIndicator
    }()

    private var webView: WKWebView = {
        let configuration = webViewConfiguration()
        let webView = WKWebView(frame: .zero, configuration: webViewConfiguration())
        webView.translatesAutoresizingMaskIntoConstraints = false
        return webView
    }()

    static func webViewConfiguration() -> WKWebViewConfiguration {
        let configuration = WKWebViewConfiguration()
        configuration.userContentController = userContentController()
        return configuration
    }

    static private func userContentController() -> WKUserContentController {
        let controller = WKUserContentController()
        controller.addUserScript(viewPortScript())
        controller.addUserScript(appearanceScript())
        return controller
    }

    static private func appearanceScript() -> WKUserScript {
        let appearance = """
           var style = document.createElement('style');
           style.textContent = '* { background-color: \(UIColor(named: "CLR_WEB_VIEW_BCKGRND")!.hexDecimalString) !important;
           color: \(UIColor(named: "CLR_LABEL_TEXT_BLACK")!.hexDecimalString) !important; }
           a { color: \(kColor_cityColor.hexDecimalString) !important; }';
           document.head.appendChild(style);
           """
        return WKUserScript(source: appearance, injectionTime: .atDocumentEnd, forMainFrameOnly: false)
    }

    static private func viewPortScript() -> WKUserScript {
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

    override func viewDidLoad() {
        super.viewDidLoad()

        setupActivityIndicator()
        setupWebView()
        setupUI()
        presenter?.setDisplay(self)
        presenter?.viewDidLoad()
        handleDynamicTypeChange()

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleDynamicTypeChange),
                                               name: UIContentSizeCategory.didChangeNotification,
                                               object: nil)
        updateAccessbiltiyElements(isHidden: true)
        scrollView.delaysContentTouches = false
    }

    private func setupActivityIndicator() {
        containerView.addSubview(activityIndicator)
        activityIndicator.centerXAnchor.constraint(equalTo: containerView.centerXAnchor, constant: 0.0).isActive = true
        activityIndicator.centerYAnchor.constraint(equalTo: containerView.centerYAnchor, constant: 100.0).isActive = true
        activityIndicator.widthAnchor.constraint(equalToConstant: 30.0).isActive = true
        activityIndicator.heightAnchor.constraint(equalToConstant: 30.0).isActive = true
        self.webView.bringSubviewToFront(self.activityIndicator)
        handleActivityIndicator(show: true)
    }

    private func handleActivityIndicator(show: Bool) {
        activityIndicator.isHidden = !show
        show ? activityIndicator.startAnimating() : activityIndicator.stopAnimating()
    }

    private func setupWebView() {
        scrollView.addSubview(webView)
        webView.navigationDelegate = self
        webView.scrollView.showsVerticalScrollIndicator = false
        webView.scrollView.isScrollEnabled = false
        webView.scrollView.bounces = false
        webView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 21.0).isActive = true
        webView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -21.0).isActive = true
        webView.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 21.0).isActive = true
        webView.bottomAnchor.constraint(equalTo: serviceBadgeView.topAnchor, constant: -15.0).isActive = true
        webviewHeightConstraint = webView.heightAnchor.constraint(equalToConstant: 53)
        webviewHeightConstraint?.isActive = true
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        presenter?.viewDidAppear()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: { [weak self] in
            // Enable View's for accessbility
            self?.updateAccessbiltiyElements(isHidden: false)
            UIAccessibility.setFocusWhenScreenChanged(self?.backButton)
        })
    }

    // enable/disable views accessibility until the viewDidAppear is called
    private func updateAccessbiltiyElements(isHidden: Bool) {
        navigationController?.navigationBar.accessibilityElementsHidden = isHidden
        view.accessibilityElementsHidden = isHidden
        webView.accessibilityElementsHidden = isHidden
        serviceButton.accessibilityElementsHidden = isHidden
        servicestatusButton.accessibilityElementsHidden = isHidden
        tabBarController?.accessibilityElementsHidden = isHidden
    }

    @objc private func handleDynamicTypeChange() {
        // Dynamic font
        backButton?.title = LocalizationKeys.Common.navigationBarBack.localized()
        badgeCountLabel.adjustsFontForContentSizeCategory = true
        badgeCountLabel.font = UIFont.SystemFont.regular.forTextStyle(style: .body, size: 16, maxSize: 30)
        serviceBadgeDescriptionLabel.adjustsFontForContentSizeCategory = true
        serviceBadgeDescriptionLabel.font = UIFont.SystemFont.regular.forTextStyle(style: .body, size: 17, maxSize: 30)
        serviceButton.titleLabel?.adjustsFontForContentSizeCategory = true
        serviceButton.titleLabel?.font = UIFont.SystemFont.regular.forTextStyle(style: .body, size: 16, maxSize: 30)
        serviceButton.titleLabel?.numberOfLines = 0
        let serviceButtonHeight = serviceButton.titleLabel?.text?.estimatedHeight(withConstrainedWidth: serviceButton.frame.width, font: (serviceButton.titleLabel?.font)!) ?? GlobalConstants.kServiceDetailPageButtonHeight
        serviceButtonHeightConstraint.constant = serviceButtonHeight <= GlobalConstants.kServiceDetailPageButtonHeight ? GlobalConstants.kServiceDetailPageButtonHeight : serviceButtonHeight

        servicestatusButton.titleLabel?.adjustsFontForContentSizeCategory = true
        servicestatusButton.titleLabel?.font = UIFont.SystemFont.regular.forTextStyle(style: .body, size: 16, maxSize: 30)
        servicestatusButton.titleLabel?.numberOfLines = 0
        let servicestatusButtonHeight = servicestatusButton.titleLabel?.text?.estimatedHeight(withConstrainedWidth: servicestatusButton.frame.width, font: (servicestatusButton.titleLabel?.font)!) ?? GlobalConstants.kServiceDetailPageButtonHeight
        serviceStatusButtonHeightConstraint.constant = servicestatusButtonHeight <= GlobalConstants.kServiceDetailPageButtonHeight ? GlobalConstants.kServiceDetailPageButtonHeight : servicestatusButtonHeight
    }

    private func setupUI() {
        title = presenter?.getServiceTitle()

        serviceBadgeDescriptionLabel.adaptFontSize()
        badgeCountLabel.adaptFontSize()
        serviceButton.titleLabel?.adaptFontSize()

        serviceBadgeDescriptionLabel.text = presenter?.getBadgeDescriptionText()

        // initailly hide the service badge link
        serviceBadgeView.isHidden = true
        iconArrowImageView.isHidden = true
        badgeCountLabel.isHidden = true
        serviceButton.isHidden = true
        serviceActionStackView.isHidden = true
        badgeCountLabel.backgroundColor = kColor_cityColor
        badgeCountLabel.addCornerRadius(radius: badgeCountLabel.bounds.height / 2)

        serviceBadgeViewBottomConstraint.constant = serviceBadgeDescriptionLabel.text == nil ? 0.0 : 40.0

        self.view.setNeedsUpdateConstraints()

        servicestatusButton.customizeBlueStyleLight()
        servicestatusButton.setTitle(presenter?.getSecondaryButtonText(), for: .normal)

        serviceButton.setTitle(presenter?.getButtonText(), for: .normal)
        serviceButton.customizeCityColorStyle()

        imageView.contentMode = .scaleAspectFill
        imageView.image = UIImage(named: (presenter?.getServiceImage()?.absoluteUrlString())!)

        loadWebView(with: presenter?.getServiceDetails())
        backButton = UIBarButtonItem(title: LocalizationKeys.Common.navigationBarBack.localized(), style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem = backButton
    }

    private func handleActionButtons(isHidden: Bool) {
        serviceActionStackView.isHidden = isHidden
        serviceButton.isHidden = isHidden
        servicestatusButton.isHidden = !(presenter?.isShowServiceStatusButton() ?? false)
        // hide the service badge link when not available
        serviceBadgeView.isHidden = presenter?.getBadgeDescriptionText() == nil
        iconArrowImageView.isHidden = presenter?.getBadgeDescriptionText() == nil
        badgeCountLabel.isHidden = presenter?.getBadgeDescriptionText() == nil
        presenter?.showBadgeCount()
    }
    private func loadWebView(with content: String?) {
        guard let content = content else { return }
        let fontSize = SCUtilities.fontSize(for: UIApplication.shared.preferredContentSizeCategory)
        let fontSetting = "<span style=\"font-family:-apple-system; font-size: \(fontSize); color: \(UIColor(named: "CLR_ICON_TINT_BLACK")!.hexString)\"</span>"
        webView.loadHTMLString(fontSetting + content, baseURL: nil)
    }

    @IBAction func didTapOnServiceButton(_ sender: UIButton) {
        presenter?.displayServicePage()
    }

    @IBAction func didTapOnServiceBadgeDescriptionView(_ sender: UITapGestureRecognizer) {
        presenter?.displayServiceOverviewPage()
    }

    @IBAction func didTapOnServicesStatusButton(_ sender: UIButton) {
        presenter?.displayServiceStatusPage()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            loadWebView(with: presenter?.getServiceDetails())
        }
    }
}

extension SCServiceDetailViewController: SCServiceDetailDisplaying {

    func showBadge(count: String) {
        badgeCountLabel.isHidden = (count == "0" || count == "")
        badgeCountLabel.text = count
    }

    func showBtnActivityIndicator(_ show: Bool) {
        self.serviceButton.btnState = show ? .progress : .normal
    }

    func showStatusBtnActivityIndicator(show: Bool) {
        self.servicestatusButton.btnState = show ? .progress : .normal
    }

    func push(viewController: UIViewController) {
        navigationController?.pushViewController(viewController, animated: true)
    }

    func present(viewController: UIViewController) {
        definesPresentationContext = true
        present(viewController, animated: true, completion: nil)
    }
}

extension SCServiceDetailViewController: SCWasteAddressViewResultDelegate {

    func setWasteCalendar(items: [SCModelWasteCalendarItem], address: SCModelWasteCalendarAddress, wasteReminders: [SCHttpModelWasteReminder]) {
        presenter?.displayWasteCalendarViewController(items: items, address: address, wasteReminders: wasteReminders)
    }
}

extension SCServiceDetailViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if navigationAction.navigationType == WKNavigationType.linkActivated,
           let url = navigationAction.request.url {
            if url.scheme == "mailto" || url.scheme == "tel" {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                SCInternalBrowser.showURL(url, withBrowserType: .safari, title: title)
            }
            decisionHandler(.cancel)
            return
        }
        decisionHandler(.allow)
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        let appearance = """
                   var style = document.createElement('style');
                   style.textContent = '* { background-color: \(UIColor(named: "CLR_WEB_VIEW_BCKGRND")!.hexDecimalString) !important; color: \(UIColor(named: "CLR_LABEL_TEXT_BLACK")!.hexDecimalString) !important; } a { color: \(kColor_cityColor.hexDecimalString) !important; }';
                   document.head.appendChild(style);
           """
        webView.evaluateJavaScript(appearance, completionHandler: nil)
        webView.evaluateJavaScript("document.documentElement.scrollHeight", completionHandler: { (height, _) in
            DispatchQueue.main.async { [weak self] in
                self?.handleActivityIndicator(show: false)
                self?.handleActionButtons(isHidden: false)
                self?.webviewHeightConstraint?.constant = height as! CGFloat
            }
        })
    }
}
