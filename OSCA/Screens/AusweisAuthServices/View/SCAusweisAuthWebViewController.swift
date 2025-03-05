/*
Created by Bharat Jagtap on 22/02/21.
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

protocol SCAusweisAuthWebViewDisplay {
    
    func loadURL(url : URL);
    func present(viewController : UIViewController);
    func showError(error : Error);
    func popViewController(animated : Bool );
    func showWebLoadingIndicator()
    func hideWebLoadingIndicator()
    func setNavigationTitle(title : String)
}
/**
 SCAusweisAuthWebViewController takes care of loading the eGov service URL in the containing WebView . It works with SCAusweisAuthWebViewPresenter to track the tcTokenURL and accordingly trigger the AusweisAuth Workflow.
 */
class SCAusweisAuthWebViewController: UIViewController {

    var presenter : SCAusweisAuthWebPresenting!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var closeButton : UIBarButtonItem!
    
    /// WebView Toolbar buttons
    @IBOutlet weak var goBackButton : UIBarButtonItem!
    @IBOutlet weak var goForwardButton : UIBarButtonItem!
    @IBOutlet weak var reloadButton : UIBarButtonItem!
    @IBOutlet weak var launchExternalButton : UIBarButtonItem!
    @IBOutlet weak var webViewToolbar: UIToolbar!
    var webViews: [WKWebView] = [WKWebView]()
    private weak var navigationGestureHolder : UIGestureRecognizerDelegate?
    

    override func viewDidLoad() {
        super.viewDidLoad()
        setupAccessibility()

        presenter.setDisplay(display: self)
        setupWebView()
        self.navigationItem.hidesBackButton = true
        self.presenter.viewDidLoad()

        self.closeButton.title = "cs_004_button_done".localized()       

    }
    
    fileprivate func setupWebView() {
        let webView = WKWebView(frame: view.frame,
                                configuration: WKWebViewConfiguration())
        webView.uiDelegate = self
        webView.navigationDelegate = self
        view.addSubview(webView)
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0).isActive = true
        webView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0).isActive = true
        webView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0).isActive = true
        webView.bottomAnchor.constraint(equalTo: webViewToolbar.topAnchor, constant: 0).isActive = true
        webView.navigationDelegate = self
        webView.uiDelegate = self
        webViews.append(webView)
    }

    func setupAccessibility() {
        
        self.closeButton.accessibilityTraits = .button
        self.closeButton.accessibilityLabel = "cs_004_button_done".localized()

        self.goBackButton.accessibilityTraits = .button
        self.goBackButton.accessibilityLabel = "egov_web_toolbar_goback_button_accessibility_title".localized()

        self.goForwardButton.accessibilityTraits = .button
        self.goForwardButton.accessibilityLabel = "egov_web_toolbar_goforward_button_accessibility_title".localized()

        self.reloadButton.accessibilityTraits = .button
        self.reloadButton.accessibilityLabel = "egov_web_toolbar_reload_button_accessibility_title".localized()

        self.launchExternalButton.accessibilityTraits = .button
        self.launchExternalButton.accessibilityLabel = "egov_web_toolbar_launchExternal_button_accessibility_title".localized()
        

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        presenter.viewDidAppear()
        updateWebToolBarState()
        navigationGestureHolder =
            self.navigationController?.interactivePopGestureRecognizer?.delegate
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.interactivePopGestureRecognizer?.delegate = navigationGestureHolder
    }
    
    // MARK: Navbar & Web Toolbar Actions
    
    @IBAction func didPressCloseButton(_ sender: Any) {
        
//        let alert = UIAlertController(title: "egovs_003_close_dialog_title".localized(), message: "egovs_003_close_dialog_description".localized(), preferredStyle: .alert)
//        alert.addAction(UIAlertAction(title: "egovs_003_close_dialog_cancel_btn".localized(), style: .default, handler: nil))
//        alert.addAction(UIAlertAction(title: "egovs_003_close_dialog_close_btn".localized(), style: .default, handler: { [weak self] (action) in
//            self?.presenter.handleCloseButtonPress()
//        }))
//
//        present(viewController: alert)
        
        self.presenter.handleCloseButtonPress()
    }
    
    
    @IBAction func didPressGoBackButton(_ sender: Any) {
        hideWebLoadingIndicator()
        if webViews.last?.canGoBack == true {
            self.webViews.last?.goBack()
        } else if webViews.count > 1 {
            // remove webview only when we have more than one webview
            self.webViews.last?.removeFromSuperview()
            self.webViews.removeLast()
        }
    }
    
    @IBAction func didPressGoForwardButton(_ sender: Any) {
        self.webViews.last?.goForward()
    }
    
    @IBAction func didPressReloadButton(_ sender: Any) {
        self.webViews.last?.reload()
    }
    
    @IBAction func didPressLuanchExternalButton(_ sender: Any) {

        
        if let url = webViews.last?.url {
            UIApplication.shared.open(url, options: [:] , completionHandler: nil)
        }
    }
    
    func updateWebToolBarState() {
        
        self.goBackButton.isEnabled = webViews.count > 1 ? true : self.webViews.last?.canGoBack ?? false
        self.goForwardButton.isEnabled = self.webViews.last?.canGoForward ?? false
    }
}

// MARK: WkWebView Delegate
extension SCAusweisAuthWebViewController : WKNavigationDelegate {
    
    func webView(_ webView: WKWebView,
          decidePolicyFor navigationAction: WKNavigationAction,
          decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {

        let shouldContinue = presenter.shouldNavigateInWebView(webView, decidePolicyFor: navigationAction)
        decisionHandler( shouldContinue ? .allow : .cancel)
    }
    
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
    
        if let url = webView.url {
            debugPrint("WebView Did Start Provisional Navigation : \(url)")
            presenter.didStartLoadingURL(url: url)
        }
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        
        if let url = webView.url {
            debugPrint("WebView Did Finish : \(url)")
            presenter.didLoadURL(url : url)
        }
        
        updateWebToolBarState()
        
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        debugPrint("WebView Did Fail : \(String(describing: webView.url))")
        presenter.didTerminateURLLoadRequest(url : webView.url)
        updateWebToolBarState()
    }
    
    func webViewWebContentProcessDidTerminate(_ webView: WKWebView) {
        debugPrint("WebView Did Terminate : \(String(describing: webView.url))")
        presenter.didTerminateURLLoadRequest(url: webView.url)
        updateWebToolBarState()
    }
    
}

// MARK: SCAusweisAuthWebViewDisplay

extension SCAusweisAuthWebViewController : SCAusweisAuthWebViewDisplay {
    
    
    func loadURL(url : URL) {
        webViews.last?.load(URLRequest(url: url))
    }
    
    func present(viewController : UIViewController) {
        
        present(viewController, animated: true, completion: nil)
    }
    
    func showError(error : Error) {
            
    }
    
    func popViewController(animated : Bool ){
        
        self.navigationController?.popViewController(animated: animated)
    }
    
    func showWebLoadingIndicator() {
        view.bringSubviewToFront(activityIndicator)
        self.activityIndicator.startAnimating()
    }
    
    func hideWebLoadingIndicator() {
        
        self.activityIndicator.stopAnimating()
    }
    
    func setNavigationTitle(title : String) {
        
        self.navigationItem.title = title
    }
}

// MARK: WKUI Delegate
extension SCAusweisAuthWebViewController : WKUIDelegate {
    
    func webView(_ webView: WKWebView,
                 createWebViewWith configuration: WKWebViewConfiguration,
                 for navigationAction: WKNavigationAction,
                 windowFeatures: WKWindowFeatures) -> WKWebView? {
        if navigationAction.targetFrame == nil {
            let nextWebView = WKWebView(frame: webView.frame, configuration: configuration)
            nextWebView.uiDelegate = self
            nextWebView.navigationDelegate = self
            webViews.append(nextWebView)
            view.addSubview(nextWebView)
            nextWebView.translatesAutoresizingMaskIntoConstraints = false
            nextWebView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0).isActive = true
            nextWebView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0).isActive = true
            nextWebView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0).isActive = true
            nextWebView.bottomAnchor.constraint(equalTo: webViewToolbar.topAnchor, constant: 0).isActive = true
            return nextWebView
        }
        return nil
    }
}

extension SCAusweisAuthWebViewController : UIGestureRecognizerDelegate {
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if webViews.last?.canGoBack ?? false {
            webViews.last?.goBack()
        }
        return false
    }
}
