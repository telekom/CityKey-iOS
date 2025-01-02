//
//  SCWebBrowserPresenter.swift
//  OSCA
//
//  Created by Bharat Jagtap on 17/12/21.
//  Copyright © 2021 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import Foundation
import WebKit

class SCWebBrowserPresenter : SCAusweisAuthWebPresenting {

    private var display: SCAusweisAuthWebViewDisplay!
    private var url : URL!
    
    init(url : URL) {
        self.url = url
    }
    
    func viewDidLoad() {
        display.loadURL(url: self.url)
    }
    
    func viewWillAppear() {
        
    }
    
    func viewDidAppear() {
        
    }
    
    func viewWillDisappear() {
        
    }

    func didStartLoadingURL(url : URL){
        display.showWebLoadingIndicator()
    }
    
    func didLoadURL(url : URL) {
        display.hideWebLoadingIndicator()
    }
    
    func didTerminateURLLoadRequest(url : URL?) {
        display.hideWebLoadingIndicator()
    }
    
    func shouldNavigateInWebView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction) -> Bool {
        return true
    }
    
    func handleCloseButtonPress() {
        display.popViewController(animated: true)
    }
    
    func setDisplay(display : SCAusweisAuthWebViewDisplay) {
        self.display = display
    }
    
    
}
