//
//  SCBasicPOIGuideDetailViewControllerTests.swift
//  OSCATests
//
//  Created by Bhaskar N S on 04/06/24.
//  Copyright © 2024 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import XCTest
@testable import OSCA

final class SCBasicPOIGuideDetailViewControllerTests: XCTestCase {
	private func prepareSut(presenter: SCBasicPOIGuideDetailPresenting? = nil) -> SCBasicPOIGuideDetailViewController {
		let storyboard = UIStoryboard(name: "BasicPOIGuideDetail", bundle: nil)
		let sut = storyboard.instantiateViewController(identifier: "SCBasicPOIGuideDetailViewController") as! SCBasicPOIGuideDetailViewController
		sut.presenter = presenter ?? SCBasicPOIGuideDetailPresenterMock()
		sut.loadViewIfNeeded()
		return sut
	}
	
	func testViewDidLoad() {
		let sut = prepareSut()
		sut.viewDidLoad()
		guard let presenter = sut.presenter as? SCBasicPOIGuideDetailPresenterMock else {
			XCTFail("Test Failed")
			return
		}
		XCTAssertTrue(presenter.isViewLoaded)
	}

}

class SCBasicPOIGuideDetailPresenterMock: SCBasicPOIGuideDetailPresenting {
	private(set) var isViewLoaded: Bool = false
	
	func viewDidLoad() {
		isViewLoaded = true
	}
	func setDisplay(_ display: OSCA.SCBasicPOIGuideDetailDisplaying) {
		
	}
	
	func mapViewWasPressed(latitude: Double, longitude: Double, zoomFactor: Float, address: String) {
		
	}
	
	func directionsButtonWasPressed(latitude: Double, longitude: Double, address: String) {
		
	}
	
	func reloadDetailPageContent() {
		
	}
	
	func getShareBarButton() -> UIBarButtonItem? {
		return UIBarButtonItem()
	}
	
	func sharePOI() {
		
	}
}
