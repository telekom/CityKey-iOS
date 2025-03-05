/*
Created by Bharat Jagtap on 23/02/21.
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

import Foundation
import WebKit

protocol SCAusweisAuthWebPresenting : SCPresenting {
    
    func viewWillDisappear()
    func didStartLoadingURL(url : URL)
    func didLoadURL(url : URL)
    func didTerminateURLLoadRequest(url : URL?)
    func shouldNavigateInWebView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction) -> Bool
    func handleCloseButtonPress()
    func setDisplay(display : SCAusweisAuthWebViewDisplay)

}


class SCAusweisAuthWebPresenter   {

    private var display: SCAusweisAuthWebViewDisplay!
    private let cityContentSharedWorker: SCCityContentSharedWorking
    private let injector: SCAusweisAuthServiceInjecting
    private let serviceWebDetails : SCModelEgovServiceWebDetails
    
    var isNFCAvailable: Bool {
        if NSClassFromString("NFCNDEFReaderSession") == nil { return false }
        return (NSClassFromString("NFCNDEFReaderSession")?.value(forKey: "readingAvailable") as? Bool ) ?? false
    }

    init(cityContentSharedWorker : SCCityContentSharedWorking , injector : SCAusweisAuthServiceInjecting , serviceWebDetails : SCModelEgovServiceWebDetails ) {
        
        self.cityContentSharedWorker = cityContentSharedWorker
        self.injector = injector
        self.serviceWebDetails = serviceWebDetails
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.ausweisAuthWorkFlowDidFinishWithSuccess), name: Notification.Name.ausweisSDKServiceWorkflowDidFinishWithSuccess, object: nil)
    }
    
    deinit {
        
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func ausweisAuthWorkFlowDidFinishWithSuccess(_ notification : Notification) {
     
        guard let urlString = notification.object as? String else { return }
        if let url = URL(string: urlString) {
            debugPrint("display.loadURL: \(url.absoluteString)")
            display.loadURL(url: url)
        } else {
            
        }
                
    }
    
}

extension SCAusweisAuthWebPresenter : SCAusweisAuthWebPresenting {

    func viewDidLoad() {
        
        // BHARAT TODO : remove dependency on this intialise call
        if isNFCAvailable {
            SCAusweisAppSDKService.initialiseSDK()
        }
        
        /*
        guard let btnAction = serviceData.itemBtnActions?.first else {
            return
        }
        
        guard let modelServiceAction = btnAction.modelServiceAction else {
            return
        }
        
        
        // BHARAT CHECK
        display.setNavigationTitle(title: serviceData.itemTitle )
        display.loadURL(url: URL(string: modelServiceAction.iosUri)!)
        debugPrint("AusweisAuth Start URL : \(modelServiceAction.iosUri)")
        */
        display.setNavigationTitle(title: serviceWebDetails.serviceTitle)
        
        if let url = URL(string: serviceWebDetails.serviceURL) {
            display.loadURL(url: url )
        } else {
            
        }
        
    }
    
    func viewWillAppear() {
        
        
    }
    
    func viewDidAppear() {
        
        
    }
    
    func viewWillDisappear() {
        
        
    }
    
    func didStartLoadingURL(url: URL) {
        display.showWebLoadingIndicator()
        debugPrint("AusweisWebView : didStartLoadingURL : \(url) ")
    }
    
    func didLoadURL(url : URL) {
        display.hideWebLoadingIndicator()
        debugPrint("AusweisWebView : didLoadURL : \(url) ")
    }
    
    func didTerminateURLLoadRequest(url : URL?) {
        display.hideWebLoadingIndicator()
        debugPrint("AusweisWebView : didLoadURL : \(String(describing: url)) ")

    }

    func shouldNavigateInWebView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction) -> Bool {
        
        if let url = navigationAction.request.url {
            
            if let result = self.validURLwithToken(url: url){
                display.hideWebLoadingIndicator()

                if !isNFCAvailable {
                    
                    let alert = UIAlertController(title: "egov_nfc_not_avaiable_title".localized(), message: "egov_nfc_not_available_description".localized(), preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
                    self.display.present(viewController: alert)
                    
                } else {
                    
                    let viewController = self.injector.getAusweisAuthWorkFlowViewController(tcTokenURL : result, cityContentSharedWorker: self.cityContentSharedWorker, injector: self.injector)
                    self.display.present(viewController : viewController.navigationController!)
                }
                return false
            }
        }        
        return true
    }
    
    func handleCloseButtonPress() {
        
        let alert = UIAlertController(title: "egovs_003_close_dialog_title".localized(), message: "egovs_003_close_dialog_description".localized(), preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "egovs_003_close_dialog_cancel_btn".localized(), style: .default, handler: nil))
        alert.addAction(UIAlertAction(title: "egovs_003_close_dialog_close_btn".localized(), style: .default, handler: { [weak self] (action) in
            self?.display.popViewController(animated: true)
        }))

        display.present(viewController: alert)
    }
    
    func setDisplay(display : SCAusweisAuthWebViewDisplay) {
        
        self.display = display
    }
    
    func validURLwithToken(url: URL) -> String? {
        
        if url.absoluteString.contains("tcTokenURL") {

            let urlComps = url.absoluteString.components(separatedBy: "tcTokenURL=")
            var ausweisAuthURL = urlComps.last ?? ""
            if ausweisAuthURL.contains("servicekonto") {
                ausweisAuthURL = ausweisAuthURL.decodeUrl() ?? ""
            } else {
                ausweisAuthURL = ausweisAuthURL.encodeUrl() ?? ""
            }
            debugPrint("Ausweis Auth URL for SDK : \(ausweisAuthURL)")
            return ausweisAuthURL
        }
        return nil
    }
    
    
}

