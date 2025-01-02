//
//  SCDataPrivacyNoticePresenterTests.swift
//  OSCATests
//
//  Created by Bhaskar N S on 08/07/22.
//  Copyright © 2022 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import XCTest
@testable import OSCA

class SCDataPrivacyNoticePresenterTests: XCTestCase {
    
    var displayer: SCDataPrivacyNoticeDisplay!
    
    private func prepareSut(appContentSharedWorker: SCAppContentSharedWorking? = nil) -> SCDataPrivacyNoticePresenter {
        let presenter: SCDataPrivacyNoticePresenter = SCDataPrivacyNoticePresenter(appContentSharedWorker: appContentSharedWorker ?? SCAppContentWorkerMock(),
                                                                                   injector: MockSCInjector())
        return presenter
        
    }
    
    func testViewDidLoad() {
        let mockTitle = LocalizationKeys.SCDataPrivacyNotice.dialogDpnUpdatedTitle.localized()
        let sut = prepareSut()
        let displayer = SCDataPrivacyNoticeDisplayer()
        self.displayer = displayer
        sut.setDisplay(displayer)
        sut.viewDidLoad()
        XCTAssertEqual(mockTitle, displayer.title)
        XCTAssertNotNil(displayer.dpnText)
    }
    
    func testOnAcceptClickedWithNoError() {
        let appContentSharedWorker: SCAppContentSharedWorking = SCAppContentWorkerMock(acceptDataPrivacyNoticeChangeError: nil,
                                                                                       count: 1)
        let sut = prepareSut(appContentSharedWorker: appContentSharedWorker)
        let displayer = SCDataPrivacyNoticeDisplayer()
        self.displayer = displayer
        sut.setDisplay(displayer)
        sut.onAcceptClicked()
        XCTAssertTrue(displayer.isDismissCalled)
    }
    
    func testOnAcceptClickedWithError() {
        let appContentSharedWorker: SCAppContentSharedWorking = SCAppContentWorkerMock(acceptDataPrivacyNoticeChangeError: .noInternet,
                                                                                       count: nil)
        let sut = prepareSut(appContentSharedWorker: appContentSharedWorker)
        let displayer = SCDataPrivacyNoticeDisplayer()
        self.displayer = displayer
        sut.setDisplay(displayer)
        sut.onAcceptClicked()
        XCTAssertTrue(displayer.isResetAcceptCalled)
    }
    
    func testOnShowNoticeClicked() {
        let sut = prepareSut()
        let displayer = SCDataPrivacyNoticeDisplayer()
        self.displayer = displayer
        sut.setDisplay(displayer)
        sut.onShowNoticeClicked()
        XCTAssertTrue(displayer.isPushCalled)
    }
}

class SCDataPrivacyNoticeDisplayer: SCDataPrivacyNoticeDisplay {
    private(set) var title: String = ""
    private(set) var dpnText: NSAttributedString?
    private(set) var isPushCalled: Bool = false
    private(set) var isDismissCalled: Bool = false
    private(set) var isResetAcceptCalled: Bool = false
    
    func setTitle(_ title: String) {
        self.title = title
    }
    
    func updateDPNText(_ string: NSAttributedString) {
        dpnText = string
    }
    
    func push(_ viewController: UIViewController) {
        isPushCalled = true
    }
    
    func dismiss() {
        isDismissCalled = true
    }
    
    func resetAcceptButtonState() {
        isResetAcceptCalled = true
    }
}
