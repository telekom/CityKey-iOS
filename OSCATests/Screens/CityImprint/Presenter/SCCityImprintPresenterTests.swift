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
//  SCCityImprintPresenterTests.swift
//  OSCATests
//
//  Created by Bhaskar N S on 15/09/22.
//  Copyright © 2022 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import XCTest
@testable import OSCA

final class SCCityImprintPresenterTests: XCTestCase {
    weak var dispaly: SCCityImprintDisplayer?
    
    private func preparesut(cityContentSharedWorker: SCCityContentSharedWorking? = nil, injector: SCToolsShowing? = nil) -> SCCityImprintPresenter {
        return SCCityImprintPresenter(cityContentSharedWorker: cityContentSharedWorker ?? SCCityContentSharedWorkerMock(),
                                      injector: injector ?? MockSCInjector())
    }
    
    func testViewDidLoad() {
        let sut = preparesut()
        let displayer = SCCityImprintDisplayer()
        sut.setDisplay(displayer)
        sut.viewDidLoad()
        XCTAssertTrue(displayer.isSetupCalled)
        XCTAssertEqual(displayer.cityName, "Bad Honnef")
        XCTAssertEqual(displayer.imprintDesc, "test cityImprintDesc")
    }
    
    func testShowLocationSelector() {
        let mockInjector = MockSCInjector()
        let sut = preparesut(injector: mockInjector)
        let displayer = SCCityImprintDisplayer()
        sut.setDisplay(displayer)
        sut.viewDidLoad()
        sut.locationButtonWasPressed()
        XCTAssertTrue(mockInjector.isShowLocationSelectorCalled)
    }
    
    func testProfileButtonWasPressed() {
        let mockInjector = MockSCInjector()
        let sut = preparesut(injector: mockInjector)
        let displayer = SCCityImprintDisplayer()
        sut.setDisplay(displayer)
        sut.viewDidLoad()
        sut.profileButtonWasPressed()
        XCTAssertTrue(mockInjector.isShowProfileCalled)
    }
    
    func testImprintButtonWasPressed() {
        let mockInjector = MockSCInjector()
        let mockWorker = SCCityContentSharedWorkerMock()
        let sut = preparesut(injector: mockInjector)
        let displayer = SCCityImprintDisplayer()
        sut.setDisplay(displayer)
        sut.viewDidLoad()
        sut.imprintButtonWasPressed()
        XCTAssertNotNil(mockWorker.getCityContentData(for: 13)?.cityImprint)
    }

}

class SCCityImprintDisplayer: SCCityImprintDisplaying {
    private(set) var isSetupCalled: Bool = false
    private(set) var cityName: String?
    private(set) var imprintDesc: String?
    private(set) var coatImageUrl: OSCA.SCImageURL??
    private(set) var imprintImageUrl: OSCA.SCImageURL??
    func setupUI() {
        isSetupCalled = true
    }
    
    func updateCityName(_ cityName: String) {
        self.cityName = cityName
    }
    
    func updateCityImage(withURL: OSCA.SCImageURL?) {
        self.coatImageUrl = withURL
    }
    
    func updateImprintDesc(_ imprintDesc: String?) {
        self.imprintDesc = imprintDesc
    }
    
    func handleAppPreviewBannerView() {
        
    }
    
    func updateImprintImage(withUrl: SCImageURL?) {
        imprintImageUrl = withUrl
    }
}
