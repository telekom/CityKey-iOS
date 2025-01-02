//
//  SCServicesMoreInfoViewController.swift
//  OSCA
//
//  Created by A118572539 on 16/12/21.
//  Copyright © 2021 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import UIKit
import WebKit

protocol SCServicesMoreInfoViewDisplay: AnyObject, SCDisplaying {
    func setNavigationTitle(_ title: String)
    func loadHTMLContent(_ content: String)
}

class SCServicesMoreInfoViewController: UIViewController {

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var webViewContainer: SCWebView!
    var presenter: SCServicesMoreInfoViewPresenting!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.presenter.setDisplay(self)
        navigationItem.backBarButtonItem?.accessibilityLabel = LocalizationKeys.Common.navigationBarBack.localized()
        self.activityIndicator.startAnimating()
        self.webViewContainer.webView.navigationDelegate = self
        self.presenter.viewDidLoad()
        setupNotifications()
    }

    private func setupNotifications() {
        SCDataUIEvents.registerNotifications(for: self, on: UIContentSizeCategory.didChangeNotification,
                                             with: #selector(handleDynamicTypeChange))
    }

    @objc private func handleDynamicTypeChange() {
        reloadWebView()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        reloadWebView()
    }

    private func reloadWebView() {
        presenter.reloadWebView()
    }
}

extension SCServicesMoreInfoViewController: SCServicesMoreInfoViewDisplay {

    func setNavigationTitle(_ title: String) {
        self.navigationItem.title = title
    }

    func loadHTMLContent(_ content: String) {
        self.activityIndicator.stopAnimating()
        webViewContainer.loadWebView(with: content)
    }
}

extension SCServicesMoreInfoViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        let webViewColor = UIColor(named: "CLR_WEB_VIEW_BCKGRND") ?? UIColor.white
        let webViewFontColor = UIColor(named: "CLR_LABEL_TEXT_BLACK") ?? UIColor.black
        let appearance = """
               var style = document.createElement('style');
               style.textContent = '* { background-color: \(webViewColor.hexDecimalString)
               !important; color: \(webViewFontColor.hexDecimalString) !important; }
               a { color: \(kColor_cityColor.hexDecimalString) !important; }';
               document.head.appendChild(style);
               """
        webView.evaluateJavaScript(appearance, completionHandler: nil)
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
