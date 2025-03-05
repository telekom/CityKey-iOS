/*
Created by Harshada Deshmukh on 09/05/21.
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

SPDX-FileCopyrightText: 2025 Deutsche Telekom AG, Harshada Deshmukh
SPDX-License-Identifier: Apache-2.0 AND LicenseRef-Deutsche-Telekom-Brand
License-Filename: LICENSES/Apache-2.0.txt LICENSES/LicenseRef-Deutsche-Telekom-Brand.txt
*/

import UIKit

class SCDefectReporterFormSubmissionPresenter {
    
    weak private var display: SCDefectReporterFormSubmissionViewDisplay?
    
    private let injector: SCAdjustTrackingInjection & SCDefectReporterInjecting
    private let cityContentSharedWorker: SCCityContentSharedWorking
    var category: SCModelDefectCategory?
    var subCategory : SCModelDefectSubCategory?
    var uniqueId: String
    var utitlies: SCUtilityUsable
    let serviceFlow: Services
    let reporterEmailId: String?

    init(injector: SCAdjustTrackingInjection & SCDefectReporterInjecting,
         cityContentSharedWorker: SCCityContentSharedWorking,
         uniqueId: String,
         category: SCModelDefectCategory,
         subCategory: SCModelDefectSubCategory? = nil,
         utitlies: SCUtilityUsable = SCUtilities(),
         serviceFlow: Services, reporterEmailId: String?) {

        self.injector = injector
        self.cityContentSharedWorker = cityContentSharedWorker
        self.uniqueId = uniqueId
        self.category = category
        self.subCategory = subCategory
        self.utitlies = utitlies
        self.serviceFlow = serviceFlow
        self.reporterEmailId = reporterEmailId
    }
    
}

extension SCDefectReporterFormSubmissionPresenter: SCPresenting {
    
    func viewDidLoad() {
        trackEvent()
        self.display?.setNavigation(title: self.subCategory != nil ? self.subCategory!.serviceName : self.category!.serviceName)
        self.display?.setupUI(category: self.category!, subCategory: self.subCategory ?? nil, uniqueId: self.uniqueId)
    }
    
    private func trackEvent() {
        var eventName: String
        switch serviceFlow {
        case .defectReporter:
            // SMARTC-13058 : Track additional events via Adjust - Defect Reporter
            // User submits a defect by pressing the submit button
            eventName = AnalyticsKeys.EventName.defectSubmitted
        case .fahrradParken(_):
            eventName = AnalyticsKeys.EventName.FahrradparkenSubmitted
        }
        self.injector.trackEvent(eventName: eventName)
    }
}

extension SCDefectReporterFormSubmissionPresenter : SCDefectReporterFormSubmissionPresenting {
    
    func setDisplay(_ display: SCDefectReporterFormSubmissionViewDisplay) {
        self.display = display
    }
    
    func okBtnWasPressed(){
        self.handleBackNavigationFlow()
    }
    
    private func handleBackNavigationFlow(){
        utitlies.dismissAnyPresentedViewController { [weak self] in
            guard let strongSelf = self else {
                return
            }
            let tabBarController = strongSelf.utitlies.topViewController() as? UITabBarController
            if let indexForServiceTab = strongSelf.utitlies.indexForServiceController() {
                tabBarController?.selectedIndex = indexForServiceTab
                let selectedViewController = tabBarController?.selectedViewController as? UINavigationController

                let controller = selectedViewController?.hasViewController(ofKind: SCServiceDetailViewController.self) as! SCServiceDetailViewController
                selectedViewController?.popToViewController(controller, animated: true)
            }
        }
    }
    
    func getCityName() -> String? {
        return cityContentSharedWorker.getCityContentData(for: cityContentSharedWorker.getCityID())?.city.name
    }
    
    func getCityId() -> Int {
        return cityContentSharedWorker.getCityID()
    }
    
    func showFeedbackLabel() -> Bool {
        switch serviceFlow {
        case .defectReporter:
            return true
        case .fahrradParken(_):
            let email = reporterEmailId ?? ""
            return email.isEmpty ? false : true
        }
    }
    
    func getServiceFlow() -> Services {
        return serviceFlow
    }
}
