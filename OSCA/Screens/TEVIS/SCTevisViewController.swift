//
//  SCTevisViewController.swift
//  OSCA
//
//  Created by Michael on 26.04.20.
//  Copyright © 2020 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

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
