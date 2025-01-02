//
//  SCTextInWebViewController.swift
//  OSCA
//
//  Created by Bhaskar N S on 12/03/24.
//  Copyright © 2024 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import UIKit
import WebKit
import MessageUI

class SCTextInWebViewController: UIViewController {

    @IBOutlet weak var webContainer: SCWebView!
    var content: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupWebView()
        SCDataUIEvents.registerNotifications(for: self,
                                             on: UIContentSizeCategory.didChangeNotification,
                                             with: #selector(handleDynamicTypeChange))
    }

    private func setupWebView() {
        webContainer.webView.navigationDelegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        webContainer.loadWebView(with: content)
    }

    @objc private func handleDynamicTypeChange() {
        reloadWebView()
    }

    private func reloadWebView() {
        webContainer.loadWebView(with: content)
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        reloadWebView()
    }

    private func stripOutAppleWebData(requestURL: URL) -> URL {
        if requestURL.scheme == "applewebdata" {
            let requestURLString = requestURL.absoluteString
            let trimmedRequestURLString = (requestURLString as NSString).replacingOccurrences(of: "^(?:applewebdata://[0-9A-Z-]*/?)",
                                                                                              with: "", options: .regularExpression,
                                                                                              range: NSRange(location: 0, length: requestURLString.count))

            if trimmedRequestURLString.count > 0 {
                return URL(string: trimmedRequestURLString) ?? requestURL
            }
        }
        return requestURL
    }

    private func sendMail(recipient: String) {
        if MFMailComposeViewController.canSendMail() {
            let mailComposeViewController = MFMailComposeViewController()
            mailComposeViewController.mailComposeDelegate = self
            mailComposeViewController.setToRecipients([recipient])
            self.present(mailComposeViewController, animated: true, completion: nil)
        } else {
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
                alert.addAction(UIAlertAction(title: LocalizationKeys.SCCitizenSurveyPageViewPresenter.p001ProfileConfirmEmailChangeBtn.localized(), style: UIAlertAction.Style.default, handler: { _ in
                    alert.dismiss(animated: true)
                }))
                self.present(alert, animated: true, completion: nil)
            } else {
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

extension SCTextInWebViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}

extension SCTextInWebViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        let appearance = """
                       var style = document.createElement('style');
                       style.textContent = '* { background-color: \(UIColor(named: "CLR_BCKGRND")!.hexDecimalString) !important;
                       color: \(UIColor(named: "CLR_LABEL_TEXT_BLACK")!.hexDecimalString) !important; } a { color: \(kColor_cityColor.hexDecimalString) !important; }';
                       document.head.appendChild(style);
               """
        let customCss = """
        var style = document.createElement('style');
        style.textContent = '* { width: 99%; overflow-x: hidden; -webkit-hyphens: auto; hyphens: auto; }';
        document.head.appendChild(style);
        """
        webView.evaluateJavaScript(customCss, completionHandler: nil)
        webView.evaluateJavaScript(appearance, completionHandler: nil)
    }

    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if navigationAction.navigationType == WKNavigationType.linkActivated,
           let url = navigationAction.request.url {
            if url.scheme == "mailto" || url.scheme == "tel" {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                let url = stripOutAppleWebData(requestURL: url)
                if let email = url.email {
                    sendMail(recipient: email)
                } else if UIApplication.shared.canOpenURL(url) {
                    SCInternalBrowser.showURL(url, withBrowserType: .safari, title: title)
                }
            }
            decisionHandler(.cancel)
            return
        }
        decisionHandler(.allow)
    }
}
