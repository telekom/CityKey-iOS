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
//  SCDataPrivacySettingsPresenterTests.swift
//  OSCATests
//
//  Created by Bhaskar N S on 08/07/22.
//  Copyright © 2022 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import XCTest
@testable import OSCA

class SCDataPrivacySettingsPresenterTests: XCTestCase {

    private var displayer: SCDataPrivacySettingsDisplay!
    private func prepareSut(worker: SCAppContentSharedWorking? = nil,
                            isFirstRunSettings: Bool = false,
                            shouldPushDataPrivacyController: Bool = false) -> SCDataPrivacySettingsPresenter {
        let presenter = SCDataPrivacySettingsPresenter(appContentSharedWorker:  worker ?? SCAppContentWorkerMock(),
                                                       injector: MockSCInjector(),
                                                       shouldPushDataPrivacyController: shouldPushDataPrivacyController,
                                                       preventSwipeToDismiss: false,
                                                       isFirstRunSettings: isFirstRunSettings)
        return presenter
    }
    
    func testViewDidLoad() {
        let mockTitle = LocalizationKeys.DataPrivacySettings.dialogDpnSettingsHeadline.localized()
        let sut = prepareSut()
        let displayer = SCDataPrivacySettingsDisplayer()
        sut.setDisplay(displayer)
        sut.viewDidLoad()
        XCTAssertTrue(displayer.isSetupCalled)
        XCTAssertEqual(mockTitle, displayer.title)
    }
    
    func testAcceptAllPressedFirstRun() {
        let sut = prepareSut(isFirstRunSettings: true)
        let displayer = SCDataPrivacySettingsDisplayer()
        sut.setDisplay(displayer)
        sut.acceptAllPressed()
        XCTAssertTrue(displayer.isDismissCalled)
    }
    
    func testAcceptAllPressed() {
        let sut = prepareSut(isFirstRunSettings: false)
        let displayer = SCDataPrivacySettingsDisplayer()
        sut.setDisplay(displayer)
        sut.acceptAllPressed()
        XCTAssertTrue(displayer.isPopCalled)
    }
    
    func testDataPrivacyLinkPressedPush() {
        let sut = prepareSut(shouldPushDataPrivacyController: true)
        let displayer = SCDataPrivacySettingsDisplayer()
        sut.setDisplay(displayer)
        sut.dataPrivacyLinkPressed()
        XCTAssertTrue(displayer.isPushCalled)
    }
    
    func testDataPrivacyLinkPressed() {
        let sut = prepareSut(shouldPushDataPrivacyController: false)
        let displayer = SCDataPrivacySettingsDisplayer()
        sut.setDisplay(displayer)
        sut.dataPrivacyLinkPressed()
        XCTAssertTrue(displayer.isPopCalled)
    }
    
    func testAcceptSelectedPressedFirstRun() {
        let sut = prepareSut(isFirstRunSettings: false)
        let displayer = SCDataPrivacySettingsDisplayer()
        sut.setDisplay(displayer)
        sut.acceptSelectedPressed(adjustSwitchStatus: true)
        XCTAssertTrue(displayer.isPopCalled)
    }
    
    func testAcceptSelectedPressed() {
        let sut = prepareSut(isFirstRunSettings: true)
        let displayer = SCDataPrivacySettingsDisplayer()
        sut.setDisplay(displayer)
        sut.acceptSelectedPressed(adjustSwitchStatus: true)
        XCTAssertTrue(displayer.isDismissCalled)
    }
}

class SCDataPrivacySettingsDisplayer: SCDataPrivacySettingsDisplay {
    private(set) var isSetupCalled: Bool = false
    private(set) var title: String = ""
    private(set) var isDismissCalled: Bool = false
    private(set) var isPushCalled: Bool = false
    private(set) var isPopCalled: Bool = false
    func setupUI(navigationTitle: String, title: String, description: String, moengageTitle: String, moengageDescription: String, adjustTitle: String, adjustDescription: String, adjustEnabled: Bool) {
        isSetupCalled = true
        self.title = title
    }
    
    func preventSwipeToDismiss() {
        
    }
    
    func dismiss() {
        isDismissCalled = true
    }
    
    func push(_ controller: UIViewController) {
        isPushCalled = true
    }
    
    func popViewController() {
        isPopCalled = true
    }
    
    func dismiss(completionHandler: (() -> Void)?) {
        isDismissCalled = true
    }
}
