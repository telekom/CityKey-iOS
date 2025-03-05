/*
Created by Bhaskar N S on 19/05/23.
Copyright © 2023 Deutsche Telekom AG - VTI Organization. All rights reserved.

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

SPDX-FileCopyrightText: 2025 Deutsche Telekom AG, Bhaskar N S
SPDX-License-Identifier: Apache-2.0 AND LicenseRef-Deutsche-Telekom-Brand
License-Filename: LICENSES/Apache-2.0.txt LICENSES/LicenseRef-Deutsche-Telekom-Brand.txt
*/

import Foundation
import UIKit

enum Services {
    case defectReporter
    case fahrradParken(flow: FahrradParkenFlow)
}
enum FahrradParkenFlow {
    case submitRequest
    case viewRequest
}

class SCFahrradparkenServiceDetail: SCServiceDetailProvider {

    private let serviceData: SCBaseComponentItem
    private let injector: SCServicesInjecting & SCAdjustTrackingInjection
    private let cityContentSharedWorker: SCCityContentSharedWorking
    private let fahrradParkenReporterWorker: SCFahrradParkenReporterWorking = SCFahrradParkenReporterWoker(requestFactory: SCRequest())
    private var primaryButtonTitle: String = ""
    private var secondayButtonTitle: String = ""
    
    init(serviceData: SCBaseComponentItem,
         injector: SCServicesInjecting & SCAdjustTrackingInjection,
         cityContentSharedWorker: SCCityContentSharedWorking) {
        self.serviceData = serviceData
        self.injector = injector
        self.cityContentSharedWorker = cityContentSharedWorker
        if let actions = serviceData.itemBtnActions {
            for action in actions {
                if let serviceAction = action.modelServiceAction {
                    if serviceAction.actionOrder == 2 {
                        primaryButtonTitle = serviceAction.visibleText
                    } else if serviceAction.actionOrder == 1 {
                        secondayButtonTitle = serviceAction.visibleText
                    }
                }
            }
        }
    }
    
    func getServiceTitle() -> String {
        serviceData.itemTitle
    }
    
    func getBadgeDescriptionText() -> String? {
        nil
    }
    
    func getBadgeCount() -> String {
        "0"
    }
    
    func getButtonText() -> String {
        return primaryButtonTitle
    }
    
    func getSecondaryButtonText() -> String? {
        return secondayButtonTitle
    }
    
    func getPushController() -> UIViewController {
        return UIViewController()
    }
    
    func getButtonActionController() -> UIViewController? {
        return nil
    }
    
    func getButtonActionController(month: String?, completion: @escaping (UIViewController?, SCWorkerError?, Bool) -> Void) {
        let cityId = cityContentSharedWorker.getCityID()
        fahrradParkenReporterWorker.getFahrradparkenCategories(cityId: "\(cityId)") { (categories, error) in

            guard error == nil else {
                completion(nil, error, false)
                return
            }

            let defectReporterCategoryViewController = self.injector.getDefectReporterCategoryViewController(categoryList: categories,
                                                                                                             serviceData: self.serviceData,
                                                                                                             serviceFlow: .fahrradParken(flow: .submitRequest))

            completion(defectReporterCategoryViewController, nil, true)
        }
    }
    
    func getServiceStatusButtonActionController(completion: @escaping (UIViewController?, SCWorkerError?, Bool) -> Void) {
        let cityId = cityContentSharedWorker.getCityID()
        fahrradParkenReporterWorker.getFahrradparkenCategories(cityId: "\(cityId)") { (categories, error) in

            guard error == nil else {
                completion(nil, error, false)
                return
            }

            let defectReporterCategoryViewController = self.injector.getDefectReporterCategoryViewController(categoryList: categories,
                                                                                                             serviceData: self.serviceData,
                                                                                                             serviceFlow: .fahrradParken(flow: .viewRequest))
            completion(defectReporterCategoryViewController, nil, true)
        }
    }
    
    func getServiceID() -> String {
        serviceData.itemID
    }
    
    func submitDefect(cityId: String, defectRequest: SCModelDefectRequest, completion: @escaping ((_ uniqueId : String?, _ error: SCWorkerError?) -> Void)) {
        fahrradParkenReporterWorker.submitDefect(cityId: cityId, defectRequest: defectRequest, completion: completion)
    }
    
    func uploadDefectImage(cityId: String, imageData: Data, completion: @escaping ((_ mediaURL : String?, _ error: SCWorkerError?) -> Void)) {
        fahrradParkenReporterWorker.uploadDefectImage(cityId: cityId, imageData: imageData, completion: completion)
    }
}
