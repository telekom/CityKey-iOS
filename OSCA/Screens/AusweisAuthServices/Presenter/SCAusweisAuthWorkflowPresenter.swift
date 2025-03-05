/*
Created by Bharat Jagtap on 24/02/21.
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
import UIKit

protocol SCAusweisAuthWorkflowPresenting : SCPresenting, AnyObject {
    
    func setDisplay(display : SCAusweisAuthWorkFlowDisplay)
    func handleWorkflowCloseButton()
    
    func showAusweisLoading()
    
    func showAusweisOverview()
    
    func showAusweisInsertCardView()
    
    func showAusweisEnterPIN()
    
    func showAusweisNeedCAN()
    func showAusweisEnterCAN()
        
    func showAusweisNeedPUK()
    func showAusweisEnterPUK()
    
    func showAusweisSuccess()
    func showAusweisError(_ errorType: AusweisErrorType)
    
    func showAusweisServiceDetailInfo()
    func showAusweisEnterPINHelpView()
    
    func showAusweisCardBlockedView()
    
    func finishWithSuccess(url : String)
}

enum AusweisErrorType : String {
    case payloadError = "payloadError"
    case majorError = "majorError"
    case accessRightsError = "accessRightsError"
    case badStateError = "badStateError"
    case messageError = "messageError"
}

class SCAusweisAuthWorkflowPresenter : SCAusweisAuthWorkflowPresenting  {
    
    weak var display : SCAusweisAuthWorkFlowDisplay!
    private var worker : SCAusweisAuthWorking
    private let cityContentSharedWorker: SCCityContentSharedWorking
    private let injector: SCAusweisAuthServiceInjecting & SCAdjustTrackingInjection
    
    init(worker : SCAusweisAuthWorking, cityContentSharedWorker : SCCityContentSharedWorking , injector : SCAusweisAuthServiceInjecting & SCAdjustTrackingInjection) {
        
        self.worker = worker
        self.cityContentSharedWorker = cityContentSharedWorker
        self.injector = injector
        
    }
    
    func setDisplay(display: SCAusweisAuthWorkFlowDisplay) {
        self.display = display
    }
    
    func viewDidLoad() {
        
        worker.startAuth()
    }
    
    func viewWillAppear() {
        
    }
    
    func viewDidAppear() {
        
    }
    
    func handleWorkflowCloseButton() {
        
        // Removing the call for cancelOrFinishAuth() due to multiple calls to eidAuthenticationFailed event
        self.worker.cancelOrFinishAuth()
        self.display.dismissWorkFlowController()
    }
    
    func showAusweisLoading() {
        
        // eID process is started (ie. our eID UI appears)
        self.injector.trackEvent(eventName: AnalyticsKeys.EventName.eidProcessStarted)
        
        let viewController = injector.getAusweisAuthLoadingViewController(injector: self.injector, worker: self.worker)
        display.display(viewController: viewController)
        display.setNavigationTitle(title: "egov_info_title".localized())

    }
    
    func showAusweisOverview() {

        // eID process is started (ie. our eID UI appears)
        self.injector.trackEvent(eventName: AnalyticsKeys.EventName.eidProcessStarted)
        
        let viewController = injector.getAusweisAuthServiceOverviewViewController(injector: self.injector, worker: self.worker) as! SCAusweisAuthServiceOverviewController
        display.display(viewController: viewController)
        display.setNavigationTitle(title: "egov_info_title".localized())
    }
    
    func showAusweisInsertCardView() {

        debugPrint("Workflow Presenter : showAusweisInsertCardView")
        let viewController = injector.getAusweisAuthInsertCardViewController(injector: self.injector, worker: self.worker)
        display.display(viewController: viewController)
        display.setNavigationTitle(title: "egov_attach_card_title".localized())
    }
    
    func showAusweisEnterPIN() {
        
        debugPrint("Workflow Presenter : showAusweisInsertCardView")
        let viewController = injector.getAusweisAuthEnterPINViewController(injector: self.injector, worker: self.worker)
        display.display(viewController: viewController)
        display.setNavigationTitle(title: "egov_pin_title".localized())
    }
    
    
    func showAusweisNeedCAN() {
        
        let viewController = injector.getAusweisAuthNeedCANViewController(injector: self.injector, worker: self.worker)
        display.display(viewController: viewController)
        display.setNavigationTitle(title: "egov_caninfo_title".localized() )

    }
    
    func showAusweisEnterCAN() {
        
        let viewController = injector.getAusweisAuthEnterCANViewController(injector: self.injector, worker: self.worker)
        display.display(viewController: viewController)
        display.setNavigationTitle(title: "egov_can_title".localized() )
    }
    
    func showAusweisNeedPUK() {
    
        let viewController = injector.getAusweisAuthNeedPUKViewController(injector: self.injector, worker: self.worker)
        display.display(viewController: viewController)
        display.setNavigationTitle(title: "egov_caninfo_title".localized() )
        
    }
    
    func showAusweisEnterPUK() {
        
        let viewController = injector.getAusweisAuthEnterPUKViewController(injector: self.injector, worker: self.worker)
        display.display(viewController: viewController)
        display.setNavigationTitle(title: "egov_pukinfo_label".localized() )
    }
    
    func showAusweisSuccess() {
        // eID authentication was successful
        self.injector.trackEvent(eventName: AnalyticsKeys.EventName.eidAuthenticationSuccessful)
        
        let viewController = injector.getAusweisAuthSuccessViewController(injector: self.injector, worker: self.worker)
        display.display(viewController: viewController)
        display.setNavigationTitle(title: "egov_success_title".localized())
    }
    
    func showAusweisError(_ errorType: AusweisErrorType) {

//       TO DO - This does not work  
//        let currentViewController = display.getCurrentViewController()
//        if let _ = currentViewController as? SCAusweisAuthFailureViewController {
//            debugPrint("showAusweisError : returning as it is already visible")
//            return
//        }
        
        // eID authentication failed (for whatever reason)
        self.injector.trackEvent(eventName: AnalyticsKeys.EventName.eidAuthenticationFailed)

        switch errorType {
            
        case .payloadError :
            self.injector.trackEvent(eventName: AnalyticsKeys.EventName.eidAuthenticationFailedPayloadError)

        case .majorError :
            self.injector.trackEvent(eventName: AnalyticsKeys.EventName.eidAuthenticationFailedMajorError)

        case .accessRightsError :
            self.injector.trackEvent(eventName: AnalyticsKeys.EventName.eidAuthenticationFailedAccessRightsError)

        case .badStateError :
            self.injector.trackEvent(eventName: AnalyticsKeys.EventName.eidAuthenticationFailedBadStateError)

        case .messageError :
            self.injector.trackEvent(eventName: AnalyticsKeys.EventName.eidAuthenticationFailedMessageError)
            
        }

        let viewController = injector.getAusweisAuthFailureViewController(injector: self.injector, worker: self.worker)
        display.display(viewController: viewController)
        display.setNavigationTitle(title: "egov_attach_card_title".localized())
    }
    
    func finishWithSuccess(url : String) {
         
        NotificationCenter.default.post(Notification(name: Notification.Name.ausweisSDKServiceWorkflowDidFinishWithSuccess, object: url, userInfo: nil))
        display.dismissWorkFlowController()
    }
    
    
    func showAusweisServiceDetailInfo() {
        
        let viewController = injector.getAusweisAuthProviderInfoViewController(injector: self.injector, worker: self.worker)
        display.push(viewController: viewController)
        display.setNavigationTitle(title: "egov_certificate_providerinfo".localized())
    }
    
    func showAusweisEnterPINHelpView() {
        
        let viewController = injector.getAusweisAuthHelpViewController(injector: self.injector, worker: self.worker)
        display.push(viewController: viewController)
        display.setNavigationTitle(title: "egov_help_screen_title".localized())

    }
    
    func showAusweisCardBlockedView() {
       
        let viewController = injector.getAusweisAuthCardBlockedViewController(injector: self.injector, worker: self.worker)
        display.push(viewController: viewController)
        display.setNavigationTitle(title: "egov_cardblocked_title".localized())
    }
}
