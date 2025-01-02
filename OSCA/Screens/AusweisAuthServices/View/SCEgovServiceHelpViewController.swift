//
//  SCEgovServiceHelpViewController.swift
//  OSCA
//
//  Created by Bharat Jagtap on 01/05/21.
//  Copyright © 2021 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import UIKit
import WebKit

protocol SCEgovServiceHelpViewDisplay: AnyObject, SCDisplaying {
    func setNavigationTitle(_ title: String)
    func loadHTMLContent(_ content: String)
}

class SCEgovServiceHelpViewController: UIViewController {

    var presenter: SCEgovServiceHelpPresenting!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var webContainer: SCWebView!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.presenter.setDisplay(self)

        webContainer.webView.navigationDelegate = self
        self.navigationItem.backBarButtonItem?.accessibilityLabel = "navigation_bar_back".localized()
        self.loadingIndicator.startAnimating()
        self.presenter.viewDidLoad()
        SCDataUIEvents.registerNotifications(for: self, on: UIContentSizeCategory.didChangeNotification, with: #selector(handleDynamicTypeChange))
    }

    @objc private func handleDynamicTypeChange() {
        presenter.reloadHelpHTMLContent()
    }

    private func loadWebView(with content: String?) {
        webContainer.loadWebView(with: content)
    }
}

extension SCEgovServiceHelpViewController: SCEgovServiceHelpViewDisplay {

    func setNavigationTitle(_ title: String) {

        self.navigationItem.title = title
    }

    func loadHTMLContent(_ content: String) {
        loadWebView(with: content)
        self.loadingIndicator.stopAnimating()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        presenter.reloadHelpHTMLContent()
    }
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: nil) { [weak self] _ in
            self?.presenter.reloadHelpHTMLContent()
        }
    }
}

extension SCEgovServiceHelpViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        let appearanceScript = """
                   var style = document.createElement('style');
                   style.textContent = '* { background-color: \(UIColor(named: "CLR_BCKGRND")!.hexDecimalString) !important; color: \(UIColor(named: "CLR_LABEL_TEXT_BLACK")!.hexDecimalString) !important; } a { color: \(kColor_cityColor.hexDecimalString) !important; }';
                   document.head.appendChild(style);
           """
        let customCss = """
        var style = document.createElement('style');
        style.textContent = '* { width: 99%; overflow-x: hidden; -webkit-hyphens: auto; hyphens: auto; }';
        document.head.appendChild(style);
        """
        webView.evaluateJavaScript(customCss, completionHandler: nil)
        webView.evaluateJavaScript(appearanceScript, completionHandler: nil)
    }

    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if navigationAction.navigationType == WKNavigationType.linkActivated,
           let url = navigationAction.request.url {
            if url.scheme == "mailto" || url.scheme == "tel" {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                if UIApplication.shared.canOpenURL(url) {
                    SCInternalBrowser.showURL(url, withBrowserType: .safari, title: title)
                }
            }
            decisionHandler(.cancel)
            return
        }
        decisionHandler(.allow)
    }
}
