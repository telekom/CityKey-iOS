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
import MapKit

class SCDefectReporterLocationPresenter {
    
    weak private var display: SCDefectReporterLocationViewDisplay?
    
    private let injector: SCAdjustTrackingInjection & SCDefectReporterInjecting
    private let cityContentSharedWorker: SCCityContentSharedWorking
    var category: SCModelDefectCategory?
    var subCategory: SCModelDefectSubCategory?
    private let serviceData: SCBaseComponentItem
    private let utilities: SCUtilityUsable
    var serviceFlow: Services = .defectReporter

    init(serviceData: SCBaseComponentItem,
         injector: SCAdjustTrackingInjection & SCDefectReporterInjecting,
         cityContentSharedWorker: SCCityContentSharedWorking,
         category: SCModelDefectCategory,
         subCategory: SCModelDefectSubCategory? = nil,
         utilities: SCUtilityUsable = SCUtilities()) {

        self.injector = injector
        self.cityContentSharedWorker = cityContentSharedWorker
        self.category = category
        self.subCategory = subCategory
        self.serviceData = serviceData
        self.utilities = utilities
    }
    
}

extension SCDefectReporterLocationPresenter : SCDefectReporterLocationPresenting {
    
    func setDisplay(_ display: SCDefectReporterLocationViewDisplay) {
        self.display = display
    }

    func closeButtonWasPressed() {
        self.display?.dismiss(completion: nil)
    }
    
    func savePositionBtnWasPressed() {
        utilities.dismissAnyPresentedViewController { [weak self] in
            guard let strongSelf = self else {
                return
            }
            let tabBarController = strongSelf.utilities.topViewController() as? UITabBarController
            if let indexForServiceTab = strongSelf.utilities.indexForServiceController() {
                tabBarController?.selectedIndex = indexForServiceTab
                let selectedViewController = tabBarController?.selectedViewController as? UINavigationController

                let controller = strongSelf.injector.getDefectReporterFormViewController(category: strongSelf.category!,
                                                                                         subCategory: strongSelf.subCategory,
                                                                                         serviceData: strongSelf.serviceData,
                                                                                         serviceFlow: strongSelf.serviceFlow)
                let defectReporterFormViewController = selectedViewController?.containsViewController(ofKind: SCDefectReporterFormViewController.self)
                if defectReporterFormViewController != true {
                    selectedViewController?.pushViewController(controller, animated: true)
                }
            }
        }
    }
    
}

