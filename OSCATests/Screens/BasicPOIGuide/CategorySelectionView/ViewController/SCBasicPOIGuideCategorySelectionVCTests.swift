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
