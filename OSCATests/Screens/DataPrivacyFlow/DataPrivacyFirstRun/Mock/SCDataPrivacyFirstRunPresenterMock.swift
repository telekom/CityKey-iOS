//
//  SCDataPrivacyFirstRunPresenterMock.swift
//  OSCATests
//
//  Created by Bhaskar N S on 11/07/22.
//  Copyright © 2022 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

@testable import OSCA

class SCDataPrivacyFirstRunPresenterMock: SCDataPrivacyFirstRunPresenting {
    private(set) var isViewDidLoadCalled: Bool = false
    private(set) var isChangeSettingsPressed: Bool = false
    private(set) var isAcceptAllPressed: Bool = false
    private(set) var isAcceptSelectedLinkPressed: Bool = false
    private(set) var isDataPrivacyNoticeLinkPressed: Bool = false
    var completionHandler: (() -> Void)?
    
    func setDisplay(_ display: SCDataPrivacyFirstRunDisplay) {
        
    }
    
    func changeSettingsPressed() {
        isChangeSettingsPressed = true
    }
    
    func acceptAllPressed() {
        isAcceptAllPressed = true
    }
    
    func acceptSelectedLinkPressed() {
        isAcceptSelectedLinkPressed = true
    }
    
    func dataPrivacyNoticeLinkPressed() {
        isDataPrivacyNoticeLinkPressed = true
    }
    
    func viewDidLoad() {
        isViewDidLoadCalled = true
    }
}
