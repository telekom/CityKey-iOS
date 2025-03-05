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
//  SCEventDetailPresenterTests.swift
//  OSCATests
//
//  Created by Bhaskar N S on 23/06/22.
//  Copyright © 2022 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import XCTest
@testable import OSCA

class SCEventDetailPresenterTests: XCTestCase {
    var display: SCEventDetailDisplaying?
    private func prepareSut(worker: SCDetailEventWorking = SCEventDetailWorkerMock(), userContentSharedWorker: SCUserContentSharedWorking = SCUserContentSharedWorker(requestFactory: SCRequestMock()), auth: SCAuthStateProviding = SCAuthMock()) -> SCEventDetailPresenter {
        let eventModel = SCModelEvent(description: "", endDate: "",
                                      startDate: "", hasEndTime: false, hasStartTime: false,
                                      imageURL: SCImageURL(urlString: "", persistence: false),
                                      thumbnailURL: nil, latitude: 1.0, longitude: 1.0,
                                      locationName: "", locationAddress: "",
                                      subtitle: "", title: "", imageCredit: "",
                                      thumbnailCredit: "", pdf: nil,
                                      uid: "", link: "", categoryDescription: "", status: nil)
        let presenter = SCEventDetailPresenter(cityID: 13,
                                               event: eventModel, eventWorker: SCEventWorker(requestFactory: SCRequestMock()),
                                               injector: MockSCInjector(),
                                               worker: worker,
                                               userCityContentSharedWorker: SCUserCityContentSharedWorker(requestFactory: SCRequestMock(),
                                                                                                          cityIdentifier: SCCityContentSharedWorker(requestFactory: SCRequestMock()),
                                                                                                          userIdentifier: SCUserContentSharedWorker(requestFactory: SCRequestMock())),
                                               userContentSharedWorker: userContentSharedWorker,
                                               auth: auth, cityContentSharedWorker: SCCityContentSharedWorkerMock())
        return presenter
    }
    
    func testViewDidLoad() {
        let sut = prepareSut()
        let displayer: SCeventDetailsDisplayer = SCeventDetailsDisplayer()
        self.display = displayer
        sut.setDisplay(displayer)
        sut.viewDidLoad()
        XCTAssertTrue(displayer.isSetEventMarkedAsFavorite)
        XCTAssertTrue(displayer.isSetupUICalled)
    }
    
    func testImageViewWasTapped() {
        let sut = prepareSut()
        let displayer: SCeventDetailsDisplayer = SCeventDetailsDisplayer()
        self.display = displayer
        sut.setDisplay(displayer)
        sut.viewDidLoad()
        sut.imageViewWasTapped()
        XCTAssertTrue(displayer.isPresentFullImageCalled)
    }
    
    func testFavoriteButtonWasTappedWithoutLogin() {
        let mockMessage: String = LocalizationKeys.SCEventDetailPresenter.dialogLoginRequiredMessage.localized()
        let sut = prepareSut()
        let displayer: SCeventDetailsDisplayer = SCeventDetailsDisplayer()
        self.display = displayer
        sut.setDisplay(displayer)
        sut.viewDidLoad()
        sut.favoriteButtonWasTapped()
        XCTAssertTrue(displayer.isShowNeedsToLogin)
        XCTAssertEqual(displayer.loginRequiredMessage, mockMessage)
    }
    
    func testFavoriteButtonWasTappedSuccessWithLogin() {
        let sut = prepareSut(auth: SCAuthMock(loginState: true))
        let displayer: SCeventDetailsDisplayer = SCeventDetailsDisplayer()
        self.display = displayer
        sut.setDisplay(displayer)
        sut.viewDidLoad()
        sut.favoriteButtonWasTapped()
        XCTAssertTrue(displayer.isSetEventMarkedAsFavorite)
    }
    
    func testFavoriteButtonWasTappedFailureWithLogin() {
        let sut = prepareSut(worker: SCEventDetailWorkerMock(error: SCWorkerError.noInternet),
                             auth: SCAuthMock(loginState: true))
        let displayer: SCeventDetailsDisplayer = SCeventDetailsDisplayer()
        self.display = displayer
        sut.setDisplay(displayer)
        sut.viewDidLoad()
        sut.favoriteButtonWasTapped()
        XCTAssertTrue(displayer.isSetEventMarkedAsFavorite)
        XCTAssertFalse(displayer.isFavorite)
    }
    
    func testCloseButtonWasPressedWithOverlayVisible() {
        let sut = prepareSut(auth: SCAuthMock(loginState: true))
        let displayer: SCeventDetailsDisplayer = SCeventDetailsDisplayer()
        self.display = displayer
        displayer.isOverlayVisisble = true
        sut.setDisplay(displayer)
        sut.viewDidLoad()
        sut.closeButtonWasPressed()
        XCTAssertTrue(displayer.isShowMoreInfoOverlayCalled)
        
    }
    
    func testCloseButtonWasPressedWithOverlayNotVisible() {
        let sut = prepareSut(auth: SCAuthMock(loginState: true))
        let displayer: SCeventDetailsDisplayer = SCeventDetailsDisplayer()
        self.display = displayer
        displayer.isOverlayVisisble = false
        sut.setDisplay(displayer)
        sut.viewDidLoad()
        sut.closeButtonWasPressed()
        XCTAssertTrue(displayer.isDismissCalled)
    }
    
    func testAddToCalendardWasPressedWithoutLogin() {
        let sut = prepareSut(auth: SCAuthMock(loginState: false))
        let displayer: SCeventDetailsDisplayer = SCeventDetailsDisplayer()
        self.display = displayer
        sut.setDisplay(displayer)
        sut.viewDidLoad()
        sut.addToCalendardWasPressed()
        XCTAssertTrue(displayer.isShowNeedsToLogin)
    }
    
    func testAddToCalendardWasPressedWithLogin() {
        let sut = prepareSut(auth: SCAuthMock(loginState: false))
        let displayer: SCeventDetailsDisplayer = SCeventDetailsDisplayer()
        self.display = displayer
        sut.setDisplay(displayer)
        sut.viewDidLoad()
        sut.addToCalendardWasPressed()
        XCTAssertTrue(displayer.isShowNeedsToLogin)
    }
}

class SCAuthMock: SCAuthStateProviding {
    let loginState: Bool
    init(loginState: Bool = false) {
        self.loginState = loginState
    }
    func isUserLoggedIn() -> Bool {
        return loginState
    }
}

extension SCAuthMock: SCLoginAuthProviding {
    func login(name: String, password: String, remember: Bool, completion: @escaping (OSCA.SCWorkerError?) -> ()) {
        completion(nil)
    }
    
    func logoutReason() -> OSCA.SCLogoutReason? {
        return nil
    }
    
    func clearLogoutReason() {
        
    }
}

class SCeventDetailsDisplayer: SCEventDetailDisplaying {
    
    func setupUI(navTitle: String, title: String, description: String, endDate: Date, startDate: Date, hasEndTime: Bool, hasStartTime: Bool, imageURL: SCImageURL?, latitude: Double, longitude: Double, locationName: String, locationAddress: String, imageCredit: String, category: String, pdf: [String]?, link: String, isFavorite: Bool, eventStatus: EventStatus) {
        isSetupUICalled = true
    }
    
    private(set) var isSetEventMarkedAsFavorite: Bool = false
    private(set) var isSetupUICalled: Bool = false
    private(set) var isPresentFullImageCalled: Bool = false
    private(set) var isShowNeedsToLogin: Bool = false
    private(set) var loginRequiredMessage: String = ""
    private(set) var isFavorite: Bool = false
    var isOverlayVisisble: Bool = false
    private(set) var isShowMoreInfoOverlayCalled: Bool = false
    private(set) var isDismissCalled: Bool = false
    private(set) var isPresentCalled: Bool = false
    
    func showMoreInfoOverlay(_ show: Bool) {
        isShowMoreInfoOverlayCalled = true
    }
    
    func isShowMoreInfoOverlayVisible() -> Bool {
        return isOverlayVisisble
    }
    
    func setEventMarkedAsFavorite(isFavorite: Bool) {
        self.isFavorite = isFavorite
        isSetEventMarkedAsFavorite = true
    }
    
    func showNeedsToLogin(with text: String, cancelCompletion: (() -> Void)?, loginCompletion: @escaping (() -> Void)) {
        isShowNeedsToLogin = true
        loginRequiredMessage = text
    }
    
    func removeBlurView() {
        
    }
    
    func dismiss(completion: (() -> Void)?) {
        isDismissCalled = true
    }
    
    func push(viewController: UIViewController) {
        
    }
    
    func present(viewController: UIViewController) {
        isPresentCalled = true
    }
    
    func presentSnackBar(snackBarViewController: UIViewController, completion: (() -> Void)?) {
        
    }
    
    func presentFullImage(viewController: UIViewController) {
        isPresentFullImageCalled = true
    }
    
    func hideMapView() {
        
    }
    
    
}

class SCEventDetailWorkerMock: SCDetailEventWorking {
    let error: SCWorkerError?
    init(error: SCWorkerError? = nil) {
        self.error = error
    }
    func saveEventAsFavorite(cityID: Int, eventId: Int, markAsFavorite: Bool, completion: @escaping (SCWorkerError?) -> ()?) {
        completion(error)
    }
}

extension MockSCInjector: SCEventDetailInjecting {
    func getEventDetailMapController(latitude: Double, longitude: Double, zoomFactor: Float, address: String, locationName: String, tintColor: UIColor) -> UIViewController {
        return UINavigationController()
    }
    
    func getEventLightBoxController(_with imageURL: SCImageURL, _and credit: String) -> UIViewController {
        return SCEventLightBoxViewController()
    }
}

extension MockSCInjector: SCToolsInjecting {
    func setToolsShower(_ shower: SCToolsShowing) {

    }
    
    func getLocationViewController(presentationMode: SCLocationPresentationMode, includeNavController: Bool, completionAfterDismiss: (() -> Void)?) -> UIViewController {
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
    
    func getForceUpdateVersionViewController() -> UIViewController {
        return UIViewController()
    }
    
    func getVersionInformationViewController() -> UIViewController{
        return UIViewController()
    }
}
