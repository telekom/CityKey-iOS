//
//  SCDataPrivacyFirstRunViewControllerTests.swift
//  OSCATests
//
//  Created by Bhaskar N S on 11/07/22.
//  Copyright © 2022 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import XCTest
@testable import OSCA
class SCDataPrivacyFirstRunViewControllerTests: XCTestCase {
    private func prepareSut() -> SCDataPrivacyFirstRunViewController {
        let storyboard = UIStoryboard(name: "DataPrivacyScreen", bundle: nil)
        let sut = storyboard.instantiateViewController(identifier: "SCDataPrivacyFirstRunViewController") as! SCDataPrivacyFirstRunViewController
        sut.presenter = SCDataPrivacyFirstRunPresenterMock()
        sut.loadViewIfNeeded()
        return sut
    }

    func testViewDidLoad() {
        let sut = prepareSut()
        sut.viewDidLoad()
        guard let presenter = sut.presenter as? SCDataPrivacyFirstRunPresenterMock else {
            XCTFail("Test Failed")
            return
        }
        XCTAssertTrue(presenter.isViewDidLoadCalled)
    }
    
    func testChangeSettingsClicked() {
        let sut = prepareSut()
        sut.viewDidLoad()
        sut.changeSettingsClicked("")
        guard let presenter = sut.presenter as? SCDataPrivacyFirstRunPresenterMock else {
            XCTFail("Test Failed")
            return
        }
        XCTAssertTrue(presenter.isChangeSettingsPressed)
    }
    
    func testAcceptAllClicked() {
        let sut = prepareSut()
        sut.viewDidLoad()
        sut.acceptAllClicked("")
        guard let presenter = sut.presenter as? SCDataPrivacyFirstRunPresenterMock else {
            XCTFail("Test Failed")
            return
        }
        XCTAssertTrue(presenter.isAcceptAllPressed)
    }
}
