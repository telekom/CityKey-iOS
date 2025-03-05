/*
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

SPDX-FileCopyrightText: 2025 Deutsche Telekom AG
SPDX-License-Identifier: Apache-2.0 AND LicenseRef-Deutsche-Telekom-Brand
License-Filename: LICENSES/Apache-2.0.txt LICENSES/LicenseRef-Deutsche-Telekom-Brand.txt
*///
//  SCDefectReporterLocationPresenterTests.swift
//  OSCATests
//
//  Created by Bhaskar N S on 22/07/22.
//  Copyright © 2022 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import XCTest
@testable import OSCA
import CoreLocation

class SCDefectReporterLocationPresenterTests: XCTestCase {
    weak private var display: SCDefectReporterLocationViewDisplayer!
    private func prepareSut(utilities: SCUtilityUsable? = nil) -> SCDefectReporterLocationPresenter {
        let serviceData = SCBaseComponentItem(itemID: "", itemTitle: "",
                                              itemHtmlDetail: false, itemColor: .blue)
        let defectcategory = SCModelDefectCategory(serviceCode: "", serviceName: "",
                                                   subCategories: [],
                                                   description: nil)
        let presenter: SCDefectReporterLocationPresenter = SCDefectReporterLocationPresenter(serviceData: serviceData,
                                                                                             injector: MockSCInjector(),
                                                                                             cityContentSharedWorker: SCCityContentSharedWorkerMock(),
                                                                                             category: defectcategory,
                                                                                             utilities: utilities ?? SCUtilitiesMock())
        return presenter
    }
    
    func testCloseButtonWasPressed() {
        let sut = prepareSut()
        let displayer = SCDefectReporterLocationViewDisplayer()
        display = displayer
        sut.setDisplay(displayer)
        sut.closeButtonWasPressed()
        XCTAssertTrue(display.isDismissCalled)
    }
    
    func testSavePositionBtnWasPressed() {
        let mockIndex = 1
        let mockUtitlies = SCUtilitiesMock(tabIndex: mockIndex)
        let sut = prepareSut(utilities: mockUtitlies)
        let displayer = SCDefectReporterLocationViewDisplayer()
        display = displayer
        sut.setDisplay(displayer)
        sut.savePositionBtnWasPressed()
        XCTAssertTrue(mockUtitlies.dismissAnyPresentedControllerCalled)
    }
    
    

}

extension MockSCInjector: SCDefectReporterInjecting {
    func getDefectReporterLocationViewController(category: SCModelDefectCategory, subCategory: SCModelDefectSubCategory?, serviceData: SCBaseComponentItem, includeNavController: Bool, service: Services, completionAfterDismiss: (() -> Void)?) -> UIViewController {
        return UIViewController()
    }
    
    func getDefectReporterSubCategoryViewController(category: SCModelDefectCategory, subCategoryList: [SCModelDefectSubCategory], serviceData: SCBaseComponentItem, service: Services) -> UIViewController {
        return UIViewController()
    }
    
    func getDefectReporterFormViewController(category: SCModelDefectCategory, subCategory: SCModelDefectSubCategory?, serviceData: SCBaseComponentItem, serviceFlow: Services) -> UIViewController {
        return UIViewController()
    }
    
    func getDefectReporterFormSubmissionViewController(category: SCModelDefectCategory, subCategory: SCModelDefectSubCategory?, uniqueId: String, serviceFlow: Services, email: String?) -> UIViewController {
        return UIViewController()
    }
    
    func getDefectReportTermsViewController(for url: String, title: String?, insideNavCtrl: Bool) -> UIViewController {
        return UIViewController()
    }
    
    func getFahrradparkenReportedLocationViewController(category: SCModelDefectCategory, subCategory: SCModelDefectSubCategory?, serviceData: SCBaseComponentItem, includeNavController: Bool, service: Services, completionAfterDismiss: (() -> Void)?) -> UIViewController {
        return UIViewController()
    }
    
    func getFahrradParkenReportedLocationDetailsViewController(with location: FahrradparkenLocation, serviceData: SCBaseComponentItem, compltionHandler: (() -> Void)?) -> UIViewController {
        return UIViewController()
    }
}

class SCDefectReporterLocationViewDisplayer: SCDefectReporterLocationViewDisplay {
    private(set) var isDismissCalled: Bool = false
    private(set) var isPushCalled: Bool = false
    private(set) var title: String = ""
    private(set) var message: String = ""
    private(set) var location: CLLocation?
    func dismiss(completion: (() -> Void)?) {
        isDismissCalled = true
    }
    
    func push(viewController: UIViewController) {
        isPushCalled = true
    }
    
    func showLocationFailedMessage(messageTitle: String, withMessage: String) {
        self.title = messageTitle
        self.message = withMessage
    }
    
    func reloadDefectLocationMap(location: CLLocation) {
        self.location = location
    }
}
