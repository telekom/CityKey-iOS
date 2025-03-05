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
//  SCMainPresenterTests.swift
//  SmartCityTests
//
//  Created by Robert Swoboda - Telekom on 29.05.19.
//  Copyright © 2019 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import XCTest
import MapKit
@testable import OSCA

private struct MainTestCase {
    let homeAvailable: Bool
    let servicesAvailable: Bool
    let marketplacesAvailable: Bool
    
    static func allAvailable() -> MainTestCase {
        return MainTestCase(homeAvailable: true, servicesAvailable: true, marketplacesAvailable: true)
    }
}

class SCMainPresenterTests: XCTestCase {
    
    private var mainPresenter: SCMainPresenting!
    private var mainViewDisplayer: MockMainViewDisplayer!
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testTabBarTitlesForAll() {
        self.setupWithAllAvailable()
        
        XCTAssertEqual(mainViewDisplayer.tabBarItemTitles.count, 5)
    }
        
    func testTabBarTitlesForServicesUnavailable() {
        self.setupWithDedicatedTestCase(MainTestCase(homeAvailable: true, servicesAvailable: false, marketplacesAvailable: true))
        
        XCTAssertEqual(mainViewDisplayer.tabBarItemTitles.count, 4)
        XCTAssertNil(mainViewDisplayer.tabBarItemTitles[.services])
        
        XCTAssertNotNil(mainViewDisplayer.tabBarItemTitles[.home])
        XCTAssertNotNil(mainViewDisplayer.tabBarItemTitles[.marketplace])
        XCTAssertNotNil(mainViewDisplayer.tabBarItemTitles[.userinfo])
    }
    
    func testTabBarTitlesForMarketplacesUnavailable() {
        self.setupWithDedicatedTestCase(MainTestCase(homeAvailable: true, servicesAvailable: true, marketplacesAvailable: false))
        
        XCTAssertEqual(mainViewDisplayer.tabBarItemTitles.count, 4)
        XCTAssertNil(mainViewDisplayer.tabBarItemTitles[.marketplace])
        
        XCTAssertNotNil(mainViewDisplayer.tabBarItemTitles[.home])
        XCTAssertNotNil(mainViewDisplayer.tabBarItemTitles[.services])
        XCTAssertNotNil(mainViewDisplayer.tabBarItemTitles[.userinfo])
    }
    
    func testTaBbarTitlesForOnxlyHomeAvailable() {
        self.setupWithDedicatedTestCase(MainTestCase(homeAvailable: true, servicesAvailable: false, marketplacesAvailable: false))
        
        XCTAssertEqual(mainViewDisplayer.tabBarItemTitles.count, 3)
        XCTAssertNil(mainViewDisplayer.tabBarItemTitles[.marketplace])
        XCTAssertNil(mainViewDisplayer.tabBarItemTitles[.services])
        
        XCTAssertNotNil(mainViewDisplayer.tabBarItemTitles[.home])
        XCTAssertNotNil(mainViewDisplayer.tabBarItemTitles[.userinfo])
    }
    
    func testTaBbarTitlesForNothingAvailable() {
        self.setupWithDedicatedTestCase(MainTestCase(homeAvailable: false, servicesAvailable: false, marketplacesAvailable: false))
        
        XCTAssertEqual(mainViewDisplayer.tabBarItemTitles.count, 3)
        
        XCTAssertNotNil(mainViewDisplayer.tabBarItemTitles[.userinfo])
        
        XCTAssertNil(mainViewDisplayer.tabBarItemTitles[.marketplace])
        XCTAssertNil(mainViewDisplayer.tabBarItemTitles[.services])
    }
    
    func testColor() {
        self.setupWithAllAvailable()
        
        XCTAssertEqual(mainViewDisplayer.tabBarColor, kColor_cityColor)
    }
    
    func testUserInfoBadge() {
        self.setupWithAllAvailable()

        let tabBarItemBadgeValue = mainViewDisplayer.tabBarItemBadges[.userinfo]
        XCTAssertEqual(tabBarItemBadgeValue?.value, 1)
        XCTAssertEqual(tabBarItemBadgeValue?.color, kColor_cityColor)
    }
    
    private func setupWithDedicatedTestCase(_ testCase: MainTestCase) {
        self.mainPresenter = SCMainPresenter(mainWorker: MockMainWorker(), cityContentSharedWorker: MockCityContentSharedWorker(testCase: testCase),  userContentSharedWorker: MockUserContentSharedWorker(), appContentSharedWorker: MockAppContentWorker(), authProvider: MockAuthTokenProvider(), injector: MockMainInjector(),refreshHandler: MockRefreshHandler(), userCityContentSharedWorker: MockUserCityContentSharedWorker(), basicPOIGuideWorker: MockBasicPOIGuideWorker())
        self.mainViewDisplayer = MockMainViewDisplayer()
        
        self.mainPresenter.setDisplay(mainViewDisplayer)
        self.mainPresenter.viewDidLoad()
    }
    
    private func setupWithAllAvailable() {
        self.mainPresenter = SCMainPresenter(mainWorker: MockMainWorker(), cityContentSharedWorker: MockCityContentSharedWorker(testCase: MainTestCase.allAvailable()), userContentSharedWorker: MockUserContentSharedWorker(), appContentSharedWorker: MockAppContentWorker(), authProvider: MockAuthTokenProvider(), injector: MockMainInjector(), refreshHandler: MockRefreshHandler(), userCityContentSharedWorker: MockUserCityContentSharedWorker(), basicPOIGuideWorker: MockBasicPOIGuideWorker())
        self.mainViewDisplayer = MockMainViewDisplayer()
        
        self.mainPresenter.setDisplay(mainViewDisplayer)
        self.mainPresenter.viewDidLoad()
    }
}

private class MockMainWorker: SCMainWorking {
    func getUnreadUserInfoCount() -> Int {
        return 3
    }
}

private class MockAppContentWorker: SCAppContentSharedWorking {
    func isNearestCityAvailable() -> Bool {
        return false
    }
    
    func updateNearestCity(cityId: Int) {
        
    }
    
    func storedNearestCity() -> Int {
        return 0
    }
    
    func isDistanceToNearestLocationAvailable() -> Bool {
        return false
    }
    
    func updateDistanceToNearestLocation(distance: Double) {
        
    }
    
    func storedDistanceToNearestLocation() -> Double? {
        return 0.0
    }
    

    var favoriteEventsDataState = SCWorkerDataState()

    var termsDataState =  SCWorkerDataState()

    var firstTimeUsageFinished: Bool = true

    var switchLocationToolTipShouldBeShown: Bool = true

    var switchCityToolTipShouldBeShown: Bool = true

    var trackingPermissionFinished: Bool = true

    var isToolTipShown: Bool = true
    
    func getDataSecurity() -> SCModelTermsDataSecurity? {
        return nil
    }
    
    var privacyOptOutMoEngage: Bool = false
    
    var privacyOptOutAdjust: Bool = false
        
    var isCityActive: Bool = true

    func observePrivacySettings(completion: @escaping (Bool, Bool) -> Void) {
        
    }
    
    func getFAQLink() -> String? {
        return nil
    }
    
    func getLegalNotice() -> String? {
        return nil
    }
    
    func getTermsAndConditions() -> String? {
        return nil
    }
    
    func triggerTermsUpdate(errorBlock: @escaping (SCWorkerError?) -> ()) {
        
    }
    
    func acceptDataPrivacyNoticeChange(completion: @escaping (SCWorkerError?, Int?) -> Void) {
        
    }
    

}

private class MockUserCityContentWorker: SCUserCityContentSharedWorking {

    var favoriteEventsDataState = SCWorkerDataState()
    
    func removeFavorite(event: SCModelEvent) {
        
    }
        
    func appendFavorite(event: SCModelEvent) {
        
    }

    func update(appointments: [SCModelAppointment]) {}
        
    func markAppointmentsAsRead() {
        
    }

    func getUserCityContentData() -> SCUserCityContentModel? {
        return SCUserCityContentModel(favorites: [])
    }
    
    func triggerFavoriteEventsUpdate(errorBlock: @escaping (SCWorkerError?) -> ()) {
    }

    var appointmentsDataState = SCWorkerDataState()

    func getAppointments() -> [SCModelAppointment] {
        return []
    }

    func isAppointmentsDataAvailable() -> Bool {
        return true
    }

    func triggerAppointmentsUpdate(errorBlock: @escaping (SCWorkerError?) -> ()) { }

    func clearData() {}
}

private class MockCityContentSharedWorker: SCCityContentSharedWorking {
    var citiesDataState = SCWorkerDataState()
    var cityContentDataState = SCWorkerDataState()
    var newsDataState = SCWorkerDataState()
    var servicesDataState = SCWorkerDataState()
    var weatherDataState = SCWorkerDataState()

    func cityIDForPostalCode(postalcode: String) -> Int?{
        return nil
    }
    
    func triggerCityContentUpdate(for cityID: Int, errorBlock: @escaping (SCWorkerError?) -> ()) {
        errorBlock(nil)
    }
    
    func triggerCitiesUpdate(errorBlock: @escaping (SCWorkerError?) -> ()) {
        errorBlock(nil)
    }
    
    func getCityID() -> Int {
        return 5
    }
    
    func setStoredCityID(for cityID: Int) {

    }
    
    func getCityLocation() -> CLLocation {
        return CLLocation(latitude: 0.0, longitude: 0.0)
    }
    
    func setStoredCityLocation(for cityLocation: CLLocation) {
        
    }
    
    func isCityContentAvailable(for cityID: Int) -> Bool {
        return true
    }
    
    func getCityContentData(for cityID: Int) -> SCCityContentModel? {
        let cityModel = SCModelCity.defaultCity()
        var cityConfig = SCModelCityConfig(showFavouriteServices: true, showHomeDiscounts: true, showHomeOffers: true, showHomeTips: true, showFavouriteMarketplaces: true, showNewServices: true, showNewMarketplaces: true, showMostUsedServices: true, showMostUsedMarketplaces: true, showCategories: true, showBranches: true, showDiscounts: true, showOurMarketPlaces: true, showOurServices: true, showMarketplacesOption: true, showServicesOption: true, stickyNewsCount: 4)

        if !testCase.servicesAvailable {
            cityConfig = SCModelCityConfig(showFavouriteServices: true, showHomeDiscounts: true, showHomeOffers: true, showHomeTips: true, showFavouriteMarketplaces: true, showNewServices: true, showNewMarketplaces: true, showMostUsedServices: true, showMostUsedMarketplaces: true, showCategories: true, showBranches: true, showDiscounts: true, showOurMarketPlaces: true, showOurServices: true, showMarketplacesOption: true, showServicesOption: false, stickyNewsCount: 4)
        }
        if !testCase.marketplacesAvailable {
            cityConfig = SCModelCityConfig(showFavouriteServices: true, showHomeDiscounts: true, showHomeOffers: true, showHomeTips: true, showFavouriteMarketplaces: true, showNewServices: true, showNewMarketplaces: true, showMostUsedServices: true, showMostUsedMarketplaces: true, showCategories: true, showBranches: true, showDiscounts: true, showOurMarketPlaces: true, showOurServices: true, showMarketplacesOption: false, showServicesOption: true, stickyNewsCount: 4)
        }

        if !testCase.marketplacesAvailable && !testCase.servicesAvailable {
            cityConfig = SCModelCityConfig(showFavouriteServices: true, showHomeDiscounts: true, showHomeOffers: true, showHomeTips: true, showFavouriteMarketplaces: true, showNewServices: true, showNewMarketplaces: true, showMostUsedServices: true, showMostUsedMarketplaces: true, showCategories: true, showBranches: true, showDiscounts: true, showOurMarketPlaces: true, showOurServices: true, showMarketplacesOption: false, showServicesOption: false, stickyNewsCount: 4)
        }

        return SCCityContentModel(city: cityModel, cityImprint: "http:/test.de", cityConfig: cityConfig, cityImprintDesc: "", cityServiceDesc: "", cityNightPicture: SCImageURL(urlString: "", persistence: true), imprintImageUrl: nil)
    }
    
    func getNews(for cityID: Int) -> [SCModelMessage]? {
        return nil
    }
    
    func getServices(for cityID: Int) -> [SCModelServiceCategory]? {
        return nil
    }
    
    func getWeather(for cityID: Int) -> String {
        return "sunny"
    }
    

    func cityInfo(for cityID: Int) -> SCModelCity? {
        return SCModelCity.defaultCity()
    }
    
    func eventsOverviewData() -> SCEventsOverviewData {
        return SCEventsOverviewData()
    }
    
    func storeEventOverviewData(eventOverviewData: SCEventsOverviewData) {
        
    }
    
    
    let testCase: MainTestCase
    
    init(testCase: MainTestCase) {
        self.testCase = testCase
    }
    
    
    func getCities() -> [CityLocationInfo]? {
        return [CityLocationInfo]()
    }
    
    func getServiceMoreInfoHTMLText(cityId: String, serviceId: String, completion: @escaping (String, SCWorkerError?) -> Void) {
        
    }
    
    func checkIfDayOrNightTime() -> SCSunriseOrSunset {
        return .sunrise
    }
    
    func updateSelectedCityIdIfNotFoundInCitiesList(errorBlock: ((SCWorkerError?) -> ())?) {
        errorBlock?(nil)
    }
}

private class MockUserContentSharedWorker: SCUserContentSharedWorking {
    
    var userDataState =  SCWorkerDataState()
    var infoBoxDataState = SCWorkerDataState()

    func observeUserID(completion: @escaping (String?) -> Void) {
        
    }
    
    func getCityID() -> String? {
        return "city1"
    }
    
    func observeCityID(completion: @escaping (String?) -> Void) {
        
    }
    
    func isUserDataLoadingFailed() -> Bool {
        return false
    }
    
    func getUserID() -> String? {
        return "id1"
    }
    
    func isUserDataAvailable() -> Bool {
        return true
    }
    
    func isUserDataLoading() -> Bool {
        return false
    }
    
    func getUserData() -> SCModelUserData? {
        let profile = SCModelProfile(accountId : 2, birthdate: Date(timeIntervalSince1970: TimeInterval(1561780587)), email: "test@tester.de", postalCode: "63739", homeCityId: 10, cityName: "TestStadt", dpnAccepted: true)

        return SCModelUserData(userID: "2", cityID: "10", profile: profile)
    }
    
    func triggerUserDataUpdate(errorBlock: @escaping (SCWorkerError?) -> ()) {
        errorBlock(nil)
    }
    
    func isInfoBoxDataAvailable() -> Bool {
        return true
    }
    
    func isInfoBoxDataLoading() -> Bool {
        return false
    }
    
    func isInfoBoxDataLoadingFailed() -> Bool {
        return false
    }
    
    func getInfoBoxData() -> [SCModelInfoBoxItem]? {
        return [SCModelInfoBoxItem(userInfoId: 1, messageId: 1, description: "Info1", details: "More Details", headline: "Messahe Headline", isRead: false,  creationDate: dateFromString(dateString: "2019-08-01 00-00-00")!, category: SCModelInfoBoxItemCategory(categoryIcon: "icon.png", categoryName: "category1"), buttonText: "ok", buttonAction: "", attachments: [])]
    }

    func triggerInfoBoxDataUpdate(errorBlock: @escaping (SCWorkerError?)->()){
        errorBlock(nil)
    }
    
    func markInfoBoxItem(id : Int, read : Bool) {
        
    }
    
    func removeInfoBoxItem(id : Int){
        
    }

    func clearData(){
        
    }

}

private class MockMainInjector: SCMainInjecting & SCToolsInjecting & SCRegistrationInjecting & SCCategoryFilterInjecting & SCWasteCategoryFilterInjecting & MoEngageAnalyticsInjection & SCAdjustTrackingInjection {
    private(set) var isTrackEventCalled: Bool = false
    private(set) var isTrackEventWithParamCalled: Bool = false
    private(set) var appWillOpenCalled: Bool = false
    private(set) var isSetupMoEngageUserAttributeCalled: Bool = false
    
    func trackEvent(eventName: String) {
        isTrackEventCalled = true
    }
    
    func trackEvent(eventName: String, parameters: [String : String]) {
        isTrackEventWithParamCalled = true
    }
    
    func appWillOpen(url: URL) {
        appWillOpenCalled = true
    }
    
    func setupMoEngageUserAttributes() {
        isSetupMoEngageUserAttributeCalled = true
    }
    
    
    func getForceUpdateVersionViewController() -> UIViewController {
        return UIViewController()
    }
    
    func getVersionInformationViewController() -> UIViewController{
        return UIViewController()
    }
    
    func getBasicPOIGuideCategoryViewController(with poiCategory: [POICategoryInfo], presentationMode: SCBasicPOIGuidePresentationMode, includeNavController: Bool, completionAfterDismiss: (() -> Void)?) -> UIViewController {
        return UIViewController()
    }
    
    func getCategoryFilterViewController(screenTitle: String, selectBtnText: String,filterWorker: SCFilterWorking, preselectedCategories: [SCModelCategory]?, delegate: SCCategorySelectionDelegate) -> UIViewController {
        return UIViewController()
    }
    
    func getCategoryFilterViewController(screenTitle: String, selectBtnText: String,filterWorker: SCWasteFilterWorking, preselectedCategories: [SCModelCategoryObj]?, delegate: SCWasteCategorySelectionDelegate) -> UIViewController {
        return UIViewController()
    }
    
    func getRegistrationConfirmEMailVC(registeredEmail: String, shouldHideTopImage: Bool, presentationType: SCRegistrationConfirmEMailType, isError:Bool?, errorMessage: String?, completionOnSuccess: (() -> Void)?) -> UIViewController {
        return UIViewController()
    }
    
    func getRegistrationConfirmEMailFinishedVC(shouldHideTopImage: Bool, presentationType: SCRegistrationConfirmEMailType, completionOnSuccess: (() -> Void)?) -> UIViewController {
        return UIViewController()
    }
    
    
    func registerPushForApplication() {
    }

    func getLocationSegue(source: UIViewController, destination: UIViewController) -> UIStoryboardSegue {
        return UIStoryboardSegue(identifier: nil, source: source, destination: destination)
    }
    
    func setToolsShower(_ shower: SCToolsShowing) {
        
    }
    
    func getLocationViewController(presentationMode: SCLocationPresentationMode, includeNavController: Bool, completionAfterDismiss: (() -> Void)?) -> UIViewController {
        return UIViewController()
    }

    func getRegistrationViewController(completionOnSuccess: ((String, Bool?, String?) -> Void)?) -> UIViewController {
        return UIViewController()
    }
    
    func getLoginViewController(dismissAfterSuccess: Bool, completionOnSuccess: (() -> Void)?) -> UIViewController {
        return UIViewController()
    }
    
    func getProfileViewController() -> UIViewController {
        return UIViewController()
    }
    
    func configureMainTabViewController(_ viewController: UIViewController) {
        
    }
    
    func getFTUFlowViewController() -> UIViewController {
        return UIViewController()
    }
    
    func getMainPresenter() -> SCMainPresenting {
        return SCMainPresenter(mainWorker: MockMainWorker(), cityContentSharedWorker: MockCityContentSharedWorker(testCase: MainTestCase.allAvailable()), userContentSharedWorker: MockUserContentSharedWorker(), appContentSharedWorker: MockAppContentWorker(), authProvider:  MockAuthTokenProvider() ,injector: MockMainInjector(), refreshHandler: MockRefreshHandler(), userCityContentSharedWorker: MockUserCityContentSharedWorker(), basicPOIGuideWorker: MockBasicPOIGuideWorker())
    }
    
    func getMainTabBarController() -> UIViewController {
        return UIViewController()
    }
    func getDashboardPresenter() -> SCDashboardPresenting {
        return MockDashboardPresenter()
    }
    
    func getUserInfoBoxPresenter() -> SCUserInfoBoxPresenting {
        return MockUserInfoBoxPresenter()
    }
    
    func getFeedbackConfirmationViewController() -> UIViewController {
        return UIViewController()
    }
    
    func getFeedbackController() -> UIViewController {
        return UIViewController()
    }
    
    func getCategoryFilterViewController(screenTitle: String, selectBtnText: String, selectAllButtonHidden: Bool?, filterWorker: SCFilterWorking, preselectedCategories: [SCModelCategory]?, delegate: SCCategorySelectionDelegate) -> UIViewController {
        return UIViewController()
    }
    
    func getCategoryFilterViewController(screenTitle: String, selectBtnText: String, selectAllButtonHidden: Bool?, filterWorker: SCWasteFilterWorking, preselectedCategories: [SCModelCategoryObj]?, delegate: SCWasteCategorySelectionDelegate) -> UIViewController {
        return UIViewController()
    }
    
    func getProfileEditDateOfBirthViewController(in flow: OSCA.DateOfBirth, completionHandler: ((String?) -> Void)?) -> UIViewController {
        return UIViewController()
    }
}

private class  MockDashboardPresenter: SCDashboardPresenting {
    func didSelectListEventItem(item: OSCA.SCModelEvent, isCityChanged: Bool, cityId: Int?) {
        
    }

    func fetchEventDetail(eventId: String, cityId: Int?, isCityChanged: Bool) {
        
    }

    func didPressMoreNewsBtn() {
        
    }
    
    func didPressMoreEventsBtn() {
        
    }
    
    func setDisplay(_ display: SCDashboardDisplaying) {
        
    }
    
    func didSelectCarouselItem(item: SCBaseComponentItem) {
        
    }
    
    func didSelectListItem(item: SCBaseComponentItem) {
        
    }

    func didPressMoreBtn() {
        
    }
    
    func locationButtonWasPressed() {
        
    }
    
    func profileButtonWasPressed() {
        
    }
    
    func needsToReloadData() {
        
    }
    
    func getDashboardFlags() -> SCDashboardFlags{
        return SCDashboardFlags.showAll()
    }
    
    func viewDidLoad() {
        
    }
    
    func viewWillAppear() {
        
    }
    
    func viewDidAppear() {
        
    }
    
}


private class  MockUserInfoBoxPresenter: SCUserInfoBoxPresenting {
    func segmentedControlWasPressed(index: Int) {
        
    }
    
    func markAsRead(_ read: Bool, item: SCUserInfoBoxMessageItem) {
        
    }
    
    func deleteItem(_ item: SCUserInfoBoxMessageItem) {
        
    }
    
    func displayItem(_ item: SCUserInfoBoxMessageItem) {
        
    }
    
    
    func locationButtonWasPressed() {
        
    }
    
    func profileButtonWasPressed() {
        
    }
    
    func viewDidLoad() {
        
    }
    
    func viewWillAppear() {
        
    }
    
    func viewDidAppear() {
        
    }
    
    func setDisplay(_ display: SCUserInfoBoxDisplaying) {
        
    }
    
    func loginButtonWasPressed() {
        
    }
    
    func registerButtonWasPressed() {
        
    }
    
    func impressumButtonWasPressed() {}
    func dataPrivacyButtonWasPressed() {}
    
    func markAsRead(_ read: Bool, item: SCBaseComponentItem) {
        
    }
    
    func deleteItem(_ item: SCBaseComponentItem) {
        
    }
    
    func needsToReloadData() {
        
    }
    
    func displayItem(_ item: SCBaseComponentItem) {
    }
    
    func infoboxMessageDetailScreen(deeplinkMessageId: String?, isRefreshUserInfoBoxRequired: Bool) {
        
    }
}

private class MockMainViewDisplayer: SCMainDisplaying {
    func showActivityLayer(_ show: Bool) {
        
    }
    
    func selectedController() -> UIViewController? {
        return nil
    }
    
    func showNoInternetAvailableDialog() {
        
    }
    
    func showErrorDialog(with text: String) {
        
    }
    
    func showErrorDialog(_ error: SCWorkerError) {
        
    }
    


    
    func present(viewController: UIViewController) {}
    func navigationController() -> UINavigationController? {
        return UINavigationController()
    }
    
    
    var tabBarItemTitles: [SCMainTabBarItemType: String] = [SCMainTabBarItemType: String]()
    var tabBarColor: UIColor?
    var tabBarItemBadges: [SCMainTabBarItemType: (value: Int, color: UIColor)] = [SCMainTabBarItemType: (Int, UIColor)]()
    
    func setTabBarItemTitle(_ title: String, for itemType: SCMainTabBarItemType) {
        self.tabBarItemTitles[itemType] = title
    }
    
    func setTabBarColor(_ color: UIColor) {
        self.tabBarColor = color
    }
    
    func setTabBarItemBadge(for itemType: SCMainTabBarItemType, value: Int, color: UIColor) {
        self.tabBarItemBadges[itemType] = (value: value, color: color)
    }
    
    func removeTab(for itemType: SCMainTabBarItemType) {
        self.tabBarItemTitles.removeValue(forKey: itemType)
        self.tabBarItemBadges.removeValue(forKey: itemType)
    }
    
    func restoreAllTabs() {
        // nothing to test here? 
    }
    

}

fileprivate class MockAuthTokenProvider: SCAuthTokenProviding & SCLogoutAuthProviding {
    
    func renewAccessTokenIfValid(completion: @escaping (_ result : Bool) ->()) {
        completion(true)
        return
    }

    func fetchAccessToken(completion: @escaping (String?, String?, SCWorkerError?) -> ()) {
        return
    }
    
    func logout(logoutReason: SCLogoutReason,completion: @escaping () -> ()) {
        return
    }
    
    func getRefreshToken() -> String? {
        return nil
    }
    
    func isUserLoggedIn() -> Bool {
        return true
    }
        
}

private class MockUserCityContentSharedWorker: SCUserCityContentSharedWorking {
    var favoriteEventsDataState = SCWorkerDataState()
    
    var appointmentsDataState = SCWorkerDataState()
        
    func getUserCityContentData() -> SCUserCityContentModel? {
        return nil
    }
    
    func update(appointments: [SCModelAppointment]) {}

    func triggerFavoriteEventsUpdate(errorBlock: @escaping (SCWorkerError?) -> ()) {}
        
    func appendFavorite(event: SCModelEvent) {}
    
    func removeFavorite(event: SCModelEvent) {}
    
    func markAppointmentsAsRead() {}

    func getAppointments() -> [SCModelAppointment] {
        return []
    }
    
    func isAppointmentsDataAvailable() -> Bool {
        return true
    }
    
    func triggerAppointmentsUpdate(errorBlock: @escaping (SCWorkerError?) -> ()) {}

    func clearData() {}
}

private class MockBasicPOIGuideWorker: SCBasicPOIGuideWorking {
    var poiDataState = SCWorkerDataState()
    var poiCategoryDataState = SCWorkerDataState()

    func getCityPOI(cityId: String, latitude: Double, longitude: Double, categoryId: String, completion: @escaping (([SCModelPOI], SCWorkerError?) -> Void)) {
        
    }
    
    func getCityPOICategories(cityId: String, completion: @escaping ([SCModelPOICategory], SCWorkerError?) -> Void) {
        
    }
    
    func getCityPOICount(cityId: String, categoryId: String, completion: @escaping (Int, SCWorkerError?) -> Void) {
        
    }
    
    func getCityPOICategories() -> [POICategoryInfo]? {
        return []
    }
    
    func getCityPOI() -> [POIInfo]? {
        return []
    }
    
    func triggerPOICategoriesUpdate(for cityID: Int, errorBlock: @escaping (SCWorkerError?) -> ()) {
        
    }
    
    func triggerPOIUpdate(for cityID: Int, latitude: Double, longitude: Double, categoryId: Int, errorBlock: @escaping (SCWorkerError?) -> ()) {
        
    }
    
    
}
