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
//  SCDefectReporterFormSubmissionViewControllerTests.swift
//  OSCATests
//
//  Created by Bhaskar N S on 26/07/22.
//  Copyright © 2022 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import XCTest
@testable import OSCA

class SCDefectReporterFormSubmissionViewControllerTests: XCTestCase {
    private func prepareSut(presenter: SCDefectReporterFormSubmissionPresenting? = nil) -> SCDefectReporterFormSubmissionViewController {
        let storyboard = UIStoryboard(name: "DefectReporter", bundle: nil)
        let sut = storyboard.instantiateViewController(identifier: "SCDefectReporterFormSubmissionViewController") as! SCDefectReporterFormSubmissionViewController
        sut.presenter = presenter ?? SCDefectReporterFormSubmissionPresenterMock()
        sut.loadViewIfNeeded()
        return sut
    }
    
    func testViewDidLoad() {
        let presenter = SCDefectReporterFormSubmissionPresenterMock()
        let sut = prepareSut(presenter: presenter)
        sut.viewDidLoad()
        guard let presenter = sut.presenter as? SCDefectReporterFormSubmissionPresenterMock else {
            XCTFail("Test Failed")
            return
        }
        XCTAssertTrue(presenter.isViewDidLoadCalled)
    }
    
    func testOkBtnWasPressed() {
        let presenter = SCDefectReporterFormSubmissionPresenterMock()
        let sut = prepareSut(presenter: presenter)
        sut.okBtnWasPressed(UIButton())
        guard let presenter = sut.presenter as? SCDefectReporterFormSubmissionPresenterMock else {
            XCTFail("Test Failed")
            return
        }
        XCTAssertTrue(presenter.isOkBtnWasPressedCalled)
    }
    
    func testSetupUI() {
        let subCategory = SCModelDefectSubCategory(serviceCode: "subServiceCode",
                                                     serviceName: "subServiceName",
                                                     description: "",
                                                     isAdditionalInfo: false)
        let category = SCModelDefectCategory(serviceCode: "serviceCode",
                                             serviceName: "serviceName",
                                             subCategories: [SCModelDefectSubCategory(serviceCode: "",
                                                                                      serviceName: "",
                                                                                      description: "",
                                                                                      isAdditionalInfo: false)],
                                             description: nil)
        let uniqueId = "123"
        let presenter = SCDefectReporterFormSubmissionPresenterMock()
        let sut = prepareSut(presenter: presenter)
        sut.setupUI(category: category, subCategory: subCategory, uniqueId: uniqueId)
        XCTAssertEqual(sut.thankYouLabel?.text, LocalizationKeys.SCDefectReporterFormSubmissionVC.dr004ThankYouMsg.localized())
        XCTAssertEqual(sut.thankYouInfoLabel?.text, LocalizationKeys.SCDefectReporterFormSubmissionVC.dr004ThankYouMsg1.localized().replacingOccurrences(of: "%s", with: presenter.getCityName()!))
        XCTAssertEqual(sut.categoryTitleLabel?.text, LocalizationKeys.SCDefectReporterFormSubmissionVC.dr004CategoryLabel.localized())
        XCTAssertEqual(sut.uniqueIdTitleLabel.text, LocalizationKeys.SCDefectReporterFormSubmissionVC.dr004UniqueIdLabel.localized())
        XCTAssertEqual(sut.uniqueIdLabel.text, uniqueId)
        XCTAssertEqual(sut.reportedOnTitleLabel.text, LocalizationKeys.SCDefectReporterFormSubmissionVC.d004ReportedOnLabel.localized())
        XCTAssertEqual(sut.reportedOnLabel.text, defectReportStringFromDate(date: Date()))
        XCTAssertEqual(sut.feedbackLabel.text, LocalizationKeys.SCDefectReporterFormSubmissionVC.d004SubmitInfoMsg.localized())
        XCTAssertEqual(sut.okBtn.titleLabel?.text, LocalizationKeys.SCDefectReporterFormSubmissionVC.dr004OkButton.localized())
        XCTAssertFalse(sut.uniqueIdStackView.isHidden)
    }
    
    func testsetNavigation() {
        let backBtnTitle = LocalizationKeys.Common.navigationBarBack.localized()
        let presenter = SCDefectReporterFormSubmissionPresenterMock()
        let sut = prepareSut(presenter: presenter)
        sut.setNavigation(title: "Nav Title")
        XCTAssertEqual(sut.navigationItem.title, "Nav Title")
        XCTAssertEqual(sut.navigationItem.backButtonTitle, backBtnTitle)
        
    }

}
