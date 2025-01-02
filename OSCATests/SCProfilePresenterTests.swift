//
//  SCProfilePresenterTests.swift
//  SmartCityTests
//
//  Created by Robert Swoboda - Telekom on 28.06.19.
//  Copyright © 2019 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import XCTest
@testable import OSCA

class SCProfilePresenterTests: XCTestCase {

    static let testProfile = SCModelProfile(accountId : 2, birthdate: Date(timeIntervalSince1970: TimeInterval(1561780587)), email: "test@tester.de", postalCode: "63739", homeCityId: 10, cityName: "Teststadt", dpnAccepted: true)
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testProfilePresenterViewDidLoad() {
        // test, if the display get configured correctly when presenter gets a viewDidLoad
        
        let profilePresenter = SCProfilePresenter(profileWorker: MockProfileWorker(), userContentSharedWorker: MockUserContentSharedWorker(), appContentSharedWorker: MockAppContentWorker(), authProvider: MockLogoutAuthProvider(), injector: MockInjector())
        
        let display = MockProfileDisplay()
        profilePresenter.setDisplay(display)
        profilePresenter.viewDidLoad()
        
        // be careful: date strings depend on the locale, could be "de" on local machine, "en" on build server
        // difficult to test. We would need to inject the locale into the presenter to avoid this
        XCTAssertEqual(display.birthdateString, "29. June 2019") //"29.06.2019")
        XCTAssertEqual(display.postalCode, "63739 Teststadt")
    }
}

private class MockAppContentWorker: SCAppContentSharedWorking {
    
    func acceptDataPrivacyNoticeChange(completion: @escaping (SCWorkerError?, Int?) -> Void) {
        
    }
    
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
    
    
    var termsDataState =  SCWorkerDataState()

    var firstTimeUsageFinished: Bool = true
    
    var switchLocationToolTipShouldBeShown: Bool = true

    var trackingPermissionFinished: Bool = true
    
    func getDataSecurity() -> SCModelTermsDataSecurity? {
        return nil
    }
        
    var privacyOptOutMoEngage: Bool = false
    
    var privacyOptOutAdjust: Bool = false
    
    var isCityActive: Bool = true

    var isToolTipShown: Bool = true

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
    

}

fileprivate class MockProfileDisplay: SCProfileDisplaying {
    
    public var birthdateString: String?
    public var postalCode: String?
    public var email: String?
    
    func setResidenceName(_ postalCode: String) {
         self.postalCode = postalCode
    }
    
    func setBirthDate(_ birthDate: String) {
         self.birthdateString = birthDate
    }
    
    func setEmail(_ email: String) {
         self.email = email
    }
    
    func setPassword(_ password: String) {
        
    }
    
    func setAppPreviewMode(_ isCSPUser: Bool, isPreviewMode: Bool) {

    }
    
    func dismiss(completion: (() -> Void)?) {
        
    }
    
    func push(viewController: UIViewController) {
        
    }
    
    func endRefreshing() {
        
    }
    
    func showErrorDialog(with text: String) {
        
    }
    
    func showNoInternetAvailableDialog() {
        
    }
    
    func showErrorDialog(_ error: SCWorkerError) {
        
    }

    func setLogoutButtonState(_ state : SCCustomButtonState){
        
    }

}

fileprivate class MockProfileWorker: SCProfileWorking {
    
}

fileprivate class MockUserContentSharedWorker: SCUserContentSharedWorking {
    
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
        return SCModelUserData(userID: "id1", cityID: "city1", profile: SCProfilePresenterTests.testProfile)
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
    
    func markInfoBoxItem(id : Int, read : Bool){
        
    }
    
    func removeInfoBoxItem(id : Int) {
        
    }

    func clearData(){
        
    }

}

fileprivate class MockLogoutAuthProvider: SCLogoutAuthProviding & SCLoginAuthProviding{
    
    func isUserLoggedIn() -> Bool {
        return true
    }
        
    func logout(logoutReason: SCLogoutReason, completion: @escaping () -> ()) {
        completion()
    }
    
    func login(name: String, password: String, remember: Bool,
               completion: @escaping (SCWorkerError?) -> ()){
        completion(nil)
    }
    
    func logoutReason() -> SCLogoutReason?{
        return .technicalReason
    }
    
    func clearLogoutReason() {
        
    }
}

fileprivate class MockInjector: SCToolsInjecting & SCLegalInfoInjecting & SCProfileInjecting & SCToolsShowing & SCAdjustTrackingInjection & SCWebContentInjecting {
    func getWebContentViewController(for url: String, title: String?, insideNavCtrl: Bool, itemServiceParams: [String : String]?, serviceFunction: String?) -> UIViewController {
        return UIViewController()
    }
    
    func registerRemotePushForApplication() {
        
    }
    
    func getVersionInformationViewController() -> UIViewController {
        return UIViewController()
    }
    
    func getForceUpdateVersionViewController() -> UIViewController {
        return UIViewController()
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
    
    func getFeedbackController() -> UIViewController {
        return UIViewController()
    }
    
    func getFeedbackConfirmationViewController() -> UIViewController {
        return UIViewController()
    }
    
    
    func getProfileEditPersonalDataOverviewViewController(postcode: String, profile: SCModelProfile) -> UIViewController {
        return UIViewController()
    }
    
    func getWebContentViewController(for url: String, title: String?, insideNavCtrl: Bool) -> UIViewController {
        return UIViewController()
    }
    
    func getWebContentViewController(forHtmlString htmlString: String, title : String?, insideNavCtrl: Bool) -> UIViewController {
        return UIViewController()
    }
    
    func getDataPrivacyController(preventSwipeToDismiss: Bool, shouldPushSettingsController: Bool) -> UIViewController {
        return UIViewController()
    }
    
    func getDataPrivacyFirstRunController(preventSwipeToDismiss: Bool, completionHandler: (() -> Void)?) -> UIViewController {
        
        return UIViewController()
    }
    
    func getDataPrivacySettingsController(shouldPushDataPrivacyController: Bool, preventSwipeToDismiss: Bool, isFirstRunSettings: Bool, completionHandler: (() -> Void)?) -> UIViewController {
        
        return UIViewController()
    }
    
    func getTextViewContentViewController(forHtmlString htmlString: String, title : String?, insideNavCtrl: Bool) -> UIViewController {
        
        return UIViewController()
    }
    
    func getInfoNoticeController(title: String, content: String, insideNavCtrl: Bool) -> UIViewController{
        return UIViewController()
    }
    
    func getDataPrivacyNoticeController(insideNavCtrl: Bool) -> UIViewController {
        return UIViewController()
    }
    
    func trackEvent(eventName: String) {
        
    }
    
    func trackEvent(eventName: String, parameters: [String : String]) {
        
    }
    
    func appWillOpen(url: URL) {
        
    }
    
    func getProfileEditOverviewViewController(email: String) -> UIViewController {
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

    func getTextInWebViewContentViewController(forHtmlString htmlString: String, title: String?, insideNavCtrl: Bool) -> UIViewController {
        return UIViewController()
    }
}

extension MockInjector: SCRegistrationInjecting {
    func getRegistrationConfirmEMailVC(registeredEmail: String, shouldHideTopImage: Bool, presentationType: OSCA.SCRegistrationConfirmEMailType, isError: Bool?, errorMessage: String?, completionOnSuccess: (() -> Void)?) -> UIViewController {
        return UIViewController()
    }

    func getRegistrationConfirmEMailFinishedVC(shouldHideTopImage: Bool, presentationType: OSCA.SCRegistrationConfirmEMailType, completionOnSuccess: (() -> Void)?) -> UIViewController {
        return UIViewController()
    }
    
    func getProfileEditDateOfBirthViewController(in flow: DateOfBirth, completionHandler: ((String?) -> Void)?) -> UIViewController {
        return UIViewController()
    }
}

