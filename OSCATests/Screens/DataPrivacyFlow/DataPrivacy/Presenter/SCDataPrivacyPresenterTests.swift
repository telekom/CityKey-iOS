//
//  SCDataPrivacyPresenterTests.swift
//  OSCATests
//
//  Created by Bhaskar N S on 08/07/22.
//  Copyright © 2022 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import XCTest
@testable import OSCA

class SCDataPrivacyPresenterTests: XCTestCase {
    private var display: SCDataPrivacyDisplaying?
    private func prepareSut(showCloseBtn: Bool = false,
                            preventSwipeToDismiss: Bool = false,
                            shouldPushSettingsController: Bool = false,
                            appContentSharedWorker: SCAppContentSharedWorking = SCAppContentSharedWorker(requestFactory: SCRequestMock())) -> SCDataPrivacyPresenter {
        let presenter = SCDataPrivacyPresenter(appContentSharedWorker: appContentSharedWorker,
                                               injector: MockSCInjector(),
                                               showCloseBtn: showCloseBtn,
                                               preventSwipeToDismiss: preventSwipeToDismiss,
                                               shouldPushSettingsController: shouldPushSettingsController)
        return presenter
    }
    
    func testViewDidLoad() {
        let mockTitle = LocalizationKeys.SCDataPrivacy.x001WelcomeBtnPrivacyShort.localized().localized()
        let sut = prepareSut()
        let displayer = SCDataPrivacyDisplayer()
        sut.setDisplay(displayer)
        sut.viewDidLoad()
        XCTAssertTrue(displayer.isSetupCalled)
        XCTAssertEqual(mockTitle, displayer.title)
    }
    
    func testCloseBtnWasPressed() {
        let sut = prepareSut()
        let displayer = SCDataPrivacyDisplayer()
        sut.setDisplay(displayer)
        sut.closeBtnWasPressed()
        XCTAssertTrue(displayer.isDismissCalled)
    }
    
    func testSaveBtnWasPressed() {
        let sut = prepareSut()
        let displayer = SCDataPrivacyDisplayer()
        sut.setDisplay(displayer)
        sut.saveBtnWasPressed()
        XCTAssertTrue(displayer.isDismissCalled)
    }
    
    func testSettingsButtonPressedWithShouldPushSettingController() {
        let sut = prepareSut(shouldPushSettingsController: true)
        let displayer = SCDataPrivacyDisplayer()
        sut.setDisplay(displayer)
        sut.settingsButtonPressed()
        XCTAssertTrue(displayer.isPushCalled)
    }
    
    func testSettingsButtonPressedWithoutShouldPushSettingController() {
        let sut = prepareSut()
        let displayer = SCDataPrivacyDisplayer()
        sut.setDisplay(displayer)
        sut.settingsButtonPressed()
        XCTAssertTrue(displayer.isPopCalled)
    }
    
    func testPrepareAndRefreshUI() {
        let sut = prepareSut()
        let displayer = SCDataPrivacyDisplayer()
        sut.setDisplay(displayer)
        sut.prepareAndRefreshUI()
        XCTAssertTrue(displayer.isSetupCalled)
    }
}

class SCDataPrivacyDisplayer: SCDataPrivacyDisplaying {
    private(set) var isSetupCalled: Bool = false
    private(set) var title: String = ""
    private(set) var isDismissCalled: Bool = false
    private(set) var isPushCalled: Bool = false
    private(set) var isPopCalled: Bool = false
    func setupUI(title: String, showCloseBtn: Bool, topText: String, bottomText: String, displayActIndicator: Bool, appVersion: String?) {
        isSetupCalled = true
        self.title = title
    }
    
    func preventSwipeToDismiss() {
        
    }
    
    func dismiss() {
        isDismissCalled = true
    }
    
    func push(_ viewController: UIViewController) {
        isPushCalled = true
    }
    
    func popViewController() {
        isPopCalled = true
    }
}
