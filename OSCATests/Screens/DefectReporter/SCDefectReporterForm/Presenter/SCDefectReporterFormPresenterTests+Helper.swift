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
//  SCDefectReporterFormPresenterTests+Helper.swift
//  OSCATests
//
//  Created by Bhaskar N S on 27/07/22.
//  Copyright © 2022 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import XCTest
@testable import OSCA

extension SCDefectReporterFormPresenterTests {
    func testSendReportBtnWasPressedSuceess() {
        let mockDefectStatus = "123"
        let mockDefectLocationDetails = LocationDetails(locationAddress: "", streetName: "",
                                                        houseNumber: "", postalCode: "")
        let category = SCModelDefectCategory(serviceCode: "serviceCode",
                                             serviceName: "serviceName",
                                             subCategories: [], description: nil)
        let sut = prepareSut(serviceData: getMockServiceData(),
                             category: category,
                             defectWorker: SCDefectReporterWorkerMock(submitDefectStatus: mockDefectStatus))
        let displayer = SCDefectReporterFormViewDisplayer()
        display = displayer
        sut.setDisplay(displayer)
        sut.manadatoryFields = [.yourconcern, .email]
        sut.allFields = [.yourconcern, .email]
        sut.termsAccepted = true
        sut.sendReportBtnWasPressed(defectLocation: mockDefectLocationDetails)
        XCTAssertTrue(displayer.isUpdateValidationState)
        XCTAssertTrue(displayer.isHideErrorCalled)
        XCTAssertEqual(displayer.sendButtonState, .disabled)
        XCTAssertTrue(displayer.isDismissKeyboardCalled)
    }
    
    func testSendReportBtnWasPressedFailure() {
        let mockError: SCWorkerError = SCWorkerError.fetchFailed(SCWorkerErrorDetails(message: "", errorCode: "service.inactive"))
        let mockDefectLocationDetails = LocationDetails(locationAddress: "", streetName: "",
                                                        houseNumber: "", postalCode: "")
        let category = SCModelDefectCategory(serviceCode: "serviceCode",
                                             serviceName: "serviceName",
                                             subCategories: [], description: nil)
        let sut = prepareSut(serviceData: getMockServiceData(),
                             category: category,
                             defectWorker: SCDefectReporterWorkerMock(error: mockError))
        let displayer = SCDefectReporterFormViewDisplayer()
        display = displayer
        sut.setDisplay(displayer)
        sut.manadatoryFields = [.yourconcern, .email]
        sut.allFields = [.yourconcern, .email]
        sut.termsAccepted = true
        sut.sendReportBtnWasPressed(defectLocation: mockDefectLocationDetails)
        XCTAssertTrue(displayer.isUpdateValidationState)
        XCTAssertTrue(displayer.isHideErrorCalled)
        XCTAssertEqual(displayer.sendButtonState, .normal)
        XCTAssertTrue(displayer.isDismissKeyboardCalled)
    }
    
    func testCloseWasPressed() {
        let category = SCModelDefectCategory(serviceCode: "serviceCode",
                                             serviceName: "serviceName",
                                             subCategories: [], description: nil)
        let sut = prepareSut(serviceData: getMockServiceData(),
                             category: category)
        let displayer = SCDefectReporterFormViewDisplayer()
        display = displayer
        sut.setDisplay(displayer)
        sut.closeWasPressed()
        XCTAssertTrue(displayer.isDismissCalled)
    }
    
    func testPresentTermsAndConditions() {
        let mockUrl = "https://www.leanact.de/agb-und-datenschutz/"
        let category = SCModelDefectCategory(serviceCode: "serviceCode",
                                             serviceName: "serviceName",
                                             subCategories: [], description: nil)
        let sut = prepareSut(serviceData: getMockServiceData(),
                             category: category)
        sut.presentTermsAndConditions()
        XCTAssertEqual(mockUrl, sut.serviceData.itemServiceParams?["dataPrivacyNoticeLink"])
    }
    
    func testUpdateSendReportBtnState() {
        let category = SCModelDefectCategory(serviceCode: "serviceCode",
                                             serviceName: "serviceName",
                                             subCategories: [], description: nil)
        let sut = prepareSut(serviceData: getMockServiceData(),
                             category: category)
        let displayer = SCDefectReporterFormViewDisplayer()
        display = displayer
        sut.setDisplay(displayer)
        sut.updateSendReportBtnState()
        XCTAssertEqual(displayer.sendButtonState, .normal)
    }
    
    func getMockServiceData(itemServiceParams: [String: String]? = nil) -> SCBaseComponentItem {
        let serviceParams = ["field_firstName": "OPTIONAL", "field_email": "REQUIRED", "field_checkBoxTerms2": "NOT REQUIRED", "field_lastName": "OPTIONAL", "dataPrivacyNoticeLink": "https://www.leanact.de/agb-und-datenschutz/", "field_uploadImage": "OPTIONAL", "field_yourConcern": "REQUIRED"]
        return SCBaseComponentItem(itemID: "186", itemTitle: "Defect Reporter", itemTeaser: nil, itemSubtitle: nil,
                            itemImageURL: SCImageURL(urlString: "/img/defect-reporter-img.png", persistence: false),
                            itemImageCredit: nil, itemThumbnailURL: nil, itemIconURL: SCImageURL(urlString: "/img/mangelmelder-icon.png", persistence: false),
                            itemURL: nil, itemDetail: "<html><body style=\"margin: 0; padding: 0\"><h3>Tell us!</h3> <p>With our defect report you can tell us if there are problems in our cityscape (wild garbage, noise pollution, wanton damage, etc.). Your concern will be processed by us as soon as possible. You help us to make our city more beautiful.</p> </body</html>",
                            itemHtmlDetail: true, itemCategoryTitle: Optional("My services"), itemColor: .black, itemCellType: OSCA.SCBaseComponentItemCellType.tiles_icon, itemLockedDueAuth: false, itemLockedDueResidence: false, itemIsNew: false, itemFunction: "mängelmelder",
                            itemBtnActions: nil,
                            itemContext: SCBaseComponentItemContext.none, badgeCount: nil,
                            itemServiceParams: itemServiceParams ?? serviceParams,
                            helpLinkTitle: nil, templateId: nil, headerImageURL: nil)
    }
    
    func testChangeLocationBtnWasPressed() {
        let category = SCModelDefectCategory(serviceCode: "serviceCode",
                                             serviceName: "serviceName",
                                             subCategories: [], description: nil)
        let sut = prepareSut(serviceData: getMockServiceData(),
                             category: category)
        let displayer = SCDefectReporterFormViewDisplayer()
        display = displayer
        sut.setDisplay(displayer)
        sut.changeLocationBtnWasPressed()
        XCTAssertTrue(displayer.isPresentCalled)
    }
    
    func testGetProfileData() {
        let category = SCModelDefectCategory(serviceCode: "serviceCode",
                                             serviceName: "serviceName",
                                             subCategories: [], description: nil)
        let subCategory = SCModelDefectSubCategory(serviceCode: "serviceCode", serviceName: "serviceSubName",
                                                   description: "", isAdditionalInfo: false)
        let mockAuth = SCAuthMock(loginState: true)
        let sut = prepareSut(category: category, subCategory: subCategory, auth: mockAuth)
        sut.setProfileData()
        XCTAssertNotNil(sut.getProfileData())
        XCTAssertNotNil(sut.profile)
    }
    
    func testGetProfileDataWithNil() {
        let category = SCModelDefectCategory(serviceCode: "serviceCode",
                                             serviceName: "serviceName",
                                             subCategories: [], description: nil)
        let subCategory = SCModelDefectSubCategory(serviceCode: "serviceCode", serviceName: "serviceSubName",
                                                   description: "", isAdditionalInfo: false)
        let mockAuth = SCAuthMock(loginState: false)
        let sut = prepareSut(category: category, subCategory: subCategory, auth: mockAuth)
        sut.setProfileData()
        XCTAssertNil(sut.getProfileData())
    }
}
