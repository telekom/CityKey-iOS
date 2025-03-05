/*
Created by Michael on 18.06.19.
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

SPDX-FileCopyrightText: 2025 Deutsche Telekom AG, Michael
SPDX-License-Identifier: Apache-2.0 AND LicenseRef-Deutsche-Telekom-Brand
License-Filename: LICENSES/Apache-2.0.txt LICENSES/LicenseRef-Deutsche-Telekom-Brand.txt
*/

import UIKit

protocol SCRegistrationConfirmEMailFinishedDisplaying: AnyObject, SCDisplaying {
    func setupNavigationBar(title: String)
    func setupUI(titleText: String, detailText: String, btnText: String, topImageSymbol: UIImage)
    func dismissView(completion: (() -> Void)?)
    func popViewController()
    func hideTopImage()
}

protocol SCRegistrationConfirmEMailFinishedPresenting: SCPresenting {
    func setDisplay(_ display: SCRegistrationConfirmEMailFinishedDisplaying)
    func finishedWasPressed()
}

class SCRegistrationConfirmEMailFinishedPresenter {
    weak private var display : SCRegistrationConfirmEMailFinishedDisplaying?
    
    private let injector: SCToolsShowing & SCAdjustTrackingInjection
    private let completionOnSuccess: (() -> Void)?
    private let shouldHideTopImage : Bool
    private let presentationType : SCRegistrationConfirmEMailType

    init(injector: SCToolsShowing & SCAdjustTrackingInjection,
         shouldHideTopImage: Bool,
         presentationType: SCRegistrationConfirmEMailType,
         completionOnSuccess: (() -> Void)?) {
        
        self.injector = injector
        self.completionOnSuccess = completionOnSuccess
        self.shouldHideTopImage = shouldHideTopImage
        self.presentationType = presentationType
    }
    
    deinit {
        
    }
    
    private func setupUI() {
        
        switch presentationType {
        case .confirmMailForPWDReset:
            self.display?.setupNavigationBar(title: "f_001_forgot_password_btn_reset_password".localized())
            self.display?.setupUI(titleText:"f_003_forgot_password_confirm_success_headline".localized(), detailText: "f_003_forgot_password_confirm_success_details".localized(), btnText: "f_003_forgot_password_confirm_success_login_btn".localized(),topImageSymbol: UIImage(named: "icon_reset_password")!)
        case .confirmMailSentBeforeRegistration, .confirmMailForRegistration:

            self.display?.setupNavigationBar(title: "r_005_registration_success_title".localized())
            self.display?.setupUI(titleText:"r_005_registration_success_headline".localized(), detailText: "r_005_registration_success_details".localized(), btnText: "r_005_registration_success_login_btn".localized(),topImageSymbol: UIImage(named: "icon_confirm_email")!)
            
        case .confirmMailForEditEmail:
            self.display?.setupNavigationBar(title: "p_004_profile_email_success_title".localized())
            self.display?.setupUI(titleText:"p_004_profile_email_changed_info_sent_mail".localized(), detailText: "p_004_profile_email_changed_info_received".localized(), btnText: "r_005_registration_success_login_btn".localized(),topImageSymbol: UIImage(named: "icon_confirm_email")!)

        }

        if self.shouldHideTopImage {
            self.hideTopImage()
        }
    }
    
    private func hideTopImage(){
        self.display?.hideTopImage()
    }


}

extension SCRegistrationConfirmEMailFinishedPresenter: SCPresenting {
    
    func viewDidLoad() {
        self.setupUI()
    }
}

extension SCRegistrationConfirmEMailFinishedPresenter: SCRegistrationConfirmEMailFinishedPresenting {
    func setDisplay(_ display: SCRegistrationConfirmEMailFinishedDisplaying) {
        self.display = display
    }
        
    func finishedWasPressed(){
        //MARK: Add "RegistrationComplete" event
        
        if let registration = SCUserDefaultsHelper.getRegistration() {
            var parameters = [String:String]()
            parameters[AnalyticsKeys.TrackedParamKeys.citySelected] = kSelectedCityName
            parameters[AnalyticsKeys.TrackedParamKeys.cityId] = kSelectedCityId
//            parameters[AnalyticsKeys.TrackedParamKeys.userStatus] = AnalyticsKeys.TrackedParamKeys.notLoggedIn
            parameters[AnalyticsKeys.TrackedParamKeys.userZipcode] = registration.postalCode
            if let userYob = registration.birthdate {
                parameters[AnalyticsKeys.TrackedParamKeys.userYob] = userYob.extractYear()
            }
            self.injector.trackEvent(eventName: AnalyticsKeys.EventName.registrationComplete, parameters: parameters)
        }

        completionOnSuccess?()
    }
}
