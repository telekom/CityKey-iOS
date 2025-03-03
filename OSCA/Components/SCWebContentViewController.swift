/*
Created by Michael on 19.10.18.
Copyright © 2018 Michael. All rights reserved.

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

SPDX-FileCopyrightText: 2025 Deutsche Telekom AG, Copyright © 2018 Michael
SPDX-License-Identifier: Apache-2.0 AND LicenseRef-Deutsche-Telekom-Brand
License-Filename: LICENSES/Apache-2.0.txt LICENSES/LicenseRef-Deutsche-Telekom-Brand.txt
*/

import UIKit
import WebKit
import MessageUI

class SCWebContentViewController: UIViewController {
    var url: URL?
    var htmlString: String?
    var serviceFuncation: String?
    var itemServiceParams: [String: String]?
    override var title: String? {
        didSet {
            self.navigationController?.navigationBar.topItem?.title = title
        }
    }
    
    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var closeBtn: UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = title
        self.navigationItem.backBarButtonItem?.title = ""
        self.shouldNavBarTransparent = false
        // Do any additional setup after loading the view.
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
        
        if title == "Mobility" {
            navigationItem.rightBarButtonItem = nil
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadWebView), name: UIContentSizeCategory.didChangeNotification, object: nil)
    }
    
    // setup accessibility ids for automated testing
    private func setupAccessibilityIDs(){
        self.closeBtn.accessibilityIdentifier = "btn_close"
    }
    
    private func setupAccessibility(){
        self.closeBtn.accessibilityTraits = .button
        self.closeBtn.accessibilityLabel = "accessibility_btn_close".localized()
        self.closeBtn.accessibilityLanguage = SCUtilities.preferredContentLanguage()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.refreshNavigationBarStyle()
    }

    @IBAction func didPressCloseBtn(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        //webView.frame = createWKWebViewFrame(size: size)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
       super.traitCollectionDidChange(previousTraitCollection)
       reloadWebView()
    }

    @objc func reloadWebView() {

        // Setting a placeholder font since the font is loaded through CSS. The font now relies on the system to scale our custom font after calling `scaledFont`.
        let scaledFont = UIFontMetrics(forTextStyle: .body).scaledFont(for: .preferredFont(forTextStyle: .body), compatibleWith: traitCollection)

        // A quick way to style html without modifying the css stylesheet.
        if let htmlString = self.htmlString {
            loadHTML(withFont: scaledFont, htmlString: htmlString)
        }
    }

    private func loadHTML(withFont font: UIFont, htmlString: String) {
        let fontSetting = "<span style=\"font-size: \(font.pointSize)\"</span>"
        webView.loadHTMLString(fontSetting + htmlString, baseURL: URL(string: "https://\(GlobalConstants.kSOL_Image_Domain)"))
    }

}

extension SCWebContentViewController {
    fileprivate func createWKWebViewFrame(size: CGSize) -> CGRect {
        let navigationHeight: CGFloat = 60
        let toolbarHeight: CGFloat = 44
        let height = size.height - navigationHeight - toolbarHeight
        return CGRect(x: 0, y: 0, width: size.width, height: height)
    }
}

extension SCWebContentViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        // show indicator
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        // dismiss indicator
        
        // if url is not valid {
        //    decisionHandler(.cancel)
        // }
        guard navigationAction.request.isHttpLink else {
            // This is not HTTP link - can be a local file or a mailto
            sendMail(recipient: navigationAction.request.url?.email ?? "citykey-support@telekom.de")
            decisionHandler(.cancel)
            return
        }
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
    
    func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        let user = itemServiceParams?["User"] ?? ""
        let password = itemServiceParams?["Password"] ?? ""
        let credential = URLCredential(user: user,
                                       password: password,
                                       persistence: .forSession)
        completionHandler(.useCredential, credential)
    }
}

extension SCWebContentViewController: WKUIDelegate {
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        if navigationAction.targetFrame == nil {
            webView.load(navigationAction.request)
        }
        return nil
    }
}

extension SCWebContentViewController {

    private func sendMail(recipient: String) {
        if MFMailComposeViewController.canSendMail(){
            let mailComposeViewController = MFMailComposeViewController()
            mailComposeViewController.mailComposeDelegate = self
            mailComposeViewController.setToRecipients([recipient])
            self.present(mailComposeViewController, animated: true, completion: nil)
        }
        else{
            let to = recipient
            let gmailUrl = (URL(string: "googlegmail://co?to=\(to)"), "Gmail")
            let outlookUrl = (URL(string: "ms-outlook://compose?to=\(to)"), "Outlook")
            let sparkUrl = (URL(string: "readdle-spark://compose?recipient=\(to)"), "Spark")
            let yahooMail = (URL(string: "ymail://mail/compose?to=\(to)"), "YahooMail")
            let availableUrls = [gmailUrl, outlookUrl, sparkUrl, yahooMail].filter { (item) -> Bool in
                return item.0 != nil && UIApplication.shared.canOpenURL(item.0!)
            }
            if availableUrls.isEmpty {
                let alert = UIAlertController(title: nil, message: LocalizationKeys.SCVersionInformationViewController.wn005MailAleartText.localized(), preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: LocalizationKeys.SCCitizenSurveyPageViewPresenter.p001ProfileConfirmEmailChangeBtn.localized(), style: UIAlertAction.Style.default, handler: { action in
                    alert.dismiss(animated: true)
                }))
                self.present(alert, animated: true, completion: nil)
            }else {
                self.showEmailOptions(for: availableUrls as! [(url: URL, friendlyName: String)])
            }
            
        }
    }
    
    func showEmailOptions(for items: [(url: URL, friendlyName: String)]) {
        let ac = UIAlertController(title: LocalizationKeys.SCLocationSubTableVC.c003EmailOptionAleartText.localized(), message: nil, preferredStyle: .actionSheet)
        for item in items {
            ac.addAction(UIAlertAction(title: item.friendlyName, style: .default, handler: { (_) in
                UIApplication.shared.open(item.url, options: [:],
                                          completionHandler: nil)
            }))
        }
        ac.addAction(UIAlertAction(title: LocalizationKeys.SCDefectReporterLocationViewController.c001CitiesDialogGpsBtnCancel.localized(),
                                   style: .cancel,
                                   handler: nil))
        present(ac, animated: true)
    }
}

extension SCWebContentViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}
