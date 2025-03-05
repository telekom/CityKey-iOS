/*
Created by Harshada Deshmukh on 06/05/21.
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

class SCDefectReporterCategorySelectionPresenter {
    
    weak private var display: SCDefectReporterCategorySelectionViewDisplay?
    private let injector: SCServicesInjecting & SCDefectReporterInjecting
    private let worker: SCDefectReporterWorking
    var category: [SCModelDefectCategory]?
    private let serviceData: SCBaseComponentItem
    var serviceFlow: Services = .defectReporter

    init(serviceData: SCBaseComponentItem,
         injector: SCServicesInjecting & SCDefectReporterInjecting,
         worker : SCDefectReporterWorking,
         category : [SCModelDefectCategory] ) {
        
        self.injector = injector
        self.worker = worker
        self.category = category
        self.serviceData = serviceData
    }
}

extension SCDefectReporterCategorySelectionPresenter : SCDefectReporterCategorySelectionPresenting {
    
    func viewDidLoad() {
        
        display?.reloadCategoryList(self.category ?? [])
        display?.setNavigation(title: LocalizationKeys.SCDefectReporterCategorySelectionPresenter.dr001ChooseCategoryLabel.localized())
    }
         
    func setDisplay(_ display : SCDefectReporterCategorySelectionViewDisplay) {
        self.display = display
    }

    func didSelectCategory(_ category : SCModelDefectCategory) {
            
        // Handle case for subcategory
        if category.subCategories.count != 0 {
            let controller = self.injector.getDefectReporterSubCategoryViewController(category: category, subCategoryList: category.subCategories, serviceData: self.serviceData, service: serviceFlow)
            self.display?.push(viewController: controller)
        }
        else{
            switch serviceFlow {
            case .defectReporter:
                let controller = self.injector.getDefectReporterLocationViewController(category: category, subCategory: nil,
                                                                                       serviceData: self.serviceData,
                                                                                       includeNavController: true,
                                                                                       service: serviceFlow,
                                                                                       completionAfterDismiss: nil)
                self.display?.present(viewController: controller)
            case .fahrradParken(let flow):
                switch flow {
                case .viewRequest:
                    let controller = self.injector.getFahrradparkenReportedLocationViewController(category: category, subCategory: nil,
                                                                                                  serviceData: self.serviceData,
                                                                                                  includeNavController: false,
                                                                                                  service: serviceFlow,
                                                                                                  completionAfterDismiss: nil)
                    self.display?.push(viewController: controller)
                case .submitRequest:
                    let controller = self.injector.getFahrradparkenReportedLocationViewController(category: category, subCategory: nil,
                                                                                                  serviceData: self.serviceData,
                                                                                                  includeNavController: true,
                                                                                                  service: serviceFlow,
                                                                                                  completionAfterDismiss: nil)
                    self.display?.present(viewController: controller)
                }
            
            }
        }
    }

}
