/*
Created by Harshada Deshmukh on 18/05/21.
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

SPDX-FileCopyrightText: 2025 Deutsche Telekom AG, Harshada Deshmukh
SPDX-License-Identifier: Apache-2.0 AND LicenseRef-Deutsche-Telekom-Brand
License-Filename: LICENSES/Apache-2.0.txt LICENSES/LicenseRef-Deutsche-Telekom-Brand.txt
*/

import UIKit
import WebKit

class SCDefectReportTermsViewController: UIViewController {
    var url: URL?
    var htmlString: String?
    override var title: String? {
        didSet {
            self.navigationController?.navigationBar.topItem?.title = title
        }
    }
    
    @IBOutlet weak var webView: WKWebView!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = title
        self.navigationItem.backBarButtonItem?.title = ""
        self.shouldNavBarTransparent = false
        webView.navigationDelegate = self
        webView.uiDelegate = self
        
        self.setupAccessibilityIDs()
        self.setupAccessibility()
        
        if let url = self.url {
            let request = URLRequest(url: url)
            webView.load(request)
        } else {
            if let htmlString = self.htmlString {
                webView.loadHTMLString(htmlString, baseURL: URL(string: "https://\(GlobalConstants.kSOL_Image_Domain)"))
            }
            
        }
        
    }
    
    // setup accessibility ids for automated testing
    private func setupAccessibilityIDs(){
        self.navigationController?.navigationBar.accessibilityIdentifier = "nvbr"
        self.navigationItem.titleView?.accessibilityIdentifier = "nvitem_title"
        
    }
    
    private func setupAccessibility(){
        self.navigationItem.backButtonTitle?.accessibilityTraits = .button
        self.navigationItem.backButtonTitle?.accessibilityLabel = LocalizationKeys.Common.navigationBarBack.localized()
        self.navigationItem.backButtonTitle?.accessibilityLanguage = SCUtilities.preferredContentLanguage()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.refreshNavigationBarStyle()
    }

    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        //webView.frame = createWKWebViewFrame(size: size)
    }
    
}

extension SCDefectReportTermsViewController {
    fileprivate func createWKWebViewFrame(size: CGSize) -> CGRect {
        let navigationHeight: CGFloat = 60
        let toolbarHeight: CGFloat = 44
        let height = size.height - navigationHeight - toolbarHeight
        return CGRect(x: 0, y: 0, width: size.width, height: height)
    }
}

extension SCDefectReportTermsViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        // show indicator
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        // dismiss indicator
        
        // if url is not valid {
        //    decisionHandler(.cancel)
        // }
        decisionHandler(.allow)
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        // dismiss indicator
        
        //goBackButton.isEnabled = webView.canGoBack
        //goForwardButton.isEnabled = webView.canGoForward
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        // show error dialog
    }
}

extension SCDefectReportTermsViewController: WKUIDelegate {
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        if navigationAction.targetFrame == nil {
            webView.load(navigationAction.request)
        }
        return nil
    }
}
