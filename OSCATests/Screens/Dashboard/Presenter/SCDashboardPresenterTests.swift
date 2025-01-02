//
//  SCDashboardPresenterTests.swift
//  OSCATests
//
//  Created by Bhaskar N S on 10/06/22.
//  Copyright © 2022 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import XCTest
@testable import OSCA

class SCDashboardPresenterTests: XCTestCase {
    
    private var dashboardDisplayer: SCDashboardDisplaying!
    
    private func prepareSut(userContentSharedWorker: SCUserContentSharedWorking? = nil,
                            cityContentSharedWorker: SCCityContentSharedWorking? = nil) -> SCDashboardPresenter {
        let presenter: SCDashboardPresenter =  SCDashboardPresenter(dashboardWorker: SCDashboardWorker(requestFactory: SCRequestMock()),
                                                                    cityContentSharedWorker: cityContentSharedWorker ?? SCCityContentSharedWorker(requestFactory: SCRequestMock()),
                                                                    userContentSharedWorker: userContentSharedWorker ?? SCUserContentSharedWorker(requestFactory: SCRequestMock()),
                                                                    userCityContentSharedWorker: SCUserCityContentSharedWorker(requestFactory: SCRequestMock(),
                                                                                                                               cityIdentifier: SCCityContentSharedWorker(requestFactory: SCRequestMock()),
                                                                                                                               userIdentifier: SCUserContentSharedWorker(requestFactory: SCRequestMock())),
                                                                    dashboardEventWorker: SCEventWorker(requestFactory: SCRequestMock()),
                                                                    appContentSharedWorker: SCAppContentSharedWorker(requestFactory: SCRequestMock()),
                                                                    injector: MockSCInjector(),
                                                                    refreshHandler: MockRefreshHandler(),
                                                                    authProvider: SCAuthMock())
        let displayer: SCDashboardDisplaying = SCDashboardDisplayer()
        presenter.setDisplay(displayer)
        return presenter
    }
    
    func testViewDidLoad() {
        let sut = prepareSut()
        let displayer = SCDashboardDisplayer()
        self.dashboardDisplayer = displayer
        sut.setDisplay(displayer)
        sut.viewDidLoad()
        XCTAssertTrue(displayer.isEndRefreshingCalled)
    }
    
    func testLocationButtonWasPressed() {
        let sut = prepareSut()
        let displayer = SCDashboardDisplayer()
        self.dashboardDisplayer = displayer
        sut.setDisplay(displayer)
        sut.locationButtonWasPressed()
        XCTAssertTrue(displayer.isHideChangeLocationToolTip)
    }
    
    func testProfileButtonWasPressed() {
        let sut = prepareSut()
        let displayer = SCDashboardDisplayer()
        self.dashboardDisplayer = displayer
        sut.setDisplay(displayer)
        sut.profileButtonWasPressed()
        guard let injector = sut.injector as? MockSCInjector else {
            XCTFail("Test Failed")
            return
        }
        XCTAssertTrue(displayer.isHideChangeLocationToolTip)
        XCTAssertTrue(injector.isShowProfileCalled)
    }
    
    func testCheckForDPNChangedWhenTrue() {
        
        let userContentSharedWorker = SCUserContentSharedWorkerMock()
        userContentSharedWorker.userDataState.dataLoadingState = .fetchedWithSuccess
        
        let sut = prepareSut(userContentSharedWorker: userContentSharedWorker)
        let displayer = SCDashboardDisplayer()
        self.dashboardDisplayer = displayer
        sut.setDisplay(displayer)
        sut.profileButtonWasPressed()
        sut.checkForDPNChanged()
    }
    
//    func testCheckForDPNChangedWhenFalse() {
//
//        let userContentSharedWorker = SCUserContentSharedWorkerMock()
//        let profile = SCModelProfile(accountId : 2, birthdate: Date(timeIntervalSince1970: TimeInterval(1561780587)), email: "test@tester.de", postalCode: "63739", homeCityId: 10, cityName: "Teststadt", dpnAccepted: false)
//        userContentSharedWorker.userDataState.dataLoadingState = .fetchedWithSuccess
//        userContentSharedWorker.profileModel = profile
//        let sut = prepareSut(userContentSharedWorker: userContentSharedWorker)
//        let displayer = SCDashboardDisplayer()
//        self.dashboardDisplayer = displayer
//        sut.setDisplay(displayer)
//        sut.profileButtonWasPressed()
//        sut.checkForDPNChanged()
//        let expections = expectation(description: "CheckForDPNChangedWhenFalse")
//        Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { [weak sut] timer  in
//            guard sut != nil else {
//                XCTFail("Test Failed")
//                return
//            }
//            XCTAssertTrue(displayer.isPresentDPNViewController)
//            expections.fulfill()
//        }
//        waitForExpectations(timeout: 3.0, handler: nil)
//    }
    
    func testDidSelectCarouselItem() {
        let sut = prepareSut()
        let displayer = SCDashboardDisplayer()
        self.dashboardDisplayer = displayer
        sut.setDisplay(displayer)
        let item = SCBaseComponentItem(itemID: "", itemTitle: "", itemHtmlDetail: false, itemColor: .blue)
        sut.didSelectCarouselItem(item: item)
        XCTAssertTrue(displayer.isHideChangeLocationToolTip)
        XCTAssertTrue(displayer.isPushCalled)
    }
    
    func testDidSelectListItem() {
        let sut = prepareSut()
        let displayer = SCDashboardDisplayer()
        self.dashboardDisplayer = displayer
        sut.setDisplay(displayer)
        let item = SCBaseComponentItem(itemID: "", itemTitle: "", itemHtmlDetail: false, itemColor: .blue)
        sut.didSelectListItem(item: item)
        XCTAssertTrue(displayer.isHideChangeLocationToolTip)
        XCTAssertTrue(displayer.isPushCalled)
    }
    
    func testDidSelectListEventItem() {
        let sut = prepareSut()
        let displayer = SCDashboardDisplayer()
        self.dashboardDisplayer = displayer
        sut.setDisplay(displayer)
        let item = SCModelEvent(description: "", endDate: "", startDate: "", hasEndTime: true,
                                hasStartTime: true, imageURL: SCImageURL(urlString: "", persistence: false),
                                thumbnailURL: nil, latitude: 1.0, longitude: 1.0, locationName: "",
                                locationAddress: "", subtitle: "", title: "", imageCredit: "",
                                thumbnailCredit: "", pdf: nil, uid: "", link: "", categoryDescription: "",
                                status: nil)
        sut.events = [item]
        sut.didSelectListEventItem(item: item, isCityChanged: false, cityId: nil)
        XCTAssertTrue(displayer.isHideChangeLocationToolTip)
        XCTAssertTrue(displayer.isPushCalled)
    }
    
    func testDidPressMoreNewsBtn() {
        let userContentSharedWorker = SCUserContentSharedWorkerMock()
        userContentSharedWorker.userDataState.dataLoadingState = .fetchedWithSuccess
        
        let cityContentSharedWorker = SCCityContentSharedWorkerMock()
        let sut = prepareSut(userContentSharedWorker: userContentSharedWorker, cityContentSharedWorker: cityContentSharedWorker)
        
        let displayer = SCDashboardDisplayer()
        self.dashboardDisplayer = displayer
        sut.setDisplay(displayer)
        sut.viewDidLoad()
        sut.news = [SCModelMessage(id: "", title: "", shortText: "", subtitleText: "", detailText: "", contentURL: nil,
                                   imageURL: nil, imageCredit: nil, thumbnailURL: nil, type: .news, date: Date(), sticky: false),
                    SCModelMessage(id: "", title: "", shortText: "", subtitleText: "", detailText: "", contentURL: nil,
                                    imageURL: nil, imageCredit: nil, thumbnailURL: nil, type: .news, date: Date(), sticky: false)]
        sut.didPressMoreNewsBtn()
        XCTAssertTrue(displayer.isHideChangeLocationToolTip)
        XCTAssertTrue(displayer.isPushCalled)
        
    }
    
    func testDidPressMoreEventsBtn() {
        let userContentSharedWorker = SCUserContentSharedWorkerMock()
        userContentSharedWorker.userDataState.dataLoadingState = .fetchedWithSuccess
        
        let cityContentSharedWorker = SCCityContentSharedWorkerMock()
        let sut = prepareSut(userContentSharedWorker: userContentSharedWorker, cityContentSharedWorker: cityContentSharedWorker)
        
        let displayer = SCDashboardDisplayer()
        self.dashboardDisplayer = displayer
        sut.setDisplay(displayer)
        sut.viewDidLoad()
        sut.events = [SCModelEvent(description: "", endDate: "", startDate: "", hasEndTime: true,
                                   hasStartTime: true, imageURL: SCImageURL(urlString: "", persistence: false),
                                   thumbnailURL: nil, latitude: 1.0, longitude: 1.0, locationName: "",
                                   locationAddress: "", subtitle: "", title: "", imageCredit: "",
                                   thumbnailCredit: "", pdf: nil, uid: "", link: "", categoryDescription: "",
                                   status: nil),
                      SCModelEvent(description: "", endDate: "", startDate: "", hasEndTime: true,
                                                              hasStartTime: true, imageURL: SCImageURL(urlString: "", persistence: false),
                                                              thumbnailURL: nil, latitude: 1.0, longitude: 1.0, locationName: "",
                                                              locationAddress: "", subtitle: "", title: "", imageCredit: "",
                                                              thumbnailCredit: "", pdf: nil, uid: "", link: "", categoryDescription: "",
                                                              status: nil)]
        sut.didPressMoreEventsBtn()
        XCTAssertTrue(displayer.isHideChangeLocationToolTip)
        XCTAssertTrue(displayer.isPushCalled)
    }

}

class SCDashboardDisplayer: SCDashboardDisplaying {
    private(set) var isEndRefreshingCalled: Bool = false
    private(set) var isHideChangeLocationToolTip: Bool = false
    private(set) var isPresentDPNViewController: Bool = false
    private(set) var isPushCalled: Bool = false
    func setHeaderImageURL(_ url: SCImageURL?) {
        
    }
    
    func setCoatOfArmsImageURL(_ url: SCImageURL) {
        
    }
    
    func setWelcomeText(_ text: String) {
        
    }
    
    func setCityName(_ name: String) {
        
    }
    
    func setWeatherInfo(_ info: String) {
        
    }
    
    func customize(color: UIColor) {
        
    }
    
    func resetUI() {
        
    }
    
    func updateNews(with dataItems: [SCBaseComponentItem]) {
        
    }
    
    func updateEvents(with dataItems: [SCModelEvent]?, favorites: [SCModelEvent]?) {
        
    }
    
    func showNewsActivityInfoOverlay() {
        
    }
    
    func showNewsErrorInfoOverlay(infoText: String) {
        
    }
    
    func hideNewsInfoOverlay() {
        
    }
    
    func showEventsActivityInfoOverlay() {
        
    }
    
    func showEventsErrorInfoOverlay(infoText: String) {
        
    }
    
    func hideEventsInfoOverlay() {
        
    }
    
    func configureContent() {
        
    }
    
    func navigationController() -> UINavigationController? {
        return nil
    }
    
    func push(viewController: UIViewController) {
        isPushCalled = true
    }
    
    func present(viewController: UIViewController) {
        
    }
    
    func presentDPNViewController(viewController: UIViewController) {
        isPresentDPNViewController = true
    }
    
    func showNavigationBar(_ visible: Bool) {
        
    }
    
    func endRefreshing() {
        isEndRefreshingCalled = true
    }
    
    func endRefreshingEventContent() {
        
    }
    
    func showChangeLocationToolTip() {
        
    }
    
    func hideChangeLocationToolTip() {
        isHideChangeLocationToolTip = true
    }
    
    func handleAppPreviewBannerView() {
        
    }
}

class MockSCDashboardWorker: SCDashboardWorking {
    
}

//class MockSCCityContentSharedWorker: SCCityContentSharedWorking {
//    var citiesDataState: SCWorkerDataState
//    
//    var cityContentDataState: SCWorkerDataState
//    
//    var newsDataState: SCWorkerDataState
//    
//    var servicesDataState: SCWorkerDataState
//    
//    var weatherDataState: SCWorkerDataState
//    
//    func getCities() -> [CityLocationInfo]? {
//        <#code#>
//    }
//    
//    func triggerCitiesUpdate(errorBlock: @escaping (SCWorkerError?) -> ()) {
//        <#code#>
//    }
//    
//    func isCityContentAvailable(for cityID: Int) -> Bool {
//        <#code#>
//    }
//    
//    func getNews(for cityID: Int) -> [SCModelMessage]? {
//        <#code#>
//    }
//    
//    func getServices(for cityID: Int) -> [SCModelServiceCategory]? {
//        <#code#>
//    }
//    
//    func getWeather(for cityID: Int) -> String {
//        <#code#>
//    }
//    
//    func getCityContentData(for cityID: Int) -> SCCityContentModel? {
//        <#code#>
//    }
//    
//    func triggerCityContentUpdate(for cityID: Int, errorBlock: @escaping (SCWorkerError?) -> ()) {
//        <#code#>
//    }
//    
//    func cityInfo(for cityID: Int) -> SCModelCity? {
//        <#code#>
//    }
//    
//    func cityIDForPostalCode(postalcode: String) -> Int? {
//        <#code#>
//    }
//    
//    func setStoredCityID(for cityID: Int) {
//        <#code#>
//    }
//    
//    func setStoredCityLocation(for cityLocation: CLLocation) {
//        <#code#>
//    }
//    
//    func getServiceMoreInfoHTMLText(cityId: String, serviceId: String, completion: @escaping (String, SCWorkerError?) -> Void) {
//        <#code#>
//    }
//    
//    func checkIfDayOrNightTime() -> SCSunriseOrSunset {
//        <#code#>
//    }
//    
//    func getCityID() -> Int {
//        <#code#>
//    }
//    
//    func getCityLocation() -> CLLocation {
//        <#code#>
//    }
//    
//    
//}

class MockRefreshHandler: SCSharedWorkerRefreshHandling {
    var display: SCDisplaying?
    
    func renewSession(completion: @escaping () -> ()) {
        completion()
        return
    }
    func reloadContent(force: Bool) {
        
    }
    
    func reloadUserInfoBox(){
        
    }
    
    func showCitySelector() {
        
    }
    
    func reloadServices() {
        
    }
}
