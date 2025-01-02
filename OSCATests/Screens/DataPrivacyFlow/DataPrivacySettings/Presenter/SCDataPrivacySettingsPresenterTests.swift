//
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
