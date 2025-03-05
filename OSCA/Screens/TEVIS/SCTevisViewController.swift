/*
Created by Michael on 26.04.20.
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

SPDX-FileCopyrightText: 2025 Deutsche Telekom AG, Michael
SPDX-License-Identifier: Apache-2.0 AND LicenseRef-Deutsche-Telekom-Brand
License-Filename: LICENSES/Apache-2.0.txt LICENSES/LicenseRef-Deutsche-Telekom-Brand.txt
*/

import UIKit
import WebKit

protocol SCTevisViewDisplaying {
    func askDataPermission()
    func closeWebView()
    func sendAsParameters(request: NSURLRequest)
    func setCallBackUrl(url: NSURL)
}

class SCTevisViewController: UIViewController {

    @IBOutlet weak var webView: WKWebView!
    
    var presenter: SCTevisViewPresenting!
    var userData: SCModelUserData?
    var profile: SCModelProfile?
    var callbackUrl: NSURL!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.presenter.setDisplay(self)
        self.presenter.viewDidLoad()
        webView.navigationDelegate = self
        
        //SMARTC-17088 Client: Appointments : Title missing to the appointment page.
        self.title = LocalizationKeys.SCTevisViewController.appointmentWebViewTitle.localized()
    }
        
    @IBAction func didPressCloseBtn(_ sender: Any) {
        self.showUIAlert(with: LocalizationKeys.SCTevisViewController.appointmentWebCancelDialogMessage.localized(), cancelTitle: LocalizationKeys.SCTevisViewController.appointmentWebCancelDialogBtnCancel.localized(), retryTitle: LocalizationKeys.SCTevisViewController.appointmentWebCancelDialogBtnClose.localized(), retryHandler: { self.presenter.dismissWebView() }, additionalButtonTitle: nil, additionButtonHandler: nil)
    }
    
}

extension SCTevisViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
      decisionHandler(.allow)
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let url = navigationAction.request.url?.absoluteString {
            if url == callbackUrl.absoluteString {
                self.presenter.webProcessFinishedSuccessfully()
            }
        }
        decisionHandler(.allow)
        print(navigationAction)
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        
    }
}

extension SCTevisViewController: WKUIDelegate {
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        if navigationAction.targetFrame == nil {
            webView.load(navigationAction.request)
        }
        return nil
    }
}

extension SCTevisViewController: SCTevisViewDisplaying {
    func askDataPermission() {
        self.showUIAlert(with: LocalizationKeys.SCTevisViewController.appointmentWebPrivateDataPermissionMessage.localized(),
                         cancelTitle: nil,
                         retryTitle: LocalizationKeys.SCTevisViewController.appointmentWebPrivateDataPermissionBtnNegative.localized(),
                         retryHandler: {self.presenter.prepareRequest(useProfileData: false)},
                         additionalButtonTitle: LocalizationKeys.SCTevisViewController.appointmentWebPrivateDataPermissionBtnPositive.localized(),
                         additionButtonHandler: {self.presenter.prepareRequest(useProfileData: true)},alertTitle: LocalizationKeys.SCTevisViewController.appointmentWebPrivateDataPermissionTitle.localized())
    }
    
    
    func closeWebView() {
        self.webView.stopLoading()
        self.dismiss(animated: true, completion: nil)
    }
    
    func sendAsParameters(request: NSURLRequest){
        webView.load(request as URLRequest)
    }
    
    func setCallBackUrl(url: NSURL) {
        self.callbackUrl = url
    }
    
}
