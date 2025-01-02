//
//  SCBasicPOIGuideListMapFilterPresenterTests.swift
//  OSCATests
//
//  Created by Bhaskar N S on 03/06/24.
//  Copyright © 2024 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import XCTest
@testable import OSCA
import CoreLocation

final class SCBasicPOIGuideListMapFilterPresenterTests: XCTestCase {
	
	private var displayer: SCBasicPOIGuideListMapFilterDisplaying?
	
	private func preapreSut(poi: [POIInfo]? = nil, 
							poiCategory: [POICategoryInfo]? = nil, item: SCBaseComponentItem,
							userDefaults: UserDefaultsHelping? = nil) -> SCBasicPOIGuideListMapFilterPresenter {
		let presenter = SCBasicPOIGuideListMapFilterPresenter(cityID: 12,
															  poi: poi ?? [],
															  poiCategory: poiCategory ?? [],
															  injector: MockSCInjector(),
															  basicPOIGuideWorker: BasicPOIGuideWorkerMock(),
															  cityContentSharedWorker: SCCityContentSharedWorkerMock(),
															  item: item,
															  userDefaults: userDefaults ?? MockUserDefaults(selectedCityId: 12))
		return presenter
	}
	
	fileprivate func getPOI() -> [POIInfo] {
		return [
			OSCA.POIInfo(address: "Arndtstraße 2, 53721 Siegburg", categoryName: "Schools", cityId: 16, description: "", distance: 517, icon: Optional(OSCA.SCImageURL(urlString: "", persistence: false)), id: 10481, latitude: 50.80359, longitude: 7.190416, openHours: "", subtitle: "Gemeinschaftsgrundschule", title: "GGS Adolf-Kolping", url: "https://siegburg.de/familie-bildung/schulen/grundschulen/ggs-adolf-kolping/index.html", poiFavorite: false),
			OSCA.POIInfo(address: "Bambergstraße 23, 53721 Siegburg", categoryName: "Schools", cityId: 16, description: "", distance: 518, icon: Optional(OSCA.SCImageURL(urlString: "", persistence: false)), id: 10484, latitude: 50.804752, longitude: 7.2066336, openHours: "", subtitle: "Verbundschule", title: "GGS Nord (mit Montessori-Zweig) & GS Humperdinck", url: "https://siegburg.de/familie-bildung/schulen/grundschulen/ggs-nord-und-gs-humperdinck/index.html", poiFavorite: false),
			OSCA.POIInfo(address: "Nogenter Platz 10, 53721 Siegburg", categoryName: "Schools", cityId: 16, description: "", distance: 518, icon: Optional(OSCA.SCImageURL(urlString: "", persistence: false)), id: 10488, latitude: 50.79781, longitude: 7.20623, openHours: "", subtitle: "", title: "Realschule Siegburg", url: "https://siegburg.de/familie-bildung/schulen/realschulen/index.html", poiFavorite: false),
			OSCA.POIInfo(address: "Alleestraße 2, 53721 Siegburg", categoryName: "Schools", cityId: 16, description: "", distance: 518, icon: Optional(OSCA.SCImageURL(urlString: "", persistence: false)), id: 10492, latitude: 50.797142, longitude: 7.203804, openHours: "", subtitle: "Städtisches Gymnasium", title: "Gymnasium Siegburg Alleestraße", url: "https://siegburg.de/familie-bildung/schulen/gymnasien/gymnasium-siegburg-alleestrasse/index.html", poiFavorite: false),
		]
	}
	
	fileprivate func getMockBaseComponent() -> SCBaseComponentItem {
		return SCBaseComponentItem(itemID: "171", itemTitle: "Interesting Places", itemTeaser: nil, itemSubtitle: nil, itemImageURL: nil,
								   itemImageCredit: nil, itemThumbnailURL: nil, itemIconURL: nil, itemURL: nil, itemDetail: "Interesting Places",
								   itemHtmlDetail: true, itemCategoryTitle: "My services", itemColor: .cyan, itemCellType: .tiles_icon,
								   itemLockedDueAuth: false, itemLockedDueResidence: false, itemIsNew: false, itemFunction: "poi",
								   itemBtnActions: [], itemContext: .none, badgeCount: nil, itemServiceParams: nil, helpLinkTitle: nil,
								   templateId: nil, headerImageURL: nil, serviceType: "Interessante Orte")
	}
	
	
	func testViewDidLoad() {
		let mockItem = getMockBaseComponent()
		let sut = preapreSut(poi: getPOI(),
							 poiCategory: getPOICategyInfo(),
							 item: mockItem)
		let displayer = SCBasicPOIGuideListMapFilterDisplayer()
		self.displayer = displayer
		sut.setDisplay(displayer)
		sut.viewDidLoad()
		XCTAssertTrue(displayer.isSetUICalled)
		XCTAssertEqual(displayer.navTitle, mockItem.itemTitle)
	}
	
	func testCloseButtonPressed() {
		let mockItem = getMockBaseComponent()
		let sut = preapreSut(poi: getPOI(),
							 poiCategory: getPOICategyInfo(),
							 item: mockItem)
		let displayer = SCBasicPOIGuideListMapFilterDisplayer()
		self.displayer = displayer
		sut.setDisplay(displayer)
		sut.closeButtonWasPressed()
	}
	
	func testUpdateCategoryIdForCity() {
		let mockItem = getMockBaseComponent()
		let mockCategoriesInfo = getPOICategyInfo()
		let mockUserDerfaults = MockUserDefaults(selectedCityId: 12)
		let mockCategoryList = SCModelPOICategoryList(categoryId: 82, categoryName: "Playgrounds and football fields")
		mockUserDerfaults.poiCategoryList = mockCategoryList
		let sut = preapreSut(poi: getPOI(),
							 poiCategory: mockCategoriesInfo,
							 item: mockItem,
							 userDefaults: mockUserDerfaults)
		let displayer = SCBasicPOIGuideListMapFilterDisplayer()
		self.displayer = displayer
		sut.setDisplay(displayer)
		sut.updateCategoryIdForCity()
		XCTAssertEqual(mockUserDerfaults.getPOICategoryID(), mockCategoryList.categoryId)
	}
	
	func testDidPressGeneralErrorRetryBtn() {
		let mockItem = getMockBaseComponent()
		let sut = preapreSut(poi: getPOI(),
							 poiCategory: getPOICategyInfo(),
							 item: mockItem)
		let displayer = SCBasicPOIGuideListMapFilterDisplayer()
		self.displayer = displayer
		sut.setDisplay(displayer)
		sut.didPressGeneralErrorRetryBtn()
		let exp = expectation(description: "Test after 3 seconds")
		let result = XCTWaiter.wait(for: [exp], timeout: 3.0)
		if result == XCTWaiter.Result.timedOut {
			XCTAssertTrue(displayer.isShowOverlayWithActivityIndicator)
			XCTAssertTrue(displayer.isUpdateCategoryCalled)
		} else {
			XCTFail("Delay interrupted")
		}
	}
	
	func testClosePOIOverlayButtonWasPressed() {
		let mockItem = getMockBaseComponent()
		let sut = preapreSut(poi: getPOI(),
							 poiCategory: getPOICategyInfo(),
							 item: mockItem)
		let displayer = SCBasicPOIGuideListMapFilterDisplayer()
		self.displayer = displayer
		sut.setDisplay(displayer)
		sut.closePOIOverlayButtonWasPressed()
		XCTAssertTrue(displayer.isHidePOIOverlayCalled)
	}
	
	func testDidSelectListItem() {
		let mockItem = getMockBaseComponent()
		let sut = preapreSut(poi: getPOI(),
							 poiCategory: getPOICategyInfo(),
							 item: mockItem)
		let displayer = SCBasicPOIGuideListMapFilterDisplayer()
		self.displayer = displayer
		sut.setDisplay(displayer)
		sut.didSelectListItem(item: getPOI().first!)
		XCTAssertTrue(displayer.isPushCalled)
	}
	
	func testLoadPoiBasedOnLocation() {
		let mockItem = getMockBaseComponent()
		let mockUserDerfaults = MockUserDefaults(selectedCityId: 0)
		let sut = preapreSut(poi: getPOI(),
							 poiCategory: getPOICategyInfo(),
							 item: mockItem,
		userDefaults: mockUserDerfaults)
		let displayer = SCBasicPOIGuideListMapFilterDisplayer()
		self.displayer = displayer
		sut.setDisplay(displayer)
		sut.didPressGeneralErrorRetryBtn()
		sut.closePOIOverlayButtonWasPressed()
	}
}

class SCBasicPOIGuideListMapFilterDisplayer: SCBasicPOIGuideListMapFilterDisplaying {
	private(set) var isSetUICalled: Bool = false
	private(set) var navTitle: String = ""
	private(set) var isDismissCalled: Bool = false
	private(set) var isShowOverlayWithActivityIndicator: Bool = false
	private(set) var isUpdateCategoryCalled: Bool = false
	private(set) var isHidePOIOverlayCalled: Bool = false
	private(set) var isPushCalled: Bool = false

	func updateCategory() {
		isUpdateCategoryCalled = true
	}
	
	func loadPois(_ poiItems: [OSCA.POIInfo]) {
		
	}
	
	func dismiss(completion: (() -> Void)?) {
		isDismissCalled = true
	}
	
	func push(viewController: UIViewController) {
		isPushCalled = true
	}
	
	func present(viewController: UIViewController) {
		
	}
	
	func showPOIOverlay() {
		
	}
	
	func hidePOIOverlay() {
		isHidePOIOverlayCalled = true
	}
	
	func showLocationFailedMessage(messageTitle: String, withMessage: String) {
		
	}
	
	func showOverlayWithActivityIndicator() {
		isShowOverlayWithActivityIndicator = true
	}
	
	func showOverlayWithGeneralError() {
		
	}
	
	func hideOverlay() {
		
	}
	
	func setupUI(with navigationTitle: String) {
		isSetUICalled = true
		navTitle = navigationTitle
	}
	
	
}

class MockUserDefaults: UserDefaultsHelping {
	
	var poiInfo: [OSCA.POIInfo]?
	var poiCategoryList: SCModelPOICategoryList?
	var selectedCityId: Int
	var poiCategoryId: Int?
	var poiCategory: String = ""
	
	init(poiInfo: [OSCA.POIInfo]? = nil, poiCategory: SCModelPOICategoryList? = nil, selectedCityId: Int) {
		self.poiInfo = poiInfo
		self.poiCategoryList = poiCategory
		self.selectedCityId = selectedCityId
	}
	func setProfile(profile: SCModelProfile) {
		
	}
	
	func getProfile() -> SCModelProfile? {
		return nil
	}
	
	func setPOIInfo(poiInfo: [OSCA.POIInfo]) {
		self.poiInfo = poiInfo
	
	}
	
	func getPOIInfo() -> [OSCA.POIInfo]? {
		return poiInfo
		
	}
	
	func setSelectedPOICategory(poiCategory: SCModelPOICategoryList) {
		self.poiCategoryList = poiCategory
	}
	
	func getSelectedPOICategory() -> SCModelPOICategoryList? {
		return poiCategoryList
	}
	
	func setPOICategoryID(poiCategoryID: Int) {
		self.poiCategoryId = poiCategoryID
	}
	
	func getPOICategoryID() -> Int? {
		return poiCategoryId
	}
	
	func getSelectedCityID() -> Int {
		return selectedCityId
	}
	
	func getCurrentLocation() -> CLLocation {
		return CLLocation(latitude: 1.33, longitude: 2.33)
	}
	
	func getPOICategory() -> String? {
		return poiCategory
	}
	
	func setPOICategory(poiCategory: String) {
		self.poiCategory = poiCategory
	}
	
	func setPOICategoryGroupIcon(poiCategory: String) {
		
	}
	
	func setSelectedCityID(id: Int) {
		self.selectedCityId = id
	}
	
	
}

class BasicPOIGuideWorkerMock: SCBasicPOIGuideWorking {
	var poiDataState = SCWorkerDataState()
	var poiCategoryDataState = SCWorkerDataState()

	func getCityPOI(cityId: String, latitude: Double, longitude: Double, categoryId: String, completion: @escaping (([SCModelPOI], SCWorkerError?) -> Void)) {
		
	}
	
	func getCityPOICategories(cityId: String, completion: @escaping ([SCModelPOICategory], SCWorkerError?) -> Void) {
		
	}
	
	func getCityPOICount(cityId: String, categoryId: String, completion: @escaping (Int, SCWorkerError?) -> Void) {
		
	}
	
	func getCityPOICategories() -> [POICategoryInfo]? {
		return getPOICategyInfo()
	}
	
	func getCityPOI() -> [POIInfo]? {
		return []
	}
	
	func triggerPOICategoriesUpdate(for cityID: Int, errorBlock: @escaping (SCWorkerError?) -> ()) {
		
	}
	
	func triggerPOIUpdate(for cityID: Int, latitude: Double, longitude: Double, categoryId: Int, errorBlock: @escaping (SCWorkerError?) -> ()) {
		
	}
	
	
}

fileprivate func getPOICategyInfo() -> [POICategoryInfo] {
	return [
		POICategoryInfo(categoryGroupIcon: OSCA.SCImageURL(urlString: "https://sol-preprod-img.obs.eu-de.otc.t-systems.com/img/poi_activities_2x.png", persistence: false), categoryGroupId: "7", categoryGroupName: "Activities", categoryList: [OSCA.SCModelPOICategoryList(categoryId: 82, categoryName: "Playgrounds and football fields")], categoryFavorite: false),
		POICategoryInfo(categoryGroupIcon: OSCA.SCImageURL(urlString: "https://sol-preprod-img.obs.eu-de.otc.t-systems.com/img/poi_culture_2x.png", persistence: false), categoryGroupId: "9", categoryGroupName: "Culture", categoryList: [OSCA.SCModelPOICategoryList(categoryId: 81, categoryName: "Cultural facilities")], categoryFavorite: false),
		POICategoryInfo(categoryGroupIcon: OSCA.SCImageURL(urlString: "https://sol-preprod-img.obs.eu-de.otc.t-systems.com/img/poi_family_2x.png", persistence: false), categoryGroupId: "6", categoryGroupName: "Family", categoryList: [OSCA.SCModelPOICategoryList(categoryId: 78, categoryName: "Kindergartens"), OSCA.SCModelPOICategoryList(categoryId: 80, categoryName: "Schools")], categoryFavorite: false),
		POICategoryInfo(categoryGroupIcon: OSCA.SCImageURL(urlString: "https://sol-preprod-img.obs.eu-de.otc.t-systems.com/img/poi_insiders_2x.png", persistence: false), categoryGroupId: "14", categoryGroupName: "Insider tips of the city Siegburg", categoryList: [OSCA.SCModelPOICategoryList(categoryId: 86, categoryName: "Sights")], categoryFavorite: false),
		POICategoryInfo(categoryGroupIcon: OSCA.SCImageURL(urlString: "https://sol-preprod-img.obs.eu-de.otc.t-systems.com/img/icon-category-mobility-2@2x.png", persistence: false), categoryGroupId: "15", categoryGroupName: "Mobility", categoryList: [OSCA.SCModelPOICategoryList(categoryId: 85, categoryName: "Parking lots")], categoryFavorite: false),
		POICategoryInfo(categoryGroupIcon: OSCA.SCImageURL(urlString: "https://sol-preprod-img.obs.eu-de.otc.t-systems.com/img/poi_other_2x.png", persistence: false), categoryGroupId: "5", categoryGroupName: "Other", categoryList: [OSCA.SCModelPOICategoryList(categoryId: 79, categoryName: "Administration"), OSCA.SCModelPOICategoryList(categoryId: 83, categoryName: "Containers for small electrical appliances"), OSCA.SCModelPOICategoryList(categoryId: 84, categoryName: "Glass containers")], categoryFavorite: false)
	]
}
