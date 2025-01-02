//
//  SCDashboardPresenterMock.swift
//  OSCATests
//
//  Created by Bhaskar N S on 13/06/22.
//  Copyright © 2022 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import Foundation
@testable import OSCA

class SCDashboardPresenterMock: SCPresenting, SCDashboardPresenting {
    
    private(set) var isViewDidLoadCalled: Bool = false
    private(set) var isViewDidAppearCalled: Bool = false
    private(set) var isViewWillAppearCalled: Bool = false
    private(set) var cityName: String = ""
    private(set) var selectedNewsItem: SCBaseComponentItem?
    private(set) var item: SCModelEvent?
    private(set) var wasProfileBtnTapped: Bool = false
    private(set) var geoLocationWasPressed: Bool = false
    private(set) var needsToReloadDataCalled: Bool = false
    
    func setDisplay(_ display: SCDashboardDisplaying) {
        
    }
    
    func didSelectCarouselItem(item: SCBaseComponentItem) {
        selectedNewsItem = item
    }
    
    func didSelectListItem(item: SCBaseComponentItem) {
        self.selectedNewsItem = item
    }
    
    func didSelectListEventItem(item: OSCA.SCModelEvent, isCityChanged: Bool, cityId: Int?) {
        self.item = item
    }
    
    func didPressMoreNewsBtn() {
        
    }
    
    func didPressMoreEventsBtn() {
        
    }
    
    func locationButtonWasPressed() {
        geoLocationWasPressed = true
    }
    
    func profileButtonWasPressed() {
        wasProfileBtnTapped = true
    }
    
    func getDashboardFlags() -> SCDashboardFlags {
        return SCDashboardFlags(showTips: true, showOffers: true, showDiscounts: false)
    }
    
    func needsToReloadData() {
        needsToReloadDataCalled = true
    }
    
    func viewDidLoad() {
        isViewDidLoadCalled = true
    }
    
    func viewWillAppear() {
        isViewWillAppearCalled = true
    }
    
    func viewDidAppear() {
        isViewDidAppearCalled = true
    }
    
    func fetchEventDetail(eventId: String, cityId: Int?, isCityChanged: Bool) {
        
    }
}
