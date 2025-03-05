/*
Created by Bharat Jagtap on 01/05/21.
Copyright © 2021 Deutsche Telekom AG - VTI Organization. All rights reserved.

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

SPDX-FileCopyrightText: 2025 Deutsche Telekom AG, Bharat Jagtap
SPDX-License-Identifier: Apache-2.0 AND LicenseRef-Deutsche-Telekom-Brand
License-Filename: LICENSES/Apache-2.0.txt LICENSES/LicenseRef-Deutsche-Telekom-Brand.txt
*/

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
