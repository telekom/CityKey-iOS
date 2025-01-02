//
//  SCDataPrivacyNoticeViewControllerTests.swift
//  OSCATests
//
//  Created by Bhaskar N S on 08/07/22.
//  Copyright © 2022 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import XCTest
@testable import OSCA
class SCDataPrivacyNoticeViewControllerTests: XCTestCase {

    private func prepareSut() -> SCDataPrivacyNoticeViewController {
        let storyboard = UIStoryboard(name: "DataPrivacyScreen", bundle: nil)
        let sut = storyboard.instantiateViewController(identifier: "SCDataPrivacyNoticeViewController") as! SCDataPrivacyNoticeViewController
        sut.presenter = SCDataPrivacyNoticePresenterMock()
        sut.loadViewIfNeeded()
        return sut
    }
    
    func testViewDidLoad() {
        let sut = prepareSut()
        sut.viewDidLoad()
        guard let presenter = sut.presenter as? SCDataPrivacyNoticePresenterMock else {
            XCTFail("Test Failed")
            return
        }
        XCTAssertTrue(presenter.isViewDidLoadCalled)
    }
    
    func testOnShowDPNClicked() {
        let sut = prepareSut()
        sut.viewDidLoad()
        sut.onShowDPNClicked("")
        guard let presenter = sut.presenter as? SCDataPrivacyNoticePresenterMock else {
            XCTFail("Test Failed")
            return
        }
        XCTAssertTrue(presenter.onShowNoticeClickedCalled)
        
    }
    
    func testOnAcceptClicked() {
        let sut = prepareSut()
        sut.viewDidLoad()
        sut.onAcceptClicked("")
        guard let presenter = sut.presenter as? SCDataPrivacyNoticePresenterMock else {
            XCTFail("Test Failed")
            return
        }
        XCTAssertTrue(presenter.onAccpetCalled)
    }
    
    func testResetAcceptButtonState() {
        let sut = prepareSut()
        sut.viewDidLoad()
        sut.resetAcceptButtonState()
        XCTAssertEqual(sut.okButton.btnState, .normal)
    }
    
    func testSetTitle() {
        let sut = prepareSut()
        sut.viewDidLoad()
        let title = LocalizationKeys.SCDataPrivacyNotice.dialogDpnUpdatedTitle.localized()
        sut.setTitle(title)
        XCTAssertEqual(sut.navigationItem.title, title)
    }

}
