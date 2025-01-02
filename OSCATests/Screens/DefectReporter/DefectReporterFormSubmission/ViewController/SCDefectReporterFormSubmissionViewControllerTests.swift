//
//  SCDefectReporterFormSubmissionViewControllerTests.swift
//  OSCATests
//
//  Created by Bhaskar N S on 26/07/22.
//  Copyright © 2022 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import XCTest
@testable import OSCA

class SCDefectReporterFormSubmissionViewControllerTests: XCTestCase {
    private func prepareSut(presenter: SCDefectReporterFormSubmissionPresenting? = nil) -> SCDefectReporterFormSubmissionViewController {
        let storyboard = UIStoryboard(name: "DefectReporter", bundle: nil)
        let sut = storyboard.instantiateViewController(identifier: "SCDefectReporterFormSubmissionViewController") as! SCDefectReporterFormSubmissionViewController
        sut.presenter = presenter ?? SCDefectReporterFormSubmissionPresenterMock()
        sut.loadViewIfNeeded()
        return sut
    }
    
    func testViewDidLoad() {
        let presenter = SCDefectReporterFormSubmissionPresenterMock()
        let sut = prepareSut(presenter: presenter)
        sut.viewDidLoad()
        guard let presenter = sut.presenter as? SCDefectReporterFormSubmissionPresenterMock else {
            XCTFail("Test Failed")
            return
        }
        XCTAssertTrue(presenter.isViewDidLoadCalled)
    }
    
    func testOkBtnWasPressed() {
        let presenter = SCDefectReporterFormSubmissionPresenterMock()
        let sut = prepareSut(presenter: presenter)
        sut.okBtnWasPressed(UIButton())
        guard let presenter = sut.presenter as? SCDefectReporterFormSubmissionPresenterMock else {
            XCTFail("Test Failed")
            return
        }
        XCTAssertTrue(presenter.isOkBtnWasPressedCalled)
    }
    
    func testSetupUI() {
        let subCategory = SCModelDefectSubCategory(serviceCode: "subServiceCode",
                                                     serviceName: "subServiceName",
                                                     description: "",
                                                     isAdditionalInfo: false)
        let category = SCModelDefectCategory(serviceCode: "serviceCode",
                                             serviceName: "serviceName",
                                             subCategories: [SCModelDefectSubCategory(serviceCode: "",
                                                                                      serviceName: "",
                                                                                      description: "",
                                                                                      isAdditionalInfo: false)],
                                             description: nil)
        let uniqueId = "123"
        let presenter = SCDefectReporterFormSubmissionPresenterMock()
        let sut = prepareSut(presenter: presenter)
        sut.setupUI(category: category, subCategory: subCategory, uniqueId: uniqueId)
        XCTAssertEqual(sut.thankYouLabel?.text, LocalizationKeys.SCDefectReporterFormSubmissionVC.dr004ThankYouMsg.localized())
        XCTAssertEqual(sut.thankYouInfoLabel?.text, LocalizationKeys.SCDefectReporterFormSubmissionVC.dr004ThankYouMsg1.localized().replacingOccurrences(of: "%s", with: presenter.getCityName()!))
        XCTAssertEqual(sut.categoryTitleLabel?.text, LocalizationKeys.SCDefectReporterFormSubmissionVC.dr004CategoryLabel.localized())
        XCTAssertEqual(sut.uniqueIdTitleLabel.text, LocalizationKeys.SCDefectReporterFormSubmissionVC.dr004UniqueIdLabel.localized())
        XCTAssertEqual(sut.uniqueIdLabel.text, uniqueId)
        XCTAssertEqual(sut.reportedOnTitleLabel.text, LocalizationKeys.SCDefectReporterFormSubmissionVC.d004ReportedOnLabel.localized())
        XCTAssertEqual(sut.reportedOnLabel.text, defectReportStringFromDate(date: Date()))
        XCTAssertEqual(sut.feedbackLabel.text, LocalizationKeys.SCDefectReporterFormSubmissionVC.d004SubmitInfoMsg.localized())
        XCTAssertEqual(sut.okBtn.titleLabel?.text, LocalizationKeys.SCDefectReporterFormSubmissionVC.dr004OkButton.localized())
        XCTAssertFalse(sut.uniqueIdStackView.isHidden)
    }
    
    func testsetNavigation() {
        let backBtnTitle = LocalizationKeys.Common.navigationBarBack.localized()
        let presenter = SCDefectReporterFormSubmissionPresenterMock()
        let sut = prepareSut(presenter: presenter)
        sut.setNavigation(title: "Nav Title")
        XCTAssertEqual(sut.navigationItem.title, "Nav Title")
        XCTAssertEqual(sut.navigationItem.backButtonTitle, backBtnTitle)
        
    }

}
