/*
Created by Harshada Deshmukh on 04/05/21.
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

import Foundation
import UIKit

class SCDefectReporterServiceDetail: SCServiceDetailProvider {
    
    private let serviceData: SCBaseComponentItem
    private let injector: SCServicesInjecting & SCAdjustTrackingInjection// & SCDefectReporterInjecting
    private let cityContentSharedWorker: SCCityContentSharedWorking
    private let defectReporterWorker: SCDefectReporterWorking

    init(serviceData: SCBaseComponentItem,
         injector: SCServicesInjecting & SCAdjustTrackingInjection,//& SCDefectReporterInjecting,
         cityContentSharedWorker: SCCityContentSharedWorking,
         defectReporterWorker: SCDefectReporterWorking) {
        self.serviceData = serviceData
        self.injector = injector
        self.cityContentSharedWorker = cityContentSharedWorker
        self.defectReporterWorker = defectReporterWorker
    }

    func getServiceTitle() -> String {
        return serviceData.itemTitle
    }

    func getBadgeDescriptionText() -> String? {
        // HARSHADA TODO - Uncomment when we implementing More info screen
//        return "d_001_defect_reporter_more_info_button".localized()
        return serviceData.helpLinkTitle
    }

    func getButtonText() -> String {
        return serviceData.itemBtnActions?.first?.title ?? LocalizationKeys.SCDefectReporterServiceDetail.d001DefectReporterDetailButtonLabel.localized()
    }
    
    func getServiceID() -> String {
        serviceData.itemID
    }

    func getBadgeCount() -> String {
        return "0"
    }

    func getPushController() -> UIViewController {
        // HARSHADA TODO
        let controller = self.injector.getServicesMoreInfoViewController(for: self, injector: injector)
        return controller

    }

    func getButtonActionController() -> UIViewController? {
        return nil
    }
    
    func getButtonActionController(month: String?, completion: @escaping (UIViewController?, SCWorkerError?, Bool) -> Void) {
        
        let cityId = cityContentSharedWorker.getCityID()
        defectReporterWorker.getDefectCategories(cityId: "\(cityId)") { (defectReporterCategories, error) in

            guard error == nil else {
                completion(nil, error, false)
                return
            }

            let defectReporterCategoryViewController = self.injector.getDefectReporterCategoryViewController(categoryList: defectReporterCategories, serviceData: self.serviceData, serviceFlow: .defectReporter)
            completion(defectReporterCategoryViewController, nil, true)

        }
    }
    
    func submitDefect(cityId: String, defectRequest: SCModelDefectRequest, completion: @escaping ((String?, SCWorkerError?) -> Void)) {
        defectReporterWorker.submitDefect(cityId: cityId, defectRequest: defectRequest, completion: completion)
    }
    
    func uploadDefectImage(cityId: String, imageData: Data, completion: @escaping ((_ mediaURL : String?, _ error: SCWorkerError?) -> Void)) {
        defectReporterWorker.uploadDefectImage(cityId: cityId, imageData: imageData, completion: completion)
    }
}
