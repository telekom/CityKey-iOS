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
//  SCRegistrationConfirmEMailFinishedPresenterTests.swift
//  OSCATests
//
//  Created by Bhaskar N S on 16/07/24.
//  Copyright © 2024 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import XCTest
@testable import OSCA

final class SCRegistrationConfirmEMailFinishedPresenterTests: XCTestCase {

    weak private var display : SCRegistrationConfirmEMailFinishedDisplaying?
    
    func prepareSut(injector: SCToolsShowing & SCAdjustTrackingInjection = MockSCInjector(),
                    shouldHideTopImage: Bool = false,
                    presentationType: SCRegistrationConfirmEMailType = .confirmMailForRegistration,
                    completion: (() -> Void)? = nil) -> SCRegistrationConfirmEMailFinishedPresenting {
        let displayer: SCRegistrationConfirmEMailFinishedDisplaying = SCRegistrationConfirmEMailFinishedDisplayer()
        let presenter = SCRegistrationConfirmEMailFinishedPresenter(injector: injector,
                                                           shouldHideTopImage: shouldHideTopImage,
                                                           presentationType: presentationType,
                                                           completionOnSuccess: completion)
        presenter.setDisplay(displayer)
        return presenter
    }
    
    func testViewDidLoadWithConfirmMailPwd() {
        let mockNavTitle = "f_001_forgot_password_btn_reset_password".localized()
        let titleText = "f_003_forgot_password_confirm_success_headline".localized()
        let detailText =  "f_003_forgot_password_confirm_success_details".localized()
        let btnText =  "f_003_forgot_password_confirm_success_login_btn".localized()
        let topImageSymbol = UIImage(named: "icon_reset_password")!

        let sut = prepareSut(presentationType: .confirmMailForPWDReset)
        let displayer = SCRegistrationConfirmEMailFinishedDisplayer()
        self.display = displayer
        sut.setDisplay(displayer)
        sut.viewDidLoad()
        XCTAssertEqual(displayer.navTitle, mockNavTitle)
        XCTAssertEqual(displayer.titleText, titleText)
        XCTAssertEqual(displayer.detailText, detailText)
        XCTAssertEqual(displayer.btnText, btnText)
        XCTAssertEqual(displayer.topImageSymbol.pngData(), topImageSymbol.pngData())
    }
    
    func testViewDidLoadWithConfirmMailSentBeforeRegistration() {
        let mockNavTitle = "r_005_registration_success_title".localized()
        let titleText = "r_005_registration_success_headline".localized()
        let detailText =  "r_005_registration_success_details".localized()
        let btnText =  "r_005_registration_success_login_btn".localized()
        let topImageSymbol = UIImage(named: "icon_confirm_email")!

        let sut = prepareSut(presentationType: .confirmMailForRegistration)
        let displayer = SCRegistrationConfirmEMailFinishedDisplayer()
        self.display = displayer
        sut.setDisplay(displayer)
        sut.viewDidLoad()
        XCTAssertEqual(displayer.navTitle, mockNavTitle)
        XCTAssertEqual(displayer.titleText, titleText)
        XCTAssertEqual(displayer.detailText, detailText)
        XCTAssertEqual(displayer.btnText, btnText)
        XCTAssertEqual(displayer.topImageSymbol.pngData(), topImageSymbol.pngData())
    }
    
    func testViewDidLoadWithConfirmMailForEditEmail() {
        let mockNavTitle = "p_004_profile_email_success_title".localized()
        let titleText = "p_004_profile_email_changed_info_sent_mail".localized()
        let detailText =  "p_004_profile_email_changed_info_received".localized()
        let btnText =  "r_005_registration_success_login_btn".localized()
        let topImageSymbol = UIImage(named: "icon_confirm_email")!

        let sut = prepareSut(presentationType: .confirmMailForEditEmail)
        let displayer = SCRegistrationConfirmEMailFinishedDisplayer()
        self.display = displayer
        sut.setDisplay(displayer)
        sut.viewDidLoad()
        XCTAssertEqual(displayer.navTitle, mockNavTitle)
        XCTAssertEqual(displayer.titleText, titleText)
        XCTAssertEqual(displayer.detailText, detailText)
        XCTAssertEqual(displayer.btnText, btnText)
        XCTAssertEqual(displayer.topImageSymbol.pngData(), topImageSymbol.pngData())
    }
    
    func testFinishedWasPressed() {
        let completionHandler = {
            print("completed##")
        }
        let mockInjector = MockSCInjector()
        let sut = prepareSut(injector: mockInjector,
                             presentationType: .confirmMailForEditEmail,
                             completion: completionHandler)
        sut.finishedWasPressed()
        XCTAssertTrue(mockInjector.isTrackEventCalled)
    }
}


final class SCRegistrationConfirmEMailFinishedDisplayer: SCRegistrationConfirmEMailFinishedDisplaying {
    
    private(set) var titleText: String = ""
    private(set) var detailText: String = ""
    private(set) var btnText: String = ""
    private(set) var topImageSymbol: UIImage = UIImage()
    private(set) var navTitle: String = ""
    
    func setupNavigationBar(title: String) {
        navTitle = title
    }
    
    func setupUI(titleText: String, detailText: String, btnText: String, topImageSymbol: UIImage) {
        self.titleText = titleText
        self.detailText = detailText
        self.btnText = btnText
        self.topImageSymbol = topImageSymbol
    }
    
    func dismissView(completion: (() -> Void)?) {
        
    }
    
    func popViewController() {
        
    }
    
    func hideTopImage() {
        
    }
}
