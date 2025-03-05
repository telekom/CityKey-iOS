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
//  SCDefectReporterCategorySelectionViewControllerTests.swift
//  OSCATests
//
//  Created by Bhaskar N S on 25/07/22.
//  Copyright © 2022 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import XCTest
@testable import OSCA
class SCDefectReporterCategorySelectionViewControllerTests: XCTestCase {

    private func prepareSut(presenter: SCDefectReporterCategorySelectionPresenting? = nil) -> SCDefectReporterCategorySelectionViewController {
        let storyboard = UIStoryboard(name: "DefectReporter", bundle: nil)
        let sut = storyboard.instantiateViewController(identifier: "SCDefectReporterCategorySelectionViewController") as! SCDefectReporterCategorySelectionViewController
        sut.presenter = presenter ?? SCDefectReporterCategorySelectionPresenterMock()
        sut.loadViewIfNeeded()
        return sut
    }
    
    func testViewDidLoad() {
        let presenter = SCDefectReporterCategorySelectionPresenterMock()
        let sut = prepareSut(presenter: presenter)
        sut.viewDidLoad()
        guard let presenter = sut.presenter as? SCDefectReporterCategorySelectionPresenterMock else {
            XCTFail("Test Failed")
            return
        }
        XCTAssertTrue(presenter.isViewDidLoadCalled)
    }
    
    func testViewWillAppear() {
        let mockBackButtonTitle = LocalizationKeys.Common.navigationBarBack.localized()
        let presenter = SCDefectReporterCategorySelectionPresenterMock()
        let sut = prepareSut(presenter: presenter)
        sut.viewWillAppear(true)
        XCTAssertEqual(mockBackButtonTitle, sut.navigationItem.backButtonTitle)
    }
    
    func testReloadCategoryList() {
        let mockCategoryList = [SCModelDefectCategory(serviceCode: "", serviceName: "",
                                                      subCategories: [SCModelDefectSubCategory(serviceCode: "", serviceName: "",
                                                                                               description: "", isAdditionalInfo: false)], description: nil)]
        let presenter = SCDefectReporterCategorySelectionPresenterMock()
        let sut = prepareSut(presenter: presenter)
        sut.viewDidLoad()
        sut.reloadCategoryList(mockCategoryList)
        XCTAssertEqual(mockCategoryList, sut.categoryList)
    }
    
    func testNumberOfRows() {
        let mockCategoryList = [SCModelDefectCategory(serviceCode: "", serviceName: "",
                                                      subCategories: [SCModelDefectSubCategory(serviceCode: "", serviceName: "",
                                                                                               description: "", isAdditionalInfo: false)], description: nil)]
        let sut = prepareSut()
        sut.categoryList = mockCategoryList
        let count = sut.tableView(sut.tableView, numberOfRowsInSection: 0)
        XCTAssertEqual(1, count)
    }
    
    func testTableViewCellForRow() {
        let mockCategoryList = [SCModelDefectCategory(serviceCode: "", serviceName: "",
                                                      subCategories: [SCModelDefectSubCategory(serviceCode: "", serviceName: "",
                                                                                               description: "", isAdditionalInfo: false)], description: nil)]
        let sut = prepareSut()
        sut.categoryList = mockCategoryList
        let cell = sut.tableView(sut.tableView, cellForRowAt: IndexPath(row: 0, section: 0))
        XCTAssertTrue(cell is SCDefectReporterCategoryCell)
    }
    
    func testCellSelection() {
        let mockCategoryList = [SCModelDefectCategory(serviceCode: "service code", serviceName: "service name",
                                                      subCategories: [SCModelDefectSubCategory(serviceCode: "test",
                                                                                               serviceName: "test",
                                                                                               description: "test", isAdditionalInfo: false)], description: nil)]
        let sut = prepareSut()
        sut.categoryList = mockCategoryList
        sut.tableView(sut.tableView, didSelectRowAt: IndexPath(row: 0, section: 0))
        guard let presenter = sut.presenter as? SCDefectReporterCategorySelectionPresenterMock else {
            return
        }
        XCTAssertEqual(presenter.category, mockCategoryList[0])
    }
    
    func testSetNavigation() {
        let mockTitle = LocalizationKeys.SCDefectReporterCategorySelectionPresenter.dr001ChooseCategoryLabel.localized()
        let sut = prepareSut()
        sut.setNavigation(title: mockTitle)
        XCTAssertEqual(sut.navigationItem.title, mockTitle)
    }
}
