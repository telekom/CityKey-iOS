//
//  SCDefectReporterLocationViewControllerTests.swift
//  OSCATests
//
//  Created by Bhaskar N S on 22/07/22.
//  Copyright © 2022 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import XCTest
@testable import OSCA
class SCDefectReporterLocationViewControllerTests: XCTestCase {

    private func prepareSut(serviceFlow: Services = .defectReporter) -> SCDefectReporterLocationViewController {
        let storyboard = UIStoryboard(name: "DefectReporter", bundle: nil)
        let sut = storyboard.instantiateViewController(identifier: "SCDefectReporterLocationViewController") as! SCDefectReporterLocationViewController
        sut.presenter = SCDefectReporterLocationPresenterMock(serviceFlow: serviceFlow)
        sut.loadViewIfNeeded()
        sut.viewDidLoad()
        sut.viewWillAppear(true)
        return sut
    }
    
    func testViewDidLoad() {
        let mockNavTitle = LocalizationKeys.SCDefectReporterLocationViewController.dr002LocationSelectionToolbarLabel.localized()
        let backBtnTitle = LocalizationKeys.Common.navigationBarBack.localized()
        let mockLocationInfoLabel = LocalizationKeys.SCDefectReporterLocationViewController.dr003LocationPageInfo1.localized().applyHyphenation()
        let sut = prepareSut()
        sut.viewDidLoad()
        guard let presenter = sut.presenter as? SCDefectReporterLocationPresenterMock else {
            XCTFail("Test Failed")
            return
        }
        XCTAssertTrue(presenter.isViewDidLoadCalled)
        XCTAssertEqual(sut.navigationItem.title, mockNavTitle)
        XCTAssertEqual(sut.navigationItem.backButtonTitle, backBtnTitle)
        XCTAssertEqual(sut.locationInfoLabel.attributedText, mockLocationInfoLabel)
    }
    
    func testViewWillAppear() {
        let sut = prepareSut()
        sut.viewWillAppear(true)
        guard let presenter = sut.presenter as? SCDefectReporterLocationPresenterMock else {
            XCTFail("Test Failed")
            return
        }
        XCTAssertTrue(presenter.isViewWillLoadCalled)
    }
    
    func testSavePositionBtnWasPressed() {
        let sut = prepareSut()
        sut.savePositionBtnWasPressed(UIButton())
        guard let presenter = sut.presenter as? SCDefectReporterLocationPresenterMock else {
            XCTFail("Test Failed")
            return
        }
        XCTAssertTrue(presenter.isSaveLocationCalled)
    }
    
    func testCloseBtnWasPressed() {
        let sut = prepareSut()
        sut.closeBtnWasPressed(UIButton())
        guard let presenter = sut.presenter as? SCDefectReporterLocationPresenterMock else {
            XCTFail("Test Failed")
            return
        }
        XCTAssertTrue(presenter.isCloseButtonCalled)
    }
}
