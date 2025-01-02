//
//  SCCityImprintPresenterTests.swift
//  OSCATests
//
//  Created by Bhaskar N S on 15/09/22.
//  Copyright © 2022 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import XCTest
@testable import OSCA

final class SCCityImprintPresenterTests: XCTestCase {
    weak var dispaly: SCCityImprintDisplayer?
    
    private func preparesut(cityContentSharedWorker: SCCityContentSharedWorking? = nil, injector: SCToolsShowing? = nil) -> SCCityImprintPresenter {
        return SCCityImprintPresenter(cityContentSharedWorker: cityContentSharedWorker ?? SCCityContentSharedWorkerMock(),
                                      injector: injector ?? MockSCInjector())
    }
    
    func testViewDidLoad() {
        let sut = preparesut()
        let displayer = SCCityImprintDisplayer()
        sut.setDisplay(displayer)
        sut.viewDidLoad()
        XCTAssertTrue(displayer.isSetupCalled)
        XCTAssertEqual(displayer.cityName, "Bad Honnef")
        XCTAssertEqual(displayer.imprintDesc, "test cityImprintDesc")
    }
    
    func testShowLocationSelector() {
        let mockInjector = MockSCInjector()
        let sut = preparesut(injector: mockInjector)
        let displayer = SCCityImprintDisplayer()
        sut.setDisplay(displayer)
        sut.viewDidLoad()
        sut.locationButtonWasPressed()
        XCTAssertTrue(mockInjector.isShowLocationSelectorCalled)
    }
    
    func testProfileButtonWasPressed() {
        let mockInjector = MockSCInjector()
        let sut = preparesut(injector: mockInjector)
        let displayer = SCCityImprintDisplayer()
        sut.setDisplay(displayer)
        sut.viewDidLoad()
        sut.profileButtonWasPressed()
        XCTAssertTrue(mockInjector.isShowProfileCalled)
    }
    
    func testImprintButtonWasPressed() {
        let mockInjector = MockSCInjector()
        let mockWorker = SCCityContentSharedWorkerMock()
        let sut = preparesut(injector: mockInjector)
        let displayer = SCCityImprintDisplayer()
        sut.setDisplay(displayer)
        sut.viewDidLoad()
        sut.imprintButtonWasPressed()
        XCTAssertNotNil(mockWorker.getCityContentData(for: 13)?.cityImprint)
    }

}

class SCCityImprintDisplayer: SCCityImprintDisplaying {
    private(set) var isSetupCalled: Bool = false
    private(set) var cityName: String?
    private(set) var imprintDesc: String?
    private(set) var coatImageUrl: OSCA.SCImageURL??
    private(set) var imprintImageUrl: OSCA.SCImageURL??
    func setupUI() {
        isSetupCalled = true
    }
    
    func updateCityName(_ cityName: String) {
        self.cityName = cityName
    }
    
    func updateCityImage(withURL: OSCA.SCImageURL?) {
        self.coatImageUrl = withURL
    }
    
    func updateImprintDesc(_ imprintDesc: String?) {
        self.imprintDesc = imprintDesc
    }
    
    func handleAppPreviewBannerView() {
        
    }
    
    func updateImprintImage(withUrl: SCImageURL?) {
        imprintImageUrl = withUrl
    }
}
