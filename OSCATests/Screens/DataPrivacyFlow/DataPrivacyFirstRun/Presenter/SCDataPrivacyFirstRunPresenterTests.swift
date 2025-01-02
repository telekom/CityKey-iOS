//
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
