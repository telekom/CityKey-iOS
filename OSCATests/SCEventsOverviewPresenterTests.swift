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
//  SCEventsOverviewPresenterTests.swift
//  SmartCityTests
//
//  Created by Michael on 22.10.19.
//  Copyright © 2019 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import XCTest
import MapKit
@testable import OSCA

class SCEventsOverviewPresenterTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testDateFilterLabel() {
        let eventsOverviewPresenter = SCEventsOverviewPresenter(initialEventItems:[], cityContentSharedWorker: MockCityContentSharedWorker(), userCityContentSharedWorker: MockUserCityContentWorker(), eventWorker: MockEventWorker(), injector: MockMainInjector(), dataCache: MockDataCache())
        
        let emptyFilter = eventsOverviewPresenter.dateFilterDescription(startDate: nil, endDate: nil)
        let onlyStartDateFilter = eventsOverviewPresenter.dateFilterDescription(startDate: dateFromString(dateString: "2019-08-01 00-00-00"), endDate: nil)
        let onlyEndDateFilter = eventsOverviewPresenter.dateFilterDescription(startDate: nil, endDate: dateFromString(dateString: "2019-12-31 00-00-00"))
        let bothDateFilter = eventsOverviewPresenter.dateFilterDescription(startDate: dateFromString(dateString: "2019-08-01 00-00-00"), endDate: dateFromString(dateString: "2019-12-31 00-00-00"))
        
        XCTAssert(emptyFilter.filtername == "e_002_filter_empty_label".localized())
        XCTAssert(onlyStartDateFilter.filtername == "01.Aug - 01.Aug")
        XCTAssert(onlyEndDateFilter.filtername == "e_002_filter_empty_label".localized())
        XCTAssert(bothDateFilter.filtername == "01.Aug - 31.Dec")
   }

    func testCategoriesFilterLabel() {
        let eventsOverviewPresenter = SCEventsOverviewPresenter(initialEventItems:[], cityContentSharedWorker: MockCityContentSharedWorker(), userCityContentSharedWorker: MockUserCityContentWorker(), eventWorker: MockEventWorker(), injector: MockMainInjector(), dataCache: MockDataCache())
        
        let emptyFilter = eventsOverviewPresenter.categoryFilterDescription(categories: nil)
        let noItemsFilter = eventsOverviewPresenter.categoryFilterDescription(categories: [])
        let oneItemsFilter = eventsOverviewPresenter.categoryFilterDescription(categories: [SCModelCategory(categoryName: "Cat1", id: 1)])
        let twoItemsFilter = eventsOverviewPresenter.categoryFilterDescription(categories: [SCModelCategory(categoryName: "Cat1", id: 1), SCModelCategory(categoryName: "Cat2", id: 2)])

        XCTAssert(emptyFilter.filtername == "e_002_filter_empty_label".localized())
        XCTAssert(noItemsFilter.filtername == "e_002_filter_empty_label".localized())
        XCTAssert(oneItemsFilter.filtername == "Cat1")
        XCTAssert(twoItemsFilter.filtername == "Cat1,Cat2")
    }

}

private class MockUserCityContentWorker: SCUserCityContentSharedWorking {

    var favoriteEventsDataState = SCWorkerDataState()

    var appointmentsDataState = SCWorkerDataState()

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

    func triggerAppointmentsUpdate(errorBlock: @escaping (SCWorkerError?) -> ()) {}

    func getAppointments() -> [SCModelAppointment] {
        return []
    }

    func isAppointmentsDataAvailable() -> Bool {
        return true
    }

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
    
    func isCityContentAvailable(for cityID : Int) -> Bool {
        return true
    }
    
    func getCityContentData(for cityID : Int) -> SCCityContentModel? {
        
        let cityModel = SCModelCity.defaultCity()
                
        return SCCityContentModel(city: cityModel, cityImprint: "http:/test.de", cityConfig: SCModelCityConfig.showAll(), cityImprintDesc: "", cityServiceDesc: "", cityNightPicture: SCImageURL(urlString: "", persistence: true), imprintImageUrl: nil)
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

    func triggerCityContentUpdate(for cityID: Int, errorBlock: @escaping (SCWorkerError?) -> ()) {
        errorBlock(nil)
    }
    
    func getCities() -> [CityLocationInfo]? {
        return [CityLocationInfo]()
    }
    
    func triggerCitiesUpdate(errorBlock: @escaping (SCWorkerError?)->()) {
        // Nothing to test here?
    }
    
    func cityInfo(for cityID : Int) -> SCModelCity? {
        return SCModelCity.defaultCity()
    }
    
    func getServiceMoreInfoHTMLText(cityId: String, serviceId: String, completion: @escaping (String, SCWorkerError?) -> Void) {
        // Nothing to test here?
    }
    
    func checkIfDayOrNightTime() -> SCSunriseOrSunset {
        return .sunrise
    }
    
    func updateSelectedCityIdIfNotFoundInCitiesList(errorBlock: ((SCWorkerError?) -> ())?) {
        errorBlock?(nil)
    }
}


private class MockMainInjector: SCEventOverviewInjecting & SCDisplayEventInjecting & SCAdjustTrackingInjection & SCRegistrationInjecting & SCCategoryFilterInjecting & SCWasteCategoryFilterInjecting{
    func getProfileEditDateOfBirthViewController(in flow: OSCA.DateOfBirth, completionHandler: ((String?) -> Void)?) -> UIViewController {
        return UIViewController()
    }

    func getEventDetailController(with event: OSCA.SCModelEvent, isCityChanged: Bool, cityId: Int?) -> UIViewController {
        return UIViewController()
    }
    
    func getEventDetailController(with event: OSCA.SCModelEvent, cityId: Int) -> UIViewController {
        return UIViewController()
    }

    func getRegistrationViewController(completionOnSuccess: ((String, Bool?, String?) -> Void)?) -> UIViewController {
        return UIViewController()    }
    
    func getRegistrationConfirmEMailVC(registeredEmail: String, shouldHideTopImage: Bool, presentationType: SCRegistrationConfirmEMailType, isError:Bool?, errorMessage: String?, completionOnSuccess: (() -> Void)?) -> UIViewController {
         return UIViewController()
        
    }
    
    func getRegistrationConfirmEMailFinishedVC(shouldHideTopImage: Bool, presentationType: SCRegistrationConfirmEMailType, completionOnSuccess: (() -> Void)?) -> UIViewController {
        return UIViewController()    }
    
    func trackEvent(eventName: String) {
        return
    }
    
    func trackEvent(eventName: String, parameters: [String : String]) {
    }
    
    func appWillOpen(url: URL) {
        return
    }
    
    func getDatePickerController(preSelectedStartDate: Date?, preSelectedEndDate: Date?, delegate: SCDatePickerDelegate) -> UIViewController {
        return UIViewController()
    }
    
    func getCategoryFilterViewController(screenTitle: String, selectBtnText: String,filterWorker: SCFilterWorking, preselectedCategories: [SCModelCategory]?, delegate: SCCategorySelectionDelegate) -> UIViewController {
        return UIViewController()
    }
    
    func getCategoryFilterViewController(screenTitle: String, selectBtnText: String,filterWorker: SCWasteFilterWorking, preselectedCategories: [SCModelCategoryObj]?, delegate: SCWasteCategorySelectionDelegate) -> UIViewController {
        return UIViewController()
    }
    
    func showLocationSelector() {
        
    }
    
    func showRegistration() {
        
    }
    
    func showProfile() {
        
    }
    
    func showLogin(completionOnSuccess: (() -> Void)?) {
        
    }
    
    func getCategoryFilterViewController(screenTitle: String, selectBtnText: String, selectAllButtonHidden: Bool?, filterWorker: SCFilterWorking, preselectedCategories: [SCModelCategory]?, delegate: SCCategorySelectionDelegate) -> UIViewController {
        return UIViewController()
    }
    
    func getCategoryFilterViewController(screenTitle: String, selectBtnText: String, selectAllButtonHidden: Bool?, filterWorker: SCWasteFilterWorking, preselectedCategories: [SCModelCategoryObj]?, delegate: SCWasteCategorySelectionDelegate) -> UIViewController {
        return UIViewController()
    }
}

private class MockEventWorker: SCOverviewEventWorking & SCFilterWorking {
    func fetchEventListforOverview(cityID: Int, eventId: String, page: Int?, pageSize: Int?, startDate: Date?, endDate: Date?, categories: [OSCA.SCModelCategory]?, completion: @escaping (OSCA.SCWorkerError?, OSCA.SCModelEventList?) -> ()?) {
        completion(nil, nil)
    }
    
    func fetchEventListCount(cityID: Int, eventId: String, startDate: Date?, endDate: Date?, categories: [OSCA.SCModelCategory]?, completion: @escaping (OSCA.SCWorkerError?, Int) -> ()?) {
        completion(nil, 2)
    }
    
    func fetchCategoryList(cityID: Int, completion: @escaping (SCWorkerError?, [SCModelCategory]?) -> ()?) {
        completion(nil, nil)
    }
    
    func fetchEventListforOverview(cityID: Int, page: Int?, pageSize: Int?, startDate: Date?, endDate: Date?, categories: [SCModelCategory]?, completion: @escaping (SCWorkerError?, SCModelEventList?) -> ()?) {
        
    }
}

private class MockDataCache: SCDataCaching {
    func isDataPrivacyAccepted(for surveyId: Int, cityID: String) -> Bool? {
        return nil
    }

    func setDataPrivacyAccepted(for surveyId: Int, cityID: String) {}
    
    func eventsOverviewData(for cityID: Int) -> SCEventsOverviewData? {
        return nil
    }
    
    func wasteCalendarItems(for cityID: Int) -> [SCModelWasteCalendarItem]?{
        return nil
    }
    
    func storeWasteCalendarItems(_ : [SCModelWasteCalendarItem], for cityID: Int){
        
    }

    func storeEventOverviewData(eventOverviewData: SCEventsOverviewData, for cityID: Int) {
        
    }
    
    func storeLibraryID(libraryId: SCModelBarcodeID, for userID: String) {
        
    }
    
    func getLibraryID(for userID: String) -> SCModelBarcodeID? {
        return nil
    }
    
    func clearCache() {
        
    }
    
    func getWasteCalendarAddress(cityID: Int) -> SCModelWasteCalendarAddress? {
        return nil
    }
    
    func storeWasteCalendar(address: SCModelWasteCalendarAddress, for cityID: Int) {
        
    }

}
