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
