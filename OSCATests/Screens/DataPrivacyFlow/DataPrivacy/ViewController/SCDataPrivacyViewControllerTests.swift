//
//  SCDataPrivacyViewControllerTests.swift
//  OSCATests
//
//  Created by Bhaskar N S on 08/07/22.
//  Copyright © 2022 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import XCTest
@testable import OSCA
class SCDataPrivacyViewControllerTests: XCTestCase {

    private func prepareSut() -> SCDataPrivacyViewController {
        let storyboard = UIStoryboard(name: "DataPrivacyScreen", bundle: nil)
        let sut = storyboard.instantiateViewController(identifier: "SCDataPrivacyViewController") as! SCDataPrivacyViewController
        sut.presenter = SCDataPrivacyPresenterMock()
        sut.loadViewIfNeeded()
        return sut
    }
    
    func testViewDidLoad() {
        let sut = prepareSut()
        sut.viewDidLoad()
        guard let presenter = sut.presenter as? SCDataPrivacyPresenterMock else {
            XCTFail("Test Failed")
            return
        }
        XCTAssertTrue(presenter.isViewDidLoadCalled)
    }
    
    func testCloseBtnWasPressed() {
        let sut = prepareSut()
        sut.viewDidLoad()
        sut.closeBtnWasPressed("")
        guard let presenter = sut.presenter as? SCDataPrivacyPresenterMock else {
            XCTFail("Test Failed")
            return
        }
        XCTAssertTrue(presenter.isCloseCalled)
    }
    
    func testSettingsButtonPressed() {
        let sut = prepareSut()
        sut.viewDidLoad()
        sut.settingsButtonPressed("")
        guard let presenter = sut.presenter as? SCDataPrivacyPresenterMock else {
            XCTFail("Test Failed")
            return
        }
        XCTAssertTrue(presenter.isSettingsBtnCalled)
    }

}
