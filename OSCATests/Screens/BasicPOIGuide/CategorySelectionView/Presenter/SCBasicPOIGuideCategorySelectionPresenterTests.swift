/*
Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    https://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
 
In accordance with Sections 4 and 6 of the License, the following exclusions apply:

    1. Trademarks & Logos – The names, logos, and trademarks of the Licensor are not covered by this License and may not be used without separate permission.
    2. Design Rights – Visual identities, UI/UX designs, and other graphical elements remain the property of their respective owners and are not licensed under the Apache License 2.0.
    3: Non-Coded Copyrights – Documentation, images, videos, and other non-software materials require separate authorization for use, modification, or distribution.

These elements are not considered part of the licensed Work or Derivative Works unless explicitly agreed otherwise. All elements must be altered, removed, or replaced before use or distribution. All rights to these materials are reserved, and Contributor accepts no liability for any infringing use. By using this repository, you agree to indemnify and hold harmless Contributor against any claims, costs, or damages arising from your use of the excluded elements.

SPDX-FileCopyrightText: 2025 Deutsche Telekom AG
SPDX-License-Identifier: Apache-2.0 AND LicenseRef-Deutsche-Telekom-Brand
License-Filename: LICENSES/Apache-2.0.txt LICENSES/LicenseRef-Deutsche-Telekom-Brand.txt
*///
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

