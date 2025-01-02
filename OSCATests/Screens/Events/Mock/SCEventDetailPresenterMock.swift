//
//  SCEventDetailPresenterMock.swift
//  OSCATests
//
//  Created by Bhaskar N S on 23/06/22.
//  Copyright © 2022 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

@testable import OSCA

class SCEventDetailPresenterMock: SCEventDetailPresenting {
    private(set) var isViewDidLoadCalled: Bool = false
    private(set) var isViewWillAppearCalled: Bool = false
    private(set) var isCloseCalled: Bool = false
    private(set) var isshareCalled: Bool = false
    private(set) var isHandleFavoriteCalled: Bool = false
    private(set) var isHandleImageViewCalled: Bool = false
    private(set) var isMoreLinkCalled: Bool = false
    private(set) var isAddToCalendarCalled: Bool = false
    private(set) var isMapViewTapCalled: Bool = false
    private(set) var isDirectionButtonTapped: Bool = false
    private(set) var isRefreshUICalled: Bool = false
    
    func setDisplay(_ display: SCEventDetailDisplaying) {
        
    }
    
    func closeButtonWasPressed() {
        isCloseCalled = true
    }
    
    func shareButtonWasPressed() {
        isshareCalled = true
    }
    
    func moreLinkButtonWasPressed() {
        isMoreLinkCalled = true
    }
    
    func addToCalendardWasPressed() {
        isAddToCalendarCalled = true
    }
    
    func favoriteButtonWasTapped() {
        isHandleFavoriteCalled = true
    }
    
    func imageViewWasTapped() {
        isHandleImageViewCalled = true
    }
    
    func mapViewWasPressed(latitude: Double, longitude: Double, zoomFactor: Float, address: String) {
        isMapViewTapCalled = true
    }
    
    func directionsButtonWasPressed(latitude: Double, longitude: Double, address: String) {
        isDirectionButtonTapped = true
    }
    
    func trackAdjustEvent(_ engagementOption: String) {
        
    }
    
    func viewDidLoad() {
        isViewDidLoadCalled = true
    }
    
    func viewWillAppear() {
        isViewWillAppearCalled = true
    }
    
    func viewDidAppear() {
        
    }
    
    func refreshUI() {
        isRefreshUICalled = true
    }
}
