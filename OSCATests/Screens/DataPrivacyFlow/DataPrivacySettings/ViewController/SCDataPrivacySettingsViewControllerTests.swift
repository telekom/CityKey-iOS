//
//  SCDataPrivacySettingsViewControllerTests.swift
//  OSCATests
//
//  Created by Bhaskar N S on 08/07/22.
//  Copyright © 2022 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import XCTest
@testable import OSCA

class SCDataPrivacySettingsViewControllerTests: XCTestCase {
    
    private func prepareSut() -> SCDataPrivacySettingsViewController {
        let storyboard = UIStoryboard(name: "DataPrivacyScreen", bundle: nil)
        let sut = storyboard.instantiateViewController(identifier: "SCDataPrivacySettingsViewController") as! SCDataPrivacySettingsViewController
        sut.presenter = SCDataPrivacySettingsPresenterMock()
        sut.loadViewIfNeeded()
        return sut
    }
    
    func testViewDidLoad() {
        let sut = prepareSut()
        sut.viewDidLoad()
        guard let presenter = sut.presenter as? SCDataPrivacySettingsPresenterMock else {
            XCTFail("Test Failed")
            return
        }
        XCTAssertTrue(presenter.isViewDidLoadCalled)
    }
    
    func testAcceptAllClicked() {
        let sut = prepareSut()
        sut.viewDidLoad()
        sut.acceptAllClicked("")
        guard let presenter = sut.presenter as? SCDataPrivacySettingsPresenterMock else {
            XCTFail("Test Failed")
            return
        }
        XCTAssertTrue(presenter.acceptAllCalled)
    }
    
    func testAcceptSelectedClicked() {
        let sut = prepareSut()
        sut.viewDidLoad()
        sut.acceptSelectedClicked("")
        guard let presenter = sut.presenter as? SCDataPrivacySettingsPresenterMock else {
            XCTFail("Test Failed")
            return
        }
        XCTAssertTrue(presenter.acceptSelectedCalled)
    }
    
    func testDataPrivacyNoticeLinkClicked() {
        let sut = prepareSut()
        sut.viewDidLoad()
        sut.dataPrivacyNoticeLinkClicked("")
        guard let presenter = sut.presenter as? SCDataPrivacySettingsPresenterMock else {
            XCTFail("Test Failed")
            return
        }
        XCTAssertTrue(presenter.dataPrivacyLinkCalled)
    }

}

class SCDataPrivacySettingsPresenterMock: SCDataPrivacySettingsPresenting {
    private(set) var isViewDidLoadCalled: Bool = false
    private(set) var acceptAllCalled: Bool = false
    private(set) var acceptSelectedCalled: Bool = false
    private(set) var dataPrivacyLinkCalled: Bool = false
    var completionHandler: (() -> Void)?
    
    func setDisplay(_ display: SCDataPrivacySettingsDisplay) {
        
    }
    
    func backButtonPressed() {
        
    }
    
    func dataPrivacyLinkPressed() {
        dataPrivacyLinkCalled = true
    }
    
    func acceptAllPressed() {
        acceptAllCalled = true
    }
    
    func acceptSelectedPressed(adjustSwitchStatus: Bool) {
        acceptSelectedCalled = true
    }
    
    func viewDidLoad() {
        isViewDidLoadCalled = true
    }
}
