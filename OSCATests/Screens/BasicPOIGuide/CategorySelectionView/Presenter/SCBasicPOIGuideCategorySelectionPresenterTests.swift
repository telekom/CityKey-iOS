//
//  SCBasicPOIGuideCategorySelectionPresenterTests.swift
//  OSCATests
//
//  Created by Bhaskar N S on 29/05/24.
//  Copyright © 2024 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import XCTest
@testable import OSCA

final class SCBasicPOIGuideCategorySelectionPresenterTests: XCTestCase {
	weak var display: SCBasicPOIGuideDisplaying?
	
	private func prepareSut(poiCategory: [POICategoryInfo] = [],
													basicPOIGuideWorker: SCBasicPOIGuideWorker? = nil) -> SCBasicPOIGuideCategorySelectionPresenter {
		return SCBasicPOIGuideCategorySelectionPresenter(basicPOIGuideWorker: basicPOIGuideWorker ?? SCBasicPOIGuideWorker(requestFactory: SCRequestMock()),
																										 cityContentSharedWorker: SCCityContentSharedWorkerMock(),
																										 injector: MockSCInjector(), poiCategory: poiCategory)
	}
	
	func testViewDidLoadWithPOICategories() {
		let successResponseData = JsonReader().readJsonFrom(fileName: "CityPOICategories",
																												withExtension: "json")
		let poiGuideWorker = SCBasicPOIGuideWorker(requestFactory: SCRequestMock(successResponse: successResponseData))
		let sut = prepareSut(basicPOIGuideWorker: poiGuideWorker)
		let displayer = SCBasicPOIGuideDisplayer()
		sut.setDisplay(displayer)
		sut.viewDidLoad()
		XCTAssertTrue(displayer.isSetupUICalled)
		XCTAssertTrue(displayer.isShowPOICategoryMarkerCalled)
		XCTAssertTrue(displayer.isUpdateAllPOICategoryItemsCalled)
	}
	
	func testViewDidLoadWithZeroPOICategories() {
		let poiGuideWorker = SCBasicPOIGuideWorker(requestFactory: SCRequestMock())
		let sut = prepareSut(basicPOIGuideWorker: poiGuideWorker)
		let displayer = SCBasicPOIGuideDisplayer()
		sut.setDisplay(displayer)
		sut.viewDidLoad()
		XCTAssertTrue(displayer.isSetupUICalled)
		XCTAssertTrue(displayer.isShowOverlayWithGeneralErrorCalled)
	}
	
	func testViewWillAppear() {
		let successResponseData = JsonReader().readJsonFrom(fileName: "CityPOICategories",
																												withExtension: "json")
		let poiGuideWorker = SCBasicPOIGuideWorker(requestFactory: SCRequestMock(successResponse: successResponseData))
		let sut = prepareSut(basicPOIGuideWorker: poiGuideWorker)
		let displayer = SCBasicPOIGuideDisplayer()
		sut.setDisplay(displayer)
		sut.viewWillAppear()
		XCTAssertTrue(displayer.isShowPOICategoryMarkerCalled)
		XCTAssertTrue(displayer.isUpdateAllPOICategoryItemsCalled)
	}
	
	func testCategoryWasSelected() {
		let successResponseData = JsonReader().readJsonFrom(fileName: "CityPOI",
																												withExtension: "json")
		let poiGuideWorker = SCBasicPOIGuideWorker(requestFactory: SCRequestMock(successResponse: successResponseData))
		let sut = prepareSut(basicPOIGuideWorker: poiGuideWorker)
		let displayer = SCBasicPOIGuideDisplayer()
		sut.setDisplay(displayer)
		sut.viewDidLoad()
		sut.categoryWasSelected(categoryName: "6", categoryID: 10, categoryGroupIcon: "Family")
		let exp = expectation(description: "Test after 2 seconds")
		let result = XCTWaiter.wait(for: [exp], timeout: 2.0)
		if result == XCTWaiter.Result.timedOut {
			XCTAssertTrue(displayer.isDismissCalled)
		} else {
			XCTFail("Delay interrupted")
		}
	}
	
	func testCategoryWasSelectedWithError() {
		let errorResponse = SCRequestError.noInternet
		let poiGuideWorker = SCBasicPOIGuideWorker(requestFactory: SCRequestMock(successResponse: nil, errorResponse: .noInternet))
		let sut = prepareSut(basicPOIGuideWorker: poiGuideWorker)
		let displayer = SCBasicPOIGuideDisplayer()
		sut.setDisplay(displayer)
		sut.viewDidLoad()
		sut.categoryWasSelected(categoryName: "6", categoryID: 10, categoryGroupIcon: "Family")
		let exp = expectation(description: "Test after 2 seconds")
		let result = XCTWaiter.wait(for: [exp], timeout: 2.0)
		if result == XCTWaiter.Result.timedOut {
			XCTAssertTrue(displayer.isShowErrorCalled)
		} else {
			XCTFail("Delay interrupted")
		}
	}
	
	func testCloseButtonWasPressed() {
		let sut = prepareSut()
		let displayer = SCBasicPOIGuideDisplayer()
		sut.setDisplay(displayer)
		sut.viewDidLoad()
		sut.closeButtonWasPressed()
		XCTAssertTrue(displayer.isDismissCalled)
	}
	
	func testDidPressGeneralErrorRetryBtn() {
		let successResponseData = JsonReader().readJsonFrom(fileName: "CityPOICategories",
																												withExtension: "json")
		let poiGuideWorker = SCBasicPOIGuideWorker(requestFactory: SCRequestMock(successResponse: successResponseData))
		let sut = prepareSut(basicPOIGuideWorker: poiGuideWorker)
		let displayer = SCBasicPOIGuideDisplayer()
		sut.setDisplay(displayer)
		sut.viewDidLoad()
		sut.didPressGeneralErrorRetryBtn()
		let exp = expectation(description: "Test after 5 seconds")
		let result = XCTWaiter.wait(for: [exp], timeout: 7.0)
		if result == XCTWaiter.Result.timedOut {
			XCTAssertTrue(displayer.isShowOverlayWithActivityIndicatorCalled)
			XCTAssertTrue(displayer.isShowPOICategoryMarkerCalled)
			XCTAssertTrue(displayer.isUpdateAllPOICategoryItemsCalled)
		} else {
			XCTFail("Delay interrupted")
		}
	}
	
}

final class SCBasicPOIGuideDisplayer: SCBasicPOIGuideDisplaying {
	private(set) var isSetupUICalled: Bool = false
	private(set) var isUpdateAllPOICategoryItemsCalled: Bool = false
	private(set) var isShowPOICategoryMarkerCalled: Bool = false
	private(set) var isShowOverlayWithGeneralErrorCalled: Bool = false
	private(set) var isDismissCalled: Bool = false
	private(set) var isShowOverlayWithActivityIndicatorCalled: Bool = false
	private(set) var isShowErrorCalled: Bool = false
	
	func setupUI() {
		isSetupUICalled = true
	}
	
	func dismiss() {
		isDismissCalled = true
	}
	
	func dismissCategory() {
		
	}
	
	func updateAllPOICategoryItems(with categoryItems: [OSCA.POICategoryInfo]) {
		isUpdateAllPOICategoryItemsCalled = true
	}
	
	func showPOICategoryActivityIndicator(for categoryName: String) {
		
	}
	
	func hidePOICategoryActivityIndicator() {
		
	}
	
	func showLocationFailedMessage(messageTitle: String, withMessage: String) {
		
	}
	
	func showPOICategoryMarker(for categoryName: String, color: UIColor) {
		isShowPOICategoryMarkerCalled = true
	}
	
	func showOverlayWithActivityIndicator() {
		isShowOverlayWithActivityIndicatorCalled = true
	}
	
	func showOverlayWithGeneralError() {
		isShowOverlayWithGeneralErrorCalled = true
	}
	
	func hideOverlay() {
		
	}
	
	func showErrorDialog(_ error: SCWorkerError, retryHandler : (() -> Void)?, showCancelButton: Bool?, additionalButtonTitle: String?, additionButtonHandler: (() -> Void)?) {
		isShowErrorCalled = true
	}
}

