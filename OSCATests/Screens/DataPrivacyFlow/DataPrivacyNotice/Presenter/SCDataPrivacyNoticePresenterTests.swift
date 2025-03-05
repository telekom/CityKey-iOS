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
//  SCDataPrivacyNoticePresenterTests.swift
//  OSCATests
//
//  Created by Bhaskar N S on 08/07/22.
//  Copyright © 2022 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import XCTest
@testable import OSCA

class SCDataPrivacyNoticePresenterTests: XCTestCase {
    
    var displayer: SCDataPrivacyNoticeDisplay!
    
    private func prepareSut(appContentSharedWorker: SCAppContentSharedWorking? = nil) -> SCDataPrivacyNoticePresenter {
        let presenter: SCDataPrivacyNoticePresenter = SCDataPrivacyNoticePresenter(appContentSharedWorker: appContentSharedWorker ?? SCAppContentWorkerMock(),
                                                                                   injector: MockSCInjector())
        return presenter
        
    }
    
    func testViewDidLoad() {
        let mockTitle = LocalizationKeys.SCDataPrivacyNotice.dialogDpnUpdatedTitle.localized()
        let sut = prepareSut()
        let displayer = SCDataPrivacyNoticeDisplayer()
        self.displayer = displayer
        sut.setDisplay(displayer)
        sut.viewDidLoad()
        XCTAssertEqual(mockTitle, displayer.title)
        XCTAssertNotNil(displayer.dpnText)
    }
    
    func testOnAcceptClickedWithNoError() {
        let appContentSharedWorker: SCAppContentSharedWorking = SCAppContentWorkerMock(acceptDataPrivacyNoticeChangeError: nil,
                                                                                       count: 1)
        let sut = prepareSut(appContentSharedWorker: appContentSharedWorker)
        let displayer = SCDataPrivacyNoticeDisplayer()
        self.displayer = displayer
        sut.setDisplay(displayer)
        sut.onAcceptClicked()
        XCTAssertTrue(displayer.isDismissCalled)
    }
    
    func testOnAcceptClickedWithError() {
        let appContentSharedWorker: SCAppContentSharedWorking = SCAppContentWorkerMock(acceptDataPrivacyNoticeChangeError: .noInternet,
                                                                                       count: nil)
        let sut = prepareSut(appContentSharedWorker: appContentSharedWorker)
        let displayer = SCDataPrivacyNoticeDisplayer()
        self.displayer = displayer
        sut.setDisplay(displayer)
        sut.onAcceptClicked()
        XCTAssertTrue(displayer.isResetAcceptCalled)
    }
    
    func testOnShowNoticeClicked() {
        let sut = prepareSut()
        let displayer = SCDataPrivacyNoticeDisplayer()
        self.displayer = displayer
        sut.setDisplay(displayer)
        sut.onShowNoticeClicked()
        XCTAssertTrue(displayer.isPushCalled)
    }
}

class SCDataPrivacyNoticeDisplayer: SCDataPrivacyNoticeDisplay {
    private(set) var title: String = ""
    private(set) var dpnText: NSAttributedString?
    private(set) var isPushCalled: Bool = false
    private(set) var isDismissCalled: Bool = false
    private(set) var isResetAcceptCalled: Bool = false
    
    func setTitle(_ title: String) {
        self.title = title
    }
    
    func updateDPNText(_ string: NSAttributedString) {
        dpnText = string
    }
    
    func push(_ viewController: UIViewController) {
        isPushCalled = true
    }
    
    func dismiss() {
        isDismissCalled = true
    }
    
    func resetAcceptButtonState() {
        isResetAcceptCalled = true
    }
}
