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
//  SCDefectReporterSubCategoryPresenterTests.swift
//  OSCATests
//
//  Created by Bhaskar N S on 25/07/22.
//  Copyright © 2022 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import XCTest
@testable import OSCA

class SCDefectReporterSubCategoryPresenterTests: XCTestCase {
    weak private var display: SCDefectReporterSubCategoryViewDisplay?
    private func prepareSut(serviceData: SCBaseComponentItem? = nil,
                            category: SCModelDefectCategory? = nil,
                            subCategory: [SCModelDefectSubCategory] = []) -> SCDefectReporterSubCategoryPresenter {
        let defaultServiceData = SCBaseComponentItem(itemID: "", itemTitle: "",
                                              itemHtmlDetail: false, itemColor: .blue)
        let presenter = SCDefectReporterSubCategoryPresenter(serviceData: serviceData ?? defaultServiceData,
                                                             injector: MockSCInjector(),
                                                             worker: SCDefectReporterWorkerMock(),
                                                             category: category ?? SCModelDefectCategory(serviceCode: "", serviceName: "", subCategories: [], description: nil),
                                                             subCategory: subCategory)
        return presenter
    }
    
    func testViewDidLoad() {
        let mockCategory = SCModelDefectCategory(serviceCode: "test", serviceName: "testName", subCategories: [], description: nil)
        let sut = prepareSut(category: mockCategory)
        let display = SCDefectReporterSubCategoryViewDisplayer()
        self.display = display
        sut.setDisplay(display)
        sut.viewDidLoad()
        XCTAssertEqual(mockCategory.serviceName, display.navTitle)
        XCTAssertTrue(display.subCategoryList.isEmpty)
    }
    
    func testDidSelectSubCategory() {
        let subCategory = SCModelDefectSubCategory(serviceCode: "test", serviceName: "TestName",
                                                   description: "", isAdditionalInfo: false)
        let sut = prepareSut()
        let display = SCDefectReporterSubCategoryViewDisplayer()
        self.display = display
        sut.setDisplay(display)
        sut.didSelectSubCategory(subCategory)
        XCTAssertTrue(display.isPresentCalled)
    }
}

class SCDefectReporterSubCategoryViewDisplayer: SCDefectReporterSubCategoryViewDisplay {
    private(set) var reloadCategoryListCalled: Bool = false
    private(set) var subCategoryList: [SCModelDefectSubCategory] = []
    private(set) var navTitle: String = ""
    private(set) var isPresentCalled: Bool = false
    private(set) var isPushCalled: Bool = false
    func reloadSubCategoryList(_ subCategoryList: [SCModelDefectSubCategory]) {
        self.subCategoryList = subCategoryList
    }
    
    func setNavigation(title: String) {
        self.navTitle = title
    }
    
    func push(viewController: UIViewController) {
        isPushCalled = true
    }
    
    func present(viewController: UIViewController) {
        isPresentCalled = true
    }
    
    
}
