//
//  SCCitizenSurveyDataPrivacyViewControllerTests.swift
//  OSCATests
//
//  Created by Bhaskar N S on 19/09/22.
//  Copyright © 2022 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import XCTest
@testable import OSCA

final class SCCitizenSurveyDataPrivacyViewControllerTests: XCTestCase {
    private func prepareSut(presenter: SCCitizenSurveyDataPrivacyPresenting? = nil) -> SCCitizenSurveyDataPrivacyViewController {
        let storyboard = UIStoryboard(name: "CitizenSurvey", bundle: nil)
        let sut = storyboard.instantiateViewController(identifier: "SCCitizenSurveyDataPrivacyViewController") as! SCCitizenSurveyDataPrivacyViewController
        sut.presenter = presenter ?? SCCitizenSurveyDataPrivacyPresenterMock()
        sut.loadViewIfNeeded()
        return sut
    }
    
    func testViewDidLoad() {
        let mockTitle = LocalizationKeys.SCCitizenSurveyDataPrivacyViewController.dataPrivacySurveyTitle.localized()
        let mockBtnTitle = LocalizationKeys.SCCitizenSurveyDataPrivacyViewController.dataPrivacySurveyButtonText.localized()
        let sut = prepareSut()
        sut.viewDidLoad()
        XCTAssertEqual(sut.title, mockTitle)
        XCTAssertEqual(sut.dataPrivacyAcceptButton.titleLabel?.text, mockBtnTitle)
    }
    
    func testDidTapOnAccept() {
        let sut = prepareSut()
        sut.didTapOnAccept(UIButton())
        guard let presenter = sut.presenter as? SCCitizenSurveyDataPrivacyPresenterMock else {
            return
        }
        XCTAssertTrue(presenter.isSetDataPrivacyAccepted)
    }
}

class SCCitizenSurveyDataPrivacyPresenterMock: SCCitizenSurveyDataPrivacyPresenting {
    private(set) var isSetDataPrivacyAccepted: Bool = false
    func setDataPrivacyAccepted() {
        isSetDataPrivacyAccepted = true
    }
    
    func informDataPrivacyAccepted() {
        
    }
    
    func getDataPrivacyContent() -> NSMutableAttributedString? {
        return nil
    }
}
