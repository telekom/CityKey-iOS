//
//  SCDataPrivacyViewController+.swift
//  OSCA
//
//  Created by Bhaskar N S on 07/07/22.
//  Copyright © 2022 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import UIKit
import WebKit

extension SCDataPrivacyViewController: SCDataPrivacyDisplaying {

    func push(_ viewController: UIViewController) {
        self.navigationController?.pushViewController(viewController, animated: true)
    }

    func popViewController() {
        self.navigationController?.popViewController(animated: true)
    }

    func updateVersionInfo(_ text: String) {
        self.appVersionLbl.text = text
    }

    func setupUI(title: String, showCloseBtn: Bool, topText: String, bottomText: String, displayActIndicator: Bool, appVersion: String?) {

        self.navigationItem.title = title
        self.navigationItem.backBarButtonItem?.title = ""

        if displayActIndicator {
            let activityIndicator = UIActivityIndicatorView()
            activityIndicator.frame = CGRect(x: 0.0, y: 0.0, width: self.view.bounds.width, height: self.view.bounds.height)
            activityIndicator.backgroundColor = UIColor(named: "CLR_BCKGRND")
            if #available(iOS 13.0, *) {
                activityIndicator.style = .medium
            } else {
                activityIndicator.style = .gray
            }

            activityIndicator.startAnimating()
            self.view.addSubview(activityIndicator)
            topWebViewContent = topText
            bottomWebViewContent = bottomText
            DispatchQueue.main.async {
//                self.topTextView.attributedText = topText
                self.topWebView.loadWebView(with: topText)
//                self.topTextView.setNeedsLayout()
//                self.topTextView.setNeedsUpdateConstraints()
                self.bottomWebView.loadWebView(with: bottomText)
//                self.bottomTextView.attributedText = bottomText
//                self.bottomTextView.setNeedsLayout()
//                self.bottomTextView.setNeedsUpdateConstraints()
                activityIndicator.stopAnimating()
                activityIndicator.removeFromSuperview()
            }
        } else {
//            self.topTextView.attributedText = topText
            self.topWebView.loadWebView(with: topText)
//            self.topTextView.setNeedsLayout()
//            self.topTextView.setNeedsUpdateConstraints()
            bottomWebView.loadWebView(with: bottomText)
//            self.bottomTextView.attributedText = bottomText
//            self.bottomTextView.setNeedsLayout()
//            self.bottomTextView.setNeedsUpdateConstraints()
        }
        self.showSettingPoup = displayActIndicator ? true : false

        if !showCloseBtn {
            self.navigationItem.rightBarButtonItem = nil
        }

        // when an app version is availbel then we will display it, otherwise just hide id
        if appVersion?.count ?? 0 > 0 {
            self.appVersionLbl.adaptFontSize()
            self.appVersionLbl.text = appVersion
        } else {
            self.appVersionLbl.isHidden = true
            self.appVersionLblHeightConstraint.constant = 0
            self.appVersionLblTopConstraint.constant = 0
            self.topSeparator.isHidden = true
        }

        self.view.setNeedsLayout()
        self.stackView.invalidateIntrinsicContentSize()
    }

    func preventSwipeToDismiss() {
        if #available(iOS 13.0, *) {
            self.isModalInPresentation = true
        }
    }

    func dismiss() {
        self.dismiss(animated: true, completion: nil)
    }
}

extension SCDataPrivacyViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        let appearanceScript = """
                       var style = document.createElement('style');
                       style.textContent = '* { background-color: \(UIColor(named: "CLR_BCKGRND")!.hexString) !important; color: \(UIColor(named: "CLR_LABEL_TEXT_BLACK")!.hexDecimalString) !important; } a { color: \(kColor_cityColor) !important; }';
                       document.head.appendChild(style);
               """
        webView.evaluateJavaScript(appearanceScript, completionHandler: nil)

        if webView == self.topWebView.webView {
            self.topWebView.webView.evaluateJavaScript("document.documentElement.scrollHeight", completionHandler: { (height, _) in
                DispatchQueue.main.async {
                    if self.topWebViewContent.isEmpty {
                        self.topWebviewHeightConstraint?.constant = 0.0
                    } else {
                        self.topWebviewHeightConstraint?.constant = height as! CGFloat
                    }
                }
            })
        }

        if webView == self.bottomWebView.webView {
            self.bottomWebView.webView.evaluateJavaScript("document.documentElement.scrollHeight", completionHandler: { (height, _) in
                DispatchQueue.main.async {
                    if self.bottomWebViewContent.isEmpty {
                        self.bottomWebviewHeightConstraint?.constant = 0.0
                    } else {
                        self.bottomWebviewHeightConstraint?.constant = height as! CGFloat
                    }
                }
            })
        }
        webView.evaluateJavaScript("var node = document.createElement(\"style\"); node.innerHTML = \"body { margin:0; }\";document.body.appendChild(node);", completionHandler: nil)
    }

    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
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
