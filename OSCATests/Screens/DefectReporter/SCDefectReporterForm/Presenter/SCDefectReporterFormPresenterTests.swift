//
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
