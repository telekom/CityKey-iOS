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
//  SCBasicPOIGuideListMapFilterViewControllerTests.swift
//  OSCATests
//
//  Created by Bhaskar N S on 05/06/24.
//  Copyright © 2024 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import XCTest
import CoreLocation
@testable import OSCA

final class SCBasicPOIGuideListMapFilterViewControllerTests: XCTestCase {
	
	private func prepareSut(presenter: SCBasicPOIGuideListMapFilterPresenting? = nil) -> SCBasicPOIGuideListMapFilterViewController {
		let storyboard = UIStoryboard(name: "BasicPOIGuide", bundle: nil)
		let sut = storyboard.instantiateViewController(identifier: "SCBasicPOIGuideListMapFilterViewController") as! SCBasicPOIGuideListMapFilterViewController
		sut.presenter = presenter ?? SCBasicPOIGuideListMapFilterPresenterMock()
		sut.loadViewIfNeeded()
		return sut
	}
	
	func testViewDidLoad() {
		let sut = prepareSut()
		sut.viewDidLoad()
		guard let presenter = sut.presenter as? SCBasicPOIGuideListMapFilterPresenterMock else {
			XCTFail("Test failed")
			return
		}
		XCTAssertTrue(presenter.isViewLoaded)
		XCTAssertEqual(sut.mapBtn.titleLabel?.text, LocalizationKeys.SCBasicPOIGuideListMapFilterViewController.poi001TabMapLabel.localized())
		XCTAssertEqual(sut.listBtn.titleLabel?.text, LocalizationKeys.SCBasicPOIGuideListMapFilterViewController.poi001TabListLabel.localized())
		XCTAssertEqual(sut.getDirectionLabel.text, LocalizationKeys.SCBasicPOIGuideListMapFilterViewController.e006EventRoute.localized())
		XCTAssertNotNil(sut.mapView)
	}
	
	func testSetVisibilityOfMapFilter() {
		let sut = prepareSut()
		sut.isListSelected = false
		sut.setVisibilityOfListMapFilter()
		XCTAssertFalse(sut.mapViewContainer.isHidden)
		XCTAssertTrue(sut.listTableView.isHidden)
	}
	
	func testSetVisibilityOfListFilter() {
		let sut = prepareSut()
		sut.isListSelected = true
		sut.setVisibilityOfListMapFilter()
		XCTAssertTrue(sut.mapViewContainer.isHidden)
		XCTAssertFalse(sut.listTableView.isHidden)
	}
	
	func testCatgegoryViewWasPressed() {
		let sut = prepareSut()
		sut.catgegoryViewWasPressed()
		guard let presenter = sut.presenter as? SCBasicPOIGuideListMapFilterPresenterMock else {
			XCTFail("Test failed")
			return
		}
		XCTAssertTrue(sut.poiOverlayView.isHidden)
		XCTAssertTrue(presenter.isCategoryWasPressed)
	}
	
	func testPoiOverlayViewWasPressed() {
		let mockSelectedPoi = POIInfo(address: "Arndtstraße 2, 53721 Siegburg", categoryName: "Schools",
							  cityId: 16, description: "", distance: 517,
							  icon: Optional(OSCA.SCImageURL(urlString: "", persistence: false)),
							  id: 10481, latitude: 50.80359, longitude: 7.190416, openHours: "",
							  subtitle: "Gemeinschaftsgrundschule", title: "GGS Adolf-Kolping",
							  url: "https://siegburg.de/familie-bildung/schulen/grundschulen/ggs-adolf-kolping/index.html",
							  poiFavorite: false)
		let sut = prepareSut()
		sut.selectedPOI = mockSelectedPoi
		sut.poiOverlayViewWasPressed()
		guard let presenter = sut.presenter as? SCBasicPOIGuideListMapFilterPresenterMock else {
			XCTFail("Test failed")
			return
		}
		XCTAssertTrue(sut.poiOverlayView.isHidden)
		XCTAssertEqual(presenter.selectedPOIItem!, mockSelectedPoi)
	}
	
	func testSetupPOIOverlayView() {
		let mockSelectedPoi = POIInfo(address: "Arndtstraße 2, 53721 Siegburg", categoryName: "Schools",
							  cityId: 16, description: "", distance: 517,
							  icon: Optional(OSCA.SCImageURL(urlString: "", persistence: false)),
							  id: 10481, latitude: 50.80359, longitude: 7.190416, openHours: "",
							  subtitle: "Gemeinschaftsgrundschule", title: "GGS Adolf-Kolping",
							  url: "https://siegburg.de/familie-bildung/schulen/grundschulen/ggs-adolf-kolping/index.html",
							  poiFavorite: false)
		let sut = prepareSut()
		sut.selectedPOI = mockSelectedPoi
		sut.setupPOIOverlayView()
		XCTAssertEqual(sut.poiOverlayLbl.text, mockSelectedPoi.categoryName)
		XCTAssertEqual(sut.poiOverlayCategoryLbl.text, mockSelectedPoi.title)
		XCTAssertEqual(sut.poiOverlaySubtitleLbl.text, mockSelectedPoi.subtitle)
		XCTAssertEqual(sut.poiOverlayAddressLbl.text, LocalizationKeys.SCBasicPOIGuideListMapFilterViewController.poi001AddressLabel.localized())
		XCTAssertEqual(sut.poiOverlayAddressLabel.attributedText, mockSelectedPoi.address.applyHyphenation())
		XCTAssertEqual(sut.poiOverlayOpenHoursLbl.text, LocalizationKeys.SCBasicPOIGuideListMapFilterViewController.poi001OpeningHoursLabel.localized())
	}
	
	func testRetryBtnWasPressed() {
		let mockSelectedPoi = POIInfo(address: "Arndtstraße 2, 53721 Siegburg", categoryName: "Schools",
							  cityId: 16, description: "", distance: 517,
							  icon: Optional(OSCA.SCImageURL(urlString: "", persistence: false)),
							  id: 10481, latitude: 50.80359, longitude: 7.190416, openHours: "",
							  subtitle: "Gemeinschaftsgrundschule", title: "GGS Adolf-Kolping",
							  url: "https://siegburg.de/familie-bildung/schulen/grundschulen/ggs-adolf-kolping/index.html",
							  poiFavorite: false)
		let sut = prepareSut()
		sut.selectedPOI = mockSelectedPoi
		sut.retryBtnWasPressed(UIButton())
		guard let presenter = sut.presenter as? SCBasicPOIGuideListMapFilterPresenterMock else {
			XCTFail("Test failed")
			return
		}
		XCTAssertTrue(presenter.retryButtonWasPressed)
	}
	
	func testPoiOverlayCloseBtnWasPressed() {
		let sut = prepareSut()
		sut.poiOverlayCloseBtnWasPressed(UIButton())
		XCTAssertTrue(sut.poiOverlayView.isHidden)
	}
	
	func testSetupUI() {
		let mockTitle = "Where to?"
		let sut = prepareSut()
		sut.setupUI(with: mockTitle)
		XCTAssertEqual(sut.navigationItem.title, mockTitle)
		XCTAssertEqual(sut.errorLabel.text, LocalizationKeys.SCBasicPOIGuideCategorySelectionVCDisplaying.poi002ErrorText.localized())
	}
	
	func testShowPOIOverlay() {
		let sut = prepareSut()
		sut.selectedPOI = POIInfo(address: "Arndtstraße 2, 53721 Siegburg", categoryName: "Schools",
								  cityId: 16, description: "", distance: 517,
								  icon: Optional(OSCA.SCImageURL(urlString: "", persistence: false)),
								  id: 10481, latitude: 50.80359, longitude: 7.190416, openHours: "",
								  subtitle: "Gemeinschaftsgrundschule", title: "GGS Adolf-Kolping",
								  url: "https://siegburg.de/familie-bildung/schulen/grundschulen/ggs-adolf-kolping/index.html",
								  poiFavorite: false)
		sut.showPOIOverlay()
		XCTAssertFalse(sut.poiOverlayView.isHidden)
	}
	
	func testHidePOIOverlay() {
		let sut = prepareSut()
		sut.hidePOIOverlay()
		XCTAssertTrue(sut.poiOverlayView.isHidden)
	}
	
	func testShowOverlayWithActivityIndicator() {
		let sut = prepareSut()
		sut.showOverlayWithActivityIndicator()
		XCTAssertFalse(sut.activityIndicator.isHidden)
		XCTAssertFalse(sut.overlayView.isHidden)
		XCTAssertTrue(sut.errorLabel.isHidden)
		XCTAssertTrue(sut.retryButton.isHidden)
	}

	func testShowOverlayWithGeneralError() {
		let sut = prepareSut()
		sut.showOverlayWithGeneralError()
		XCTAssertTrue(sut.activityIndicator.isHidden)
		XCTAssertFalse(sut.errorLabel.isHidden)
		XCTAssertFalse(sut.retryButton.isHidden)
		XCTAssertFalse(sut.overlayView.isHidden)
	}

	func testHideOverlay() {
		let sut = prepareSut()
		XCTAssertTrue(sut.overlayView.isHidden)
	}
	
	
}

class SCBasicPOIGuideListMapFilterPresenterMock: SCBasicPOIGuideListMapFilterPresenting {
	private(set) var isViewLoaded: Bool = false
	private(set) var isViewWillAppearCalled: Bool = false
	private(set) var isViewDidAppearCalled: Bool = false
	private(set) var isCategoryWasPressed: Bool = false
	private(set) var selectedPOIItem: POIInfo?
	private(set) var retryButtonWasPressed: Bool = false
	private(set) var didSelectListItemPressed: Bool = false
	func setDisplay(_ display: OSCA.SCBasicPOIGuideListMapFilterDisplaying) {
		
	}
	
	func didSelectListItem(item: OSCA.POIInfo) {
		didSelectListItemPressed = true
		selectedPOIItem = item
	}
	
	func closeButtonWasPressed() {
		
	}
	
	func categoryWasPressed() {
		isCategoryWasPressed = true
	}
	
	func closePOIOverlayButtonWasPressed() {
		
	}
	
	func didPressGeneralErrorRetryBtn() {
		retryButtonWasPressed = true
	}
	
	func getCityLocation() -> CLLocation {
		return CLLocation(latitude: 12.11, longitude: 3.11)
	}
	
	func viewDidLoad() {
		isViewLoaded = true
	}
	
	func viewWillAppear() {
		isViewWillAppearCalled = true
	}
	
	func viewDidAppear() {
		isViewDidAppearCalled = true
	}
}
