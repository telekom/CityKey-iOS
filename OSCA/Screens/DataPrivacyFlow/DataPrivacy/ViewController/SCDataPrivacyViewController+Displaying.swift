/*
Created by Bhaskar N S on 07/07/22.
Copyright © 2022 Deutsche Telekom AG - VTI Organization. All rights reserved.

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

SPDX-FileCopyrightText: 2025 Deutsche Telekom AG, Bhaskar N S
SPDX-License-Identifier: Apache-2.0 AND LicenseRef-Deutsche-Telekom-Brand
License-Filename: LICENSES/Apache-2.0.txt LICENSES/LicenseRef-Deutsche-Telekom-Brand.txt
*/

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
