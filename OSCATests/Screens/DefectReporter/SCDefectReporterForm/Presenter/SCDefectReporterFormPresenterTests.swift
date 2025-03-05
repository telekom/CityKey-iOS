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
//  SCDefectReporterFormPresenterTests.swift
//  OSCATests
//
//  Created by Bhaskar N S on 26/07/22.
//  Copyright © 2022 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import XCTest
@testable import OSCA

class SCDefectReporterFormPresenterTests: XCTestCase {
    weak var display: SCDefectReporterFormViewDisplayer?
    
    func prepareSut(serviceData: SCBaseComponentItem? = nil,
                            category: SCModelDefectCategory,
                            subCategory: SCModelDefectSubCategory? = nil,
                            auth: SCAuthStateProviding? = nil,
                            defectWorker: SCDefectReporterWorking? = nil) -> SCDefectReporterFormPresenter {
        let defaultServiceData = SCBaseComponentItem(itemID: "", itemTitle: "",
                                              itemHtmlDetail: false, itemColor: .blue)
        let defectReporterServiceDetails = SCDefectReporterServiceDetail(serviceData: defaultServiceData,
                                                                         injector: MockSCInjector(),
                                                                         cityContentSharedWorker: SCCityContentSharedWorkerMock(),
                                                                         defectReporterWorker: defectWorker ?? SCDefectReporterWorkerMock())
        let presenter = SCDefectReporterFormPresenter(serviceData: serviceData ?? defaultServiceData,
                                                      injector: MockSCInjector(),
                                                      appContentSharedWorker: SCAppContentWorkerMock(),
                                                      cityContentSharedWorker: SCCityContentSharedWorkerMock(),
                                                      userContentSharedWorker: SCUserContentSharedWorkerMock(),
                                                      category: category,
                                                      auth: auth ?? SCAuthMock(),
                                                      mainQueue: MockQueue(),
                                                      serviceDetail: defectReporterServiceDetails,
                                                      serviceFlow: .defectReporter)
        presenter.subCategory = subCategory
        return presenter
    }
    
    func testSetupUIWithNoSubCategory() {
        let category = SCModelDefectCategory(serviceCode: "serviceCode",
                                             serviceName: "serviceName",
                                             subCategories: [], description: nil)
        let sut = prepareSut(category: category)
        let displayer = SCDefectReporterFormViewDisplayer()
        display = displayer
        sut.setDisplay(displayer)
        sut.setupUI()
        XCTAssertTrue(displayer.isSetNavigationCalled)
        XCTAssertEqual(displayer.navTitle, category.serviceName)
    }
    
    func testSetupUIWithSubCategory() {
        let category = SCModelDefectCategory(serviceCode: "serviceCode",
                                             serviceName: "serviceName",
                                             subCategories: [], description: nil)
        let subCategory = SCModelDefectSubCategory(serviceCode: "serviceCode", serviceName: "serviceSubName",
                                                   description: "", isAdditionalInfo: false)
        let sut = prepareSut(category: category, subCategory: subCategory)
        let displayer = SCDefectReporterFormViewDisplayer()
        display = displayer
        sut.setDisplay(displayer)
        sut.setupUI()
        XCTAssertTrue(displayer.isSetNavigationCalled)
        XCTAssertEqual(displayer.navTitle, subCategory.serviceName)
        XCTAssertTrue(displayer.isSetupFormUICalled)
        XCTAssertTrue(displayer.isSetDisallowedCharacterForEMail)
    }
    
    func testSetProfileDataForLoggedInUser() {
        let category = SCModelDefectCategory(serviceCode: "serviceCode",
                                             serviceName: "serviceName",
                                             subCategories: [], description: nil)
        let subCategory = SCModelDefectSubCategory(serviceCode: "serviceCode", serviceName: "serviceSubName",
                                                   description: "", isAdditionalInfo: false)
        let mockAuth = SCAuthMock(loginState: true)
        let sut = prepareSut(category: category, subCategory: subCategory, auth: mockAuth)
        sut.setProfileData()
        XCTAssertNotNil(sut.profile)
    }
    
    func testDisplayError() {
        let category = SCModelDefectCategory(serviceCode: "serviceCode",
                                             serviceName: "serviceName",
                                             subCategories: [], description: nil)
        let sut = prepareSut(category: category)
        let displayer = SCDefectReporterFormViewDisplayer()
        display = displayer
        sut.setDisplay(displayer)
        sut.displayError(SCWorkerError.noInternet)
//        XCTAssertTrue(displayer.isShowErrorDialog)
    }
    
    func testTextFieldComponentDidChange() {
        let category = SCModelDefectCategory(serviceCode: "serviceCode",
                                             serviceName: "serviceName",
                                             subCategories: [], description: nil)
        let sut = prepareSut(category: category)
        let displayer = SCDefectReporterFormViewDisplayer()
        display = displayer
        sut.setDisplay(displayer)
        sut.textFieldComponentDidChange(for: .email)
        XCTAssertTrue(displayer.isHideErrorCalled)
        XCTAssertEqual(displayer.inputField, .email)
        XCTAssertEqual(displayer.sendButtonState, .normal)
    }
    
    func testIsErrorHandledTrue() {
        let category = SCModelDefectCategory(serviceCode: "serviceCode",
                                             serviceName: "serviceName",
                                             subCategories: [], description: nil)
        let sut = prepareSut(category: category)
        let displayer = SCDefectReporterFormViewDisplayer()
        display = displayer
        sut.setDisplay(displayer)
        let isErrorHandled = sut.isErrorHandled(SCWorkerErrorDetails.init(message: "", errorCode: "postalCode.validation.error"))
        XCTAssertTrue(isErrorHandled)
    }
    
    func testIsErrorHandledFalse() {
        let category = SCModelDefectCategory(serviceCode: "serviceCode",
                                             serviceName: "serviceName",
                                             subCategories: [], description: nil)
        let sut = prepareSut(category: category)
        let displayer = SCDefectReporterFormViewDisplayer()
        display = displayer
        sut.setDisplay(displayer)
        let isErrorHandled = sut.isErrorHandled(SCWorkerErrorDetails.init(message: "", errorCode: "error"))
        XCTAssertFalse(isErrorHandled)
    }
    
    func testViewDidLoad() {
        let category = SCModelDefectCategory(serviceCode: "serviceCode",
                                             serviceName: "serviceName",
                                             subCategories: [], description: nil)
        let sut = prepareSut(category: category)
        sut.manadatoryFields = [.email, .yourconcern]
        let displayer = SCDefectReporterFormViewDisplayer()
        display = displayer
        sut.setDisplay(displayer)
        sut.viewDidLoad()
        XCTAssertEqual(displayer.sendButtonState!, .normal)
    }
    
    func testViewDidAppear() {
        let category = SCModelDefectCategory(serviceCode: "serviceCode",
                                             serviceName: "serviceName",
                                             subCategories: [], description: nil)
        let sut = prepareSut(category: category)
        sut.manadatoryFields = [.email, .yourconcern]
        let displayer = SCDefectReporterFormViewDisplayer()
        display = displayer
        sut.setDisplay(displayer)
        sut.viewDidAppear()
        XCTAssertEqual(displayer.sendButtonState, .normal)
    }
    
    func testConfigureYourConcernField() {
        let category = SCModelDefectCategory(serviceCode: "serviceCode",
                                             serviceName: "serviceName",
                                             subCategories: [], description: nil)
        let sut = prepareSut(serviceData: getMockServiceData(),
                             category: category)
        _ = sut.configureField(SCTextViewComponent(), identifier: "sgtxtfldYourConcern", type: .yourconcern, autocapitalizationType: .none)
        XCTAssertEqual(sut.allFields[0], .yourconcern)
        XCTAssertEqual(sut.manadatoryFields[0], .yourconcern)
    }
    
    func testConfigureEmailField() {
        let category = SCModelDefectCategory(serviceCode: "serviceCode",
                                             serviceName: "serviceName",
                                             subCategories: [], description: nil)
        let sut = prepareSut(serviceData: getMockServiceData(),
                             category: category)
        _ = sut.configureField(SCTextViewComponent(), identifier: "sgtxtfldEmail", type: .email, autocapitalizationType: .none)
        XCTAssertEqual(sut.allFields[0], .email)
        XCTAssertEqual(sut.manadatoryFields[0], .email)
    }
    
    func testConfigureFirstNameField() {
        let category = SCModelDefectCategory(serviceCode: "serviceCode",
                                             serviceName: "serviceName",
                                             subCategories: [], description: nil)
        let sut = prepareSut(serviceData: getMockServiceData(),
                             category: category)
        _ = sut.configureField(SCTextViewComponent(), identifier: "sgtxtfldFirstName", type: .email, autocapitalizationType: .none)
        XCTAssertTrue(sut.allFields.isEmpty)
    }
    
    func testConfigureLastNameField() {
        let category = SCModelDefectCategory(serviceCode: "serviceCode",
                                             serviceName: "serviceName",
                                             subCategories: [], description: nil)
        let sut = prepareSut(serviceData: getMockServiceData(),
                             category: category)
        _ = sut.configureField(SCTextViewComponent(), identifier: "sgtxtfldLastName", type: .email, autocapitalizationType: .none)
        XCTAssertTrue(sut.allFields.isEmpty)
    }
}
