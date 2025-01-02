//
//  SCBasicPOIGuideDetailPresenterTests.swift
//  OSCATests
//
//  Created by Bhaskar N S on 04/06/24.
//  Copyright © 2024 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import XCTest
@testable import OSCA

final class SCBasicPOIGuideDetailPresenterTests: XCTestCase {

	private var displayer: SCBasicPOIGuideDetailDisplaying?
	
	fileprivate func prepareSut(cityId: Int? = nil, poi: POIInfo? = nil) -> SCBasicPOIGuideDetailPresenter {
		return SCBasicPOIGuideDetailPresenter(cityID: cityId ?? 12,
											  poi: poi ?? getPOI(),
											  injector: MockSCInjector())
	}

	fileprivate func getPOI() -> POIInfo {
		POIInfo(address: "Arndtstraße 2, 53721 Siegburg", categoryName: "Schools", cityId: 16, description: "",
				distance: 517, icon: SCImageURL(urlString: "", persistence: false), id: 10481, latitude: 50.80359,
				longitude: 7.190416, openHours: "", subtitle: "Gemeinschaftsgrundschule", title: "GGS Adolf-Kolping",
				url: "https://siegburg.de/familie-bildung/schulen/grundschulen/ggs-adolf-kolping/index.html",
				poiFavorite: false)
	}
	
	func testViewDidLoad() {
		let mockPoiInfo = getPOI()
		let sut = prepareSut(poi: mockPoiInfo)
		let displayer = SCBasicPOIGuideDetailDisplayer()
		self.displayer = displayer
		sut.setDisplay(displayer)
		sut.viewDidLoad()
		XCTAssertTrue(displayer.isSetupUICalled)
		XCTAssertEqual(displayer.navTitle, mockPoiInfo.categoryName)
		
		XCTAssertEqual(displayer.title, mockPoiInfo.title)
		XCTAssertEqual(displayer.description, mockPoiInfo.description)
		XCTAssertEqual(displayer.address, mockPoiInfo.address)
		XCTAssertEqual(displayer.categoryName, mockPoiInfo.categoryName)
		XCTAssertEqual(displayer.cityId, mockPoiInfo.cityId)
		XCTAssertEqual(displayer.distance, mockPoiInfo.distance)
		XCTAssertEqual(displayer.icon, mockPoiInfo.icon)
		XCTAssertEqual(displayer.latitude, Double(mockPoiInfo.latitude))
		XCTAssertEqual(displayer.longitude, Double(mockPoiInfo.longitude))
		XCTAssertEqual(displayer.openHours, mockPoiInfo.openHours)
		XCTAssertEqual(displayer.id, mockPoiInfo.id)
		XCTAssertEqual(displayer.subtitle, mockPoiInfo.subtitle)
		XCTAssertEqual(displayer.url, mockPoiInfo.url)
	}
	
	func testReloadDetailPageContent() {
		let mockPoiInfo = getPOI()
		let sut = prepareSut(poi: mockPoiInfo)
		let displayer = SCBasicPOIGuideDetailDisplayer()
		self.displayer = displayer
		sut.setDisplay(displayer)
		sut.reloadDetailPageContent()
		XCTAssertTrue(displayer.isSetupUICalled)
		XCTAssertEqual(displayer.navTitle, mockPoiInfo.categoryName)
		
		XCTAssertEqual(displayer.title, mockPoiInfo.title)
		XCTAssertEqual(displayer.description, mockPoiInfo.description)
		XCTAssertEqual(displayer.address, mockPoiInfo.address)
		XCTAssertEqual(displayer.categoryName, mockPoiInfo.categoryName)
		XCTAssertEqual(displayer.cityId, mockPoiInfo.cityId)
		XCTAssertEqual(displayer.distance, mockPoiInfo.distance)
		XCTAssertEqual(displayer.icon, mockPoiInfo.icon)
		XCTAssertEqual(displayer.latitude, Double(mockPoiInfo.latitude))
		XCTAssertEqual(displayer.longitude, Double(mockPoiInfo.longitude))
		XCTAssertEqual(displayer.openHours, mockPoiInfo.openHours)
		XCTAssertEqual(displayer.id, mockPoiInfo.id)
		XCTAssertEqual(displayer.subtitle, mockPoiInfo.subtitle)
		XCTAssertEqual(displayer.url, mockPoiInfo.url)
	}
	
	func testGetShareBarButton() {
		let mockPoiInfo = getPOI()
		let sut = prepareSut(poi: mockPoiInfo)
		let displayer = SCBasicPOIGuideDetailDisplayer()
		self.displayer = displayer
		sut.setDisplay(displayer)
		XCTAssertNotNil(sut.getShareBarButton())
	}
	
	func testMapViewWasPressed() {
		let mockPoiInfo = getPOI()
		let sut = prepareSut(poi: mockPoiInfo)
		let displayer = SCBasicPOIGuideDetailDisplayer()
		self.displayer = displayer
		sut.setDisplay(displayer)
		sut.directionsButtonWasPressed(latitude: 22.2, longitude: 12.2, address: "")
	}
}

class SCBasicPOIGuideDetailDisplayer: SCBasicPOIGuideDetailDisplaying {
	private(set) var navTitle: String = ""
	private(set) var title: String = ""
	private(set) var description: String = ""
	private(set) var address: String = ""
	private(set) var categoryName: String = ""
	private(set) var cityId: Int = 0
	private(set) var distance: Int = 0
	private(set) var icon: OSCA.SCImageURL?
	private(set) var latitude: Double = 0.0
	private(set) var longitude: Double = 0.0
	private(set) var openHours: String = ""
	private(set) var id: Int = 0
	private(set) var subtitle: String = ""
	private(set) var url: String = ""
	private(set) var isDismissCalled: Bool = false
	private(set) var isPushCalled: Bool = false
	private(set) var isPresentCalled: Bool = false
	private(set) var isSetupUICalled: Bool = false
	
	func setupUI(navTitle: String, title: String, description: String, address: String, categoryName: String,
				 cityId: Int, distance: Int, icon: OSCA.SCImageURL?, latitude: Double,
				 longitude: Double, openHours: String, id: Int, subtitle: String, url: String) {
		isSetupUICalled = true
		self.navTitle = navTitle
		self.title = title
		self.description = description
		self.address = address
		self.categoryName = categoryName
		self.cityId = cityId
		self.distance = distance
		self.icon = icon
		self.latitude = latitude
		self.longitude = longitude
		self.openHours = openHours
		self.id = id
		self.subtitle = subtitle
		self.url = url
		
	}
	
	func dismiss(completion: (() -> Void)?) {
		isDismissCalled = true
	}
	
	func push(viewController: UIViewController) {
		isPushCalled = true
	}
	
	func present(viewController: UIViewController) {
		isPresentCalled = true
	}
}
