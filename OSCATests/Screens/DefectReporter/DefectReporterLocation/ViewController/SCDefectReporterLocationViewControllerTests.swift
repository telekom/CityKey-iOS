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
//  SCDefectReporterLocationViewControllerTests.swift
//  OSCATests
//
//  Created by Bhaskar N S on 22/07/22.
//  Copyright © 2022 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import XCTest
@testable import OSCA
class SCDefectReporterLocationViewControllerTests: XCTestCase {

    private func prepareSut(serviceFlow: Services = .defectReporter) -> SCDefectReporterLocationViewController {
        let storyboard = UIStoryboard(name: "DefectReporter", bundle: nil)
        let sut = storyboard.instantiateViewController(identifier: "SCDefectReporterLocationViewController") as! SCDefectReporterLocationViewController
        sut.presenter = SCDefectReporterLocationPresenterMock(serviceFlow: serviceFlow)
        sut.loadViewIfNeeded()
        sut.viewDidLoad()
        sut.viewWillAppear(true)
        return sut
    }
    
    func testViewDidLoad() {
        let mockNavTitle = LocalizationKeys.SCDefectReporterLocationViewController.dr002LocationSelectionToolbarLabel.localized()
        let backBtnTitle = LocalizationKeys.Common.navigationBarBack.localized()
        let mockLocationInfoLabel = LocalizationKeys.SCDefectReporterLocationViewController.dr003LocationPageInfo1.localized().applyHyphenation()
        let sut = prepareSut()
        sut.viewDidLoad()
        guard let presenter = sut.presenter as? SCDefectReporterLocationPresenterMock else {
            XCTFail("Test Failed")
            return
        }
        XCTAssertTrue(presenter.isViewDidLoadCalled)
        XCTAssertEqual(sut.navigationItem.title, mockNavTitle)
        XCTAssertEqual(sut.navigationItem.backButtonTitle, backBtnTitle)
        XCTAssertEqual(sut.locationInfoLabel.attributedText, mockLocationInfoLabel)
    }
    
    func testViewWillAppear() {
        let sut = prepareSut()
        sut.viewWillAppear(true)
        guard let presenter = sut.presenter as? SCDefectReporterLocationPresenterMock else {
            XCTFail("Test Failed")
            return
        }
        XCTAssertTrue(presenter.isViewWillLoadCalled)
    }
    
    func testSavePositionBtnWasPressed() {
        let sut = prepareSut()
        sut.savePositionBtnWasPressed(UIButton())
        guard let presenter = sut.presenter as? SCDefectReporterLocationPresenterMock else {
            XCTFail("Test Failed")
            return
        }
        XCTAssertTrue(presenter.isSaveLocationCalled)
    }
    
    func testCloseBtnWasPressed() {
        let sut = prepareSut()
        sut.closeBtnWasPressed(UIButton())
        guard let presenter = sut.presenter as? SCDefectReporterLocationPresenterMock else {
            XCTFail("Test Failed")
            return
        }
        XCTAssertTrue(presenter.isCloseButtonCalled)
    }
}
