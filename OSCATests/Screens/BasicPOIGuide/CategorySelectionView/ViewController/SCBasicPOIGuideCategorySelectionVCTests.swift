//
//  SCBasicPOIGuideCategorySelectionVCTests.swift
//  OSCATests
//
//  Created by Bhaskar N S on 03/06/24.
//  Copyright © 2024 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import XCTest
@testable import OSCA

final class SCBasicPOIGuideCategorySelectionVCTests: XCTestCase {

	private func prepareSut(presenter: SCBasicPOIGuidePresenting? = nil) -> SCBasicPOIGuideCategorySelectionVC {
		let storyboard = UIStoryboard(name: "BasicPOIGuide", bundle: nil)
		let sut = storyboard.instantiateViewController(identifier: "SCBasicPOIGuideCategorySelectionVC") as! SCBasicPOIGuideCategorySelectionVC
		sut.presenter = presenter ?? SCBasicPOIGuidePresenterMock()
		sut.loadViewIfNeeded()
		return sut
	}
	
	func testViewDidLoad()  {
		let presenter = SCBasicPOIGuidePresenterMock()
		let sut = prepareSut(presenter: presenter)
		sut.viewDidLoad()
		XCTAssertTrue(presenter.isViewDidLoadCalled)
	}
	
	func testViewWillAppear()  {
		let presenter = SCBasicPOIGuidePresenterMock()
		let sut = prepareSut(presenter: presenter)
		sut.viewWillAppear(true)
		XCTAssertTrue(presenter.isViewWillLoadCalled)
	}
	
	func testSetupUI()  {
		let presenter = SCBasicPOIGuidePresenterMock()
		let sut = prepareSut(presenter: presenter)
		let mockNavTitle = "poi_002_title".localized()
		let mockErrorLblText = "poi_002_error_text".localized()
		let retryBtnTitle = " " + "e_002_page_load_retry".localized()
		sut.setupUI()
		XCTAssertEqual(sut.navigationItem.title, mockNavTitle)
		XCTAssertEqual(sut.errorLabel.text, mockErrorLblText)
		XCTAssertEqual(sut.retryButton.titleLabel?.text, retryBtnTitle)
	}
	
	func testShowOverlayWithActivityIndicator() {
		let presenter = SCBasicPOIGuidePresenterMock()
		let sut = prepareSut(presenter: presenter)
		sut.showOverlayWithActivityIndicator()
		XCTAssertFalse(sut.activityIndicator.isHidden)
		XCTAssertFalse(sut.overlayView.isHidden)
		XCTAssertTrue(sut.errorLabel.isHidden)
		XCTAssertTrue(sut.retryButton.isHidden)
	}
	
	func testShowOverlayWithGeneralError() {
		let presenter = SCBasicPOIGuidePresenterMock()
		let sut = prepareSut(presenter: presenter)
		sut.showOverlayWithGeneralError()
		XCTAssertTrue(sut.activityIndicator.isHidden)
		XCTAssertFalse(sut.errorLabel.isHidden)
		XCTAssertFalse(sut.retryButton.isHidden)
		XCTAssertFalse(sut.overlayView.isHidden)
	}
	
	func testHideOverlay() {
		let presenter = SCBasicPOIGuidePresenterMock()
		let sut = prepareSut(presenter: presenter)
		sut.hideOverlay()
		XCTAssertTrue(sut.overlayView.isHidden)
	}
	

}

final class SCBasicPOIGuidePresenterMock: SCBasicPOIGuidePresenting {
	private(set) var isViewDidLoadCalled: Bool = false
	private(set) var isViewWillLoadCalled: Bool = false
	
	func viewDidLoad() {
		isViewDidLoadCalled = true
	}
	
	func viewWillAppear() {
		isViewWillLoadCalled = true
	}
	
	func setDisplay(_ display: OSCA.SCBasicPOIGuideDisplaying) {
		
	}
	
	func categoryWasSelected(categoryName: String, categoryID: Int, categoryGroupIcon: String) {
		
	}
	
	func closeButtonWasPressed() {
		
	}
	
	func didPressGeneralErrorRetryBtn() {
		
	}
}
