/*
Created by Bhaskar N S on 08/03/24.
Copyright © 2024 Deutsche Telekom AG - VTI Organization. All rights reserved.

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

import WebKit

class SCWebView: UIView {

    var webView: WKWebView!

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
        let appearance = """
                   var style = document.createElement('style');
                   style.textContent = '* { background-color: \(UIColor(named: "CLR_BCKGRND")!.hexDecimalString) !important; color: \(UIColor(named: "CLR_LABEL_TEXT_BLACK")!.hexDecimalString) !important; } a { color: \(kColor_cityColor.hexDecimalString) !important; }';
                   document.head.appendChild(style);
           """
        return WKUserScript(source: appearance, injectionTime: .atDocumentEnd, forMainFrameOnly: false)
    }

    private func viewPortScript() -> WKUserScript {
        let viewPortScript = """
            var meta = document.createElement('meta');
            meta.setAttribute('name', 'viewport');
            meta.setAttribute('content', 'width=\(UIScreen.main.bounds.width - 36.0)');
            meta.setAttribute('initial-scale', '1.0');
            meta.setAttribute('maximum-scale', '1.0');
            meta.setAttribute('minimum-scale', '1.0');
            document.getElementsByTagName('head')[0].appendChild(meta);
        """
        return WKUserScript(source: viewPortScript, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupWebView()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupWebView()
    }

    private func setupWebView() {
        webView = WKWebView(frame: bounds, configuration: webViewConfiguration())
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.scrollView.showsHorizontalScrollIndicator = false
        addSubview(webView)
        webView.navigationDelegate = self
        webView.topAnchor.constraint(equalTo: topAnchor, constant: 0).isActive = true
        webView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0).isActive = true
        webView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0).isActive = true
        webView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0).isActive = true
    }

    // MARK: - Public Methods
    func loadWebView(with content: String?) {
        guard let content = content else { return }
        let fontSize = SCUtilities.fontSize(for: UIApplication.shared.preferredContentSizeCategory)
        let fontSetting = "<span style=\"font-family:-apple-system; font-size: \(fontSize); color: \(UIColor(named: "CLR_ICON_TINT_BLACK")!.hexString)\"</span>"
        webView.loadHTMLString(fontSetting + content, baseURL: nil)
    }

    func loadURL(_ url: URL) {
        let request = URLRequest(url: url)
        webView.load(request)
    }
}

extension SCWebView: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        let appearance = """
                       var style = document.createElement('style');
                       style.textContent = '* { background-color: \(UIColor(named: "CLR_BCKGRND")!.hexDecimalString) !important; color: \(UIColor(named: "CLR_LABEL_TEXT_BLACK")!.hexDecimalString) !important; } a { color: \(kColor_cityColor.hexDecimalString) !important; }';
                       document.head.appendChild(style);
               """
        webView.evaluateJavaScript(appearance, completionHandler: nil)
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
