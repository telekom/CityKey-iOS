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
//  SCCityImprintViewControllerTests.swift
//  OSCATests
//
//  Created by Bhaskar N S on 15/09/22.
//  Copyright © 2022 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import XCTest
@testable import OSCA

final class SCCityImprintViewControllerTests: XCTestCase {

    private func prepareSut(presenter: SCCityImprintPresenting? = nil) -> SCCityImprintViewController {
        let storyboard = UIStoryboard(name: "CityImprintScreen", bundle: nil)
        let sut = storyboard.instantiateViewController(identifier: "SCCityImprintViewController") as! SCCityImprintViewController
        sut.presenter = presenter ?? SCCityImprintPresenterMock()
        sut.loadViewIfNeeded()
        return sut
    }
    
    func testViewDidLoad() {
        let sut = prepareSut()
        sut.viewDidLoad()
        guard let presenter = sut.presenter as? SCCityImprintPresenterMock else {
            XCTFail("Test Failed")
            return
        }
        XCTAssertTrue(presenter.isViewLoaded)
    }
    
    func testViewWillAppear() {
        let sut = prepareSut()
        sut.viewWillAppear(true)
        guard let presenter = sut.presenter as? SCCityImprintPresenterMock else {
            XCTFail("Test Failed")
            return
        }
        XCTAssertTrue(presenter.isViewWillAppearCalled)
    }
    
    func testViewDidAppear() {
        let mockBannerText = LocalizationKeys.AppPreviewUI.h001HomeAppPreviewBannerText.localized()
        let sut = prepareSut()
        sut.viewDidAppear(true)
        guard let presenter = sut.presenter as? SCCityImprintPresenterMock else {
            XCTFail("Test Failed")
            return
        }
        XCTAssertNotNil(presenter.isViewDidAppearCalled)
        XCTAssertEqual(sut.appPreviewBannerLabel.text, mockBannerText)
    }
    
    func testBarBtnGeoLocationWasPressed() {
        let mockBannerText = LocalizationKeys.AppPreviewUI.h001HomeAppPreviewBannerText.localized()
        let sut = prepareSut()
        sut.viewDidLoad()
        sut.barBtnGeoLocationWasPressed(UIButton())
        guard let presenter = sut.presenter as? SCCityImprintPresenterMock else {
            XCTFail("Test Failed")
            return
        }
        XCTAssertTrue(presenter.isLocationButtonWasPressed)
    }
    
    func testBarBtnProfilenWasPressed() {
        let mockBannerText = LocalizationKeys.AppPreviewUI.h001HomeAppPreviewBannerText.localized()
        let sut = prepareSut()
        sut.viewDidLoad()
        sut.barBtnProfilenWasPressed(UIButton())
        guard let presenter = sut.presenter as? SCCityImprintPresenterMock else {
            XCTFail("Test Failed")
            return
        }
        XCTAssertTrue(presenter.isProfileButtonWasPreesed)
    }
    
    func testOpenCityImprintBtnWasPressed() {
        let mockBannerText = LocalizationKeys.AppPreviewUI.h001HomeAppPreviewBannerText.localized()
        let sut = prepareSut()
        sut.viewDidLoad()
        sut.openCityImprintBtnWasPressed(UIButton())
        guard let presenter = sut.presenter as? SCCityImprintPresenterMock else {
            XCTFail("Test Failed")
            return
        }
        XCTAssertTrue(presenter.isImprintButtonWasPressed)
    }
    
    func testSetupUI() {
        let mockNavTitle = LocalizationKeys.CitykeyImprint.h001NavigationBarBtnImprint.localized()
        let headerTitle = LocalizationKeys.CitykeyImprint.h001NavigationBarBtnImprint.localized()
        let btnTitle = LocalizationKeys.CitykeyImprint.ci001ButtonText.localized()
        let sut = prepareSut()
        sut.viewDidLoad()
        sut.setupUI()
        XCTAssertEqual(sut.navigationItem.title, mockNavTitle)
        XCTAssertEqual(sut.headerTitleLabel.text, headerTitle)
        XCTAssertEqual(sut.cityImprintBtn.titleLabel?.text, btnTitle)
    }
    
    func testUpdateCityName() {
        let sut = prepareSut()
        sut.viewDidLoad()
        sut.updateCityName("Bad Honnef")
        XCTAssertEqual(sut.headerDetailLabel.text, "Bad Honnef")
    }

    func testUpdateImprintDesc() {
        let desc = "Imprint description"
        let sut = prepareSut()
        sut.viewDidLoad()
        sut.updateImprintDesc(desc)
        XCTAssertNotNil(sut.contentDetail.text)
    }
}

class SCCityImprintPresenterMock: SCCityImprintPresenting {
    private(set) var isViewLoaded: Bool = false
    private(set) var isViewWillAppearCalled: Bool = false
    private(set) var isViewDidAppearCalled: Bool = false
    var mandatoryFields: [SCDefectReporterInputFields] = []
    private(set) var isLocationButtonWasPressed: Bool = false
    private(set) var isProfileButtonWasPreesed: Bool = false
    private(set) var isImprintButtonWasPressed: Bool = false
    
    func viewDidLoad() {
        isViewLoaded = true
    }
    
    func viewWillAppear() {
        isViewWillAppearCalled = true
    }
    
    func viewDidAppear() {
        isViewDidAppearCalled = true
    }
    
    func setDisplay(_ display: OSCA.SCCityImprintDisplaying) {
        
    }
    
    func locationButtonWasPressed() {
        isLocationButtonWasPressed = true
    }
    
    func profileButtonWasPressed() {
        isProfileButtonWasPreesed = true
    }
    
    func imprintButtonWasPressed() {
        isImprintButtonWasPressed = true
    }
}
