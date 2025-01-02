//
//  SCCityImprintViewControllerTests.swift
//  OSCATests
//
//  Created by Bhaskar N S on 15/09/22.
//  Copyright © 2022 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import XCTest
@testable import OSCA

final class SCCityImprintViewControllerTests: XCTestCase {

    private func prepareSut(presenter: SCCityImprintPresenting? = nil) -> SCCityImprintViewController {
        let storyboard = UIStoryboard(name: "CityImprintScreen", bundle: nil)
        let sut = storyboard.instantiateViewController(identifier: "SCCityImprintViewController") as! SCCityImprintViewController
        sut.presenter = presenter ?? SCCityImprintPresenterMock()
        sut.loadViewIfNeeded()
        return sut
    }
    
    func testViewDidLoad() {
        let sut = prepareSut()
        sut.viewDidLoad()
        guard let presenter = sut.presenter as? SCCityImprintPresenterMock else {
            XCTFail("Test Failed")
            return
        }
        XCTAssertTrue(presenter.isViewLoaded)
    }
    
    func testViewWillAppear() {
        let sut = prepareSut()
        sut.viewWillAppear(true)
        guard let presenter = sut.presenter as? SCCityImprintPresenterMock else {
            XCTFail("Test Failed")
            return
        }
        XCTAssertTrue(presenter.isViewWillAppearCalled)
    }
    
    func testViewDidAppear() {
        let mockBannerText = LocalizationKeys.AppPreviewUI.h001HomeAppPreviewBannerText.localized()
        let sut = prepareSut()
        sut.viewDidAppear(true)
        guard let presenter = sut.presenter as? SCCityImprintPresenterMock else {
            XCTFail("Test Failed")
            return
        }
        XCTAssertNotNil(presenter.isViewDidAppearCalled)
        XCTAssertEqual(sut.appPreviewBannerLabel.text, mockBannerText)
    }
    
    func testBarBtnGeoLocationWasPressed() {
        let mockBannerText = LocalizationKeys.AppPreviewUI.h001HomeAppPreviewBannerText.localized()
        let sut = prepareSut()
        sut.viewDidLoad()
        sut.barBtnGeoLocationWasPressed(UIButton())
        guard let presenter = sut.presenter as? SCCityImprintPresenterMock else {
            XCTFail("Test Failed")
            return
        }
        XCTAssertTrue(presenter.isLocationButtonWasPressed)
    }
    
    func testBarBtnProfilenWasPressed() {
        let mockBannerText = LocalizationKeys.AppPreviewUI.h001HomeAppPreviewBannerText.localized()
        let sut = prepareSut()
        sut.viewDidLoad()
        sut.barBtnProfilenWasPressed(UIButton())
        guard let presenter = sut.presenter as? SCCityImprintPresenterMock else {
            XCTFail("Test Failed")
            return
        }
        XCTAssertTrue(presenter.isProfileButtonWasPreesed)
    }
    
    func testOpenCityImprintBtnWasPressed() {
        let mockBannerText = LocalizationKeys.AppPreviewUI.h001HomeAppPreviewBannerText.localized()
        let sut = prepareSut()
        sut.viewDidLoad()
        sut.openCityImprintBtnWasPressed(UIButton())
        guard let presenter = sut.presenter as? SCCityImprintPresenterMock else {
            XCTFail("Test Failed")
            return
        }
        XCTAssertTrue(presenter.isImprintButtonWasPressed)
    }
    
    func testSetupUI() {
        let mockNavTitle = LocalizationKeys.CitykeyImprint.h001NavigationBarBtnImprint.localized()
        let headerTitle = LocalizationKeys.CitykeyImprint.h001NavigationBarBtnImprint.localized()
        let btnTitle = LocalizationKeys.CitykeyImprint.ci001ButtonText.localized()
        let sut = prepareSut()
        sut.viewDidLoad()
        sut.setupUI()
        XCTAssertEqual(sut.navigationItem.title, mockNavTitle)
        XCTAssertEqual(sut.headerTitleLabel.text, headerTitle)
        XCTAssertEqual(sut.cityImprintBtn.titleLabel?.text, btnTitle)
    }
    
    func testUpdateCityName() {
        let sut = prepareSut()
        sut.viewDidLoad()
        sut.updateCityName("Bad Honnef")
        XCTAssertEqual(sut.headerDetailLabel.text, "Bad Honnef")
    }

    func testUpdateImprintDesc() {
        let desc = "Imprint description"
        let sut = prepareSut()
        sut.viewDidLoad()
        sut.updateImprintDesc(desc)
        XCTAssertNotNil(sut.contentDetail.text)
    }
}

class SCCityImprintPresenterMock: SCCityImprintPresenting {
    private(set) var isViewLoaded: Bool = false
    private(set) var isViewWillAppearCalled: Bool = false
    private(set) var isViewDidAppearCalled: Bool = false
    var mandatoryFields: [SCDefectReporterInputFields] = []
    private(set) var isLocationButtonWasPressed: Bool = false
    private(set) var isProfileButtonWasPreesed: Bool = false
    private(set) var isImprintButtonWasPressed: Bool = false
    
    func viewDidLoad() {
        isViewLoaded = true
    }
    
    func viewWillAppear() {
        isViewWillAppearCalled = true
    }
    
    func viewDidAppear() {
        isViewDidAppearCalled = true
    }
    
    func setDisplay(_ display: OSCA.SCCityImprintDisplaying) {
        
    }
    
    func locationButtonWasPressed() {
        isLocationButtonWasPressed = true
    }
    
    func profileButtonWasPressed() {
        isProfileButtonWasPreesed = true
    }
    
    func imprintButtonWasPressed() {
        isImprintButtonWasPressed = true
    }
}
