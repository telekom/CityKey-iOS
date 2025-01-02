//
//  SCDataPrivacyPresenterMock.swift
//  OSCATests
//
//  Created by Bhaskar N S on 08/07/22.
//  Copyright © 2022 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

@testable import OSCA

class SCDataPrivacyPresenterMock: SCDataPrivacyPresenting {
    private(set) var isViewDidLoadCalled: Bool = false
    private(set) var isViewWillAppearCalled: Bool = false
    private(set) var isCloseCalled: Bool = false
    private(set) var isSettingsBtnCalled: Bool = false
    private(set) var isPrepareAndRefreshUICalled: Bool = false
    func setDisplay(_ display: SCDataPrivacyDisplaying) {
        
    }
    
    func closeBtnWasPressed() {
        isCloseCalled = true
    }
    
    func settingsButtonPressed() {
        isSettingsBtnCalled = true
    }
    
    func viewDidLoad() {
        isViewDidLoadCalled = true
    }
    
    func prepareAndRefreshUI() {
        isPrepareAndRefreshUICalled = true
    }
}
