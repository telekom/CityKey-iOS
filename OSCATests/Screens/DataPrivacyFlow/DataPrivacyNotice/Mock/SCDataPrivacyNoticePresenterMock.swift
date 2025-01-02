//
//  SCDataPrivacyNoticePresenterMock.swift
//  OSCATests
//
//  Created by Bhaskar N S on 08/07/22.
//  Copyright © 2022 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

@testable import OSCA
class SCDataPrivacyNoticePresenterMock: SCDataPrivacyNoticePresenting {
    private(set) var isViewDidLoadCalled: Bool = false
    private(set) var onAccpetCalled: Bool = false
    private(set) var onShowNoticeClickedCalled: Bool = false

    func onAcceptClicked() {
        onAccpetCalled = true
    }
    
    func onShowNoticeClicked() {
        onShowNoticeClickedCalled = true
    }
    
    func setDisplay(_ display: SCDataPrivacyNoticeDisplay) {
        
    }
    
    func viewDidLoad() {
        isViewDidLoadCalled = true
    }
}
