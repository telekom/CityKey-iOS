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
//  SCDefectReporterCategorySelectionPresenterTests.swift
//  OSCATests
//
//  Created by Bhaskar N S on 25/07/22.
//  Copyright © 2022 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import XCTest
@testable import OSCA

class SCDefectReporterCategorySelectionPresenterTests: XCTestCase {
    weak private var display: SCDefectReporterCategorySelectionViewDisplay?
    private func prepareSut(serviceData: SCBaseComponentItem? = nil,
                            category: [SCModelDefectCategory]? = nil) -> SCDefectReporterCategorySelectionPresenter {
        let defaultServiceData = SCBaseComponentItem(itemID: "", itemTitle: "",
                                              itemHtmlDetail: false, itemColor: .blue)
        let presenter = SCDefectReporterCategorySelectionPresenter(serviceData: serviceData ?? defaultServiceData,
                                                                   injector: MockSCInjector(),
                                                                   worker: SCDefectReporterWorkerMock(),
                                                                   category: category ?? [])
        return presenter
    }
    
    func testViewDidLoad() {
        let mockTitle: String = LocalizationKeys.SCDefectReporterCategorySelectionPresenter.dr001ChooseCategoryLabel.localized()
        let sut = prepareSut()
        let display = SCDefectReporterCategorySelectionViewDisplayer()
        self.display = display
        sut.setDisplay(display)
        sut.viewDidLoad()
        XCTAssertEqual(mockTitle, display.navTitle)
        XCTAssertTrue(display.categoryList.isEmpty)
    }
    
    func testDidSelectCategoryWithSubcategory() {
        let category = [SCModelDefectCategory(serviceCode: "",
                                              serviceName: "",
                                              subCategories: [SCModelDefectSubCategory(serviceCode: "", serviceName: "",
                                                                                       description: "", isAdditionalInfo: false)],
                                              description: nil)]
        let sut = prepareSut(serviceData: nil, category: category)
        let display = SCDefectReporterCategorySelectionViewDisplayer()
        self.display = display
        sut.setDisplay(display)
        sut.didSelectCategory(SCModelDefectCategory(serviceCode: "",
                                                    serviceName: "",
                                                    subCategories: [SCModelDefectSubCategory(serviceCode: "", serviceName: "",
                                                                                             description: "", isAdditionalInfo: false)], description: nil))
        XCTAssertTrue(display.isPushCalled)
        
    }
    
    func testDidSelectCategoryWithOutSubcategory() {
        let category = [SCModelDefectCategory(serviceCode: "",
                                              serviceName: "",
                                              subCategories: [],
                                              description: nil)]
        let sut = prepareSut(serviceData: nil, category: category)
        let display = SCDefectReporterCategorySelectionViewDisplayer()
        self.display = display
        sut.setDisplay(display)
        sut.didSelectCategory(SCModelDefectCategory(serviceCode: "",
                                                    serviceName: "",
                                                    subCategories: [],
                                                    description: nil))
        XCTAssertTrue(display.isPresentCalled)
        
    }

}

class SCDefectReporterCategorySelectionViewDisplayer: SCDefectReporterCategorySelectionViewDisplay {
    private(set) var reloadCategoryListCalled: Bool = false
    private(set) var categoryList: [SCModelDefectCategory] = []
    private(set) var navTitle: String = ""
    private(set) var isPresentCalled: Bool = false
    private(set) var isPushCalled: Bool = false
    func reloadCategoryList(_ categoryList: [SCModelDefectCategory]) {
        self.categoryList = categoryList
        reloadCategoryListCalled = true
    }
    
    func setNavigation(title: String) {
        navTitle = title
    }
    
    func push(viewController: UIViewController) {
        isPushCalled = true
    }
    
    func present(viewController: UIViewController) {
        isPresentCalled = true
    }
}
