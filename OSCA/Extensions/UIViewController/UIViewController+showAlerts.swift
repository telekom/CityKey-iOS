/*
Created by Robert Swoboda - Telekom on 25.06.19.
Copyright © 2019 Deutsche Telekom AG - VTI Organization. All rights reserved.

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

SPDX-FileCopyrightText: 2025 Deutsche Telekom AG, Robert Swoboda
SPDX-License-Identifier: Apache-2.0 AND LicenseRef-Deutsche-Telekom-Brand
License-Filename: LICENSES/Apache-2.0.txt LICENSES/LicenseRef-Deutsche-Telekom-Brand.txt
*/

import UIKit

extension UIViewController {
    
    func showUIAlert(with text : String) {
        if !(SCUtilities.topViewController() is UIAlertController) {
            let alert = SCGlobalAlertController(title: "app_name".localized(),
                                          message: text.localized(),
                                          preferredStyle: .alert)
            
            let cancel = UIAlertAction(title: "dialog_button_ok".localized(), style: .cancel, handler: { (action) -> Void in })
            alert.addAction(cancel)
            alert.show()
        }
    }
    
    func showUIAlert(with text : String, cancelTitle : String? = nil, retryTitle : String? = nil, retryHandler : (() -> Void)? = nil, additionalButtonTitle: String? = nil, additionButtonHandler: (() -> Void)? = nil, alertTitle: String? = "app_name".localized()) {
        
        if !(SCUtilities.topViewController() is UIAlertController) {
            let alert = SCGlobalAlertController(title: alertTitle,
                                          message: text.localized(),
                                          preferredStyle: .alert)
            
            if cancelTitle != nil {
                let cancel = UIAlertAction(title: cancelTitle, style: .cancel, handler: { (action) -> Void in })
                alert.addAction(cancel)
            }
            if retryTitle != nil {
                let retry = UIAlertAction(title: retryTitle, style: .default, handler: { (action) -> Void in
                    DispatchQueue.main.async {
                        SCDataUIEvents.postNotification(for: .launchScreenRetry)
                        retryHandler?()
                    }})
                alert.addAction(retry)
                
            }
            
            if additionalButtonTitle != nil {
                let additional = UIAlertAction(title: additionalButtonTitle, style: .default, handler: { (action) -> Void in
                    DispatchQueue.main.async {
                        additionButtonHandler?()
                    }})
                alert.addAction(additional)
                
            }
            
            alert.show()

        }
        
    }

    func showNeedsToLoginAlert(with text : String, cancelCompletion: (() -> Void)? = nil, loginCompletion: (() -> Void)? = nil) {


        let alert = UIAlertController(title: "app_name".localized(),
                                      message: text.localized(),
                                      preferredStyle: .alert)
        
        let cancel = UIAlertAction(title: "dialog_login_required_btn_later".localized(), style: .destructive, handler: { (action) -> Void in
            DispatchQueue.main.async {
                cancelCompletion?()
            }})
        let login = UIAlertAction(title: "dialog_login_required_btn_login".localized(), style: .default, handler: { (action) -> Void in
            DispatchQueue.main.async {
                loginCompletion?()
            }})
        
        alert.addAction(cancel)
        alert.addAction(login)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func showNeedsToChangeCityAlert() {

        let alert = UIAlertController(title: "s_007_detailed_service_dialog_city_restricted_title".localized(),
                                      message: "s_007_detailed_service_dialog_city_restricted_message".localized(),
                                      preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "dialog_button_ok".localized(), style: .default, handler: nil)
        
        alert.addAction(okAction)

        self.present(alert, animated: true, completion: nil)
    }
    
    func showCityNoMoreActiveAlert(_ completion: (() -> Void)? = nil) {

        if !(SCUtilities.topViewController() is UIAlertController) {
            let alert = SCGlobalAlertController(title: "city_not_available_dialog_title".localized(),
                                          message: "city_not_available_dialog_body".localized(),
                                          preferredStyle: .alert)
            
            let okButton = UIAlertAction(title: "city_not_available_dialog_ok_button".localized(), style: .default, handler: { (action) -> Void in
                DispatchQueue.main.async {
                    completion?()
                }})
            alert.addAction(okButton)
            
            alert.show()

        }
    }
    
    
    #if !RELEASE && !STABLE
    // SMARTC-16394 Collect data about logout events
    // SMARTC-18143 iOS : Implement Logging for login/logout functionality
    // SMARTC-16772 iOS: Implement Dialog when user Unexpectedly logouts
    func showLogoutAlert(_ logOutDeviceID: String) {
        if !(SCUtilities.topViewController() is UIAlertController) {
            
            let currentTime = "Time: " + Date.generateCurrentTimeStamp()
            let deviceID = "Device ID: " + logOutDeviceID
            let message = "\n" + currentTime + "\n\n" + deviceID + "\n\n" + "Please take a screenshot of this page and mail it to the development team"
            let alert = SCGlobalAlertController(title: "You have been unexpectedly logged out",
                                          message: message,
                                          preferredStyle: .alert)
            
            let cancel = UIAlertAction(title: "dialog_button_ok".localized(), style: .cancel, handler: { (action) -> Void in
                
            })

            let share = UIAlertAction(title: "Share", style: .default, handler: { (action) -> Void in
                SCFileLogger.shared.presentShareActivity(forTag: .logout)
            })

            alert.addAction(cancel)
            alert.addAction(share)
            alert.show()
            
            UILabel.appearance(whenContainedInInstancesOf:[UIAlertController.self]).numberOfLines = 0

            UILabel.appearance(whenContainedInInstancesOf:[UIAlertController.self]).lineBreakMode = .byWordWrapping

        }
    }
    #endif
}
