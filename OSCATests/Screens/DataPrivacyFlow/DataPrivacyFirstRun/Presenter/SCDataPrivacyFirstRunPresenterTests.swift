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
//  SCDataPrivacyFirstRunPresenterTests.swift
//  OSCATests
//
//  Created by Bhaskar N S on 11/07/22.
//  Copyright © 2022 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import XCTest
@testable import OSCA

class SCDataPrivacyFirstRunPresenterTests: XCTestCase {
    private var display: SCDataPrivacyFirstRunDisplayer!
    private func prepareSut(appContentSharedWorker: SCAppContentSharedWorking? = SCAppContentWorkerMock(),
                            preventSwipeToDismiss: Bool = false) -> SCDataPrivacyFirstRunPresenter {
        let presenter = SCDataPrivacyFirstRunPresenter(appContentSharedWorker: appContentSharedWorker ?? SCAppContentWorkerMock(),
                                                       injector: MockSCInjector(),
                                                       preventSwipeToDismiss: preventSwipeToDismiss)
        return presenter
    }
    
    func testViewDidLoad() {
        let sut = prepareSut()
        let mockNavTitle = LocalizationKeys.DataPrivacySettings.dialogDpnSettingsTitle.localized()
        let mockDescription = LocalizationKeys.DataPrivacyFirstRun.dialogDpnFtuTextFormat.localized()
        let displayer = SCDataPrivacyFirstRunDisplayer()
        display = displayer
        sut.setDisplay(displayer)
        sut.viewDidLoad()
        XCTAssertTrue(display.isSetupCalled)
        XCTAssertEqual(displayer.navigationTitle, mockNavTitle)
        XCTAssertEqual(displayer.description, mockDescription)
    }
    
    func testViewDidLoadPreventToDismiss() {
        let sut = prepareSut(preventSwipeToDismiss: true)
        let mockNavTitle = LocalizationKeys.DataPrivacySettings.dialogDpnSettingsTitle.localized()
        let mockDescription = LocalizationKeys.DataPrivacyFirstRun.dialogDpnFtuTextFormat.localized()
        let displayer = SCDataPrivacyFirstRunDisplayer()
        display = displayer
        sut.setDisplay(displayer)
        sut.viewDidLoad()
        XCTAssertTrue(display.isSetupCalled)
        XCTAssertEqual(displayer.navigationTitle, mockNavTitle)
        XCTAssertEqual(displayer.description, mockDescription)
        XCTAssertTrue(displayer.preventToDismissCalled)
    }
    
    func testAcceptAllPressed() {
        let mockWorker = SCAppContentWorkerMock()
        let sut = prepareSut(appContentSharedWorker: mockWorker)
        let displayer = SCDataPrivacyFirstRunDisplayer()
        display = displayer
        sut.setDisplay(displayer)
        sut.acceptAllPressed()
        XCTAssertTrue(mockWorker.privacyOptOutMoEngage)
        XCTAssertFalse(mockWorker.privacyOptOutAdjust)
        XCTAssertTrue(mockWorker.trackingPermissionFinished)
        XCTAssertTrue(displayer.isDismissCalled)
    }
    
    func testAcceptSelectedLinkPressed() {
        let mockWorker = SCAppContentWorkerMock()
        let sut = prepareSut(appContentSharedWorker: mockWorker)
        let displayer = SCDataPrivacyFirstRunDisplayer()
        display = displayer
        sut.setDisplay(displayer)
        sut.acceptSelectedLinkPressed()
        XCTAssertTrue(mockWorker.privacyOptOutMoEngage)
        XCTAssertTrue(mockWorker.privacyOptOutAdjust)
        XCTAssertTrue(mockWorker.trackingPermissionFinished)
        XCTAssertTrue(displayer.isDismissCalled)
    }
    
    func testDataPrivacyNoticeLinkPressed() {
        let sut = prepareSut()
        let displayer = SCDataPrivacyFirstRunDisplayer()
        display = displayer
        sut.setDisplay(displayer)
        sut.dataPrivacyNoticeLinkPressed()
        XCTAssertTrue(display.isNavigateToCalled)
    }
    
    func testChangeSettingsPressed() {
        let sut = prepareSut()
        let displayer = SCDataPrivacyFirstRunDisplayer()
        display = displayer
        sut.setDisplay(displayer)
        sut.changeSettingsPressed()
        XCTAssertTrue(display.isNavigateToCalled)
    }
}

class SCDataPrivacyFirstRunDisplayer: SCDataPrivacyFirstRunDisplay {
    private(set) var isSetupCalled: Bool = false
    private(set) var navigationTitle: String = ""
    private(set) var description: String = ""
    private(set) var isDismissCalled: Bool = false
    private(set) var isNavigateToCalled: Bool = false
    private(set) var preventToDismissCalled: Bool = false
    
    func setupUI(navigationTitle: String, description: String) {
        isSetupCalled = true
        self.navigationTitle = navigationTitle
        self.description = description
    }
    
    func preventSwipeToDismiss() {
        preventToDismissCalled = true
    }
    func dismiss(completion: (() -> Void)?) {
        isDismissCalled = true
    }
    func dismiss() {
        isDismissCalled = true
    }
    
    func navigateTo(_ controller: UIViewController) {
        isNavigateToCalled = true
    }
}
