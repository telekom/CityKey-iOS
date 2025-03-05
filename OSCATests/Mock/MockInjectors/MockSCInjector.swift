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
//  MockSCInjector.swift
//  OSCATests
//
//  Created by Bhaskar N S on 28/06/24.
//  Copyright © 2024 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import Foundation
import UIKit
@testable import OSCA


class MockSCInjector: SCInjecting {
    var isTrackEventCalled: Bool = false
    private(set) var isShowLocationSelectorCalled: Bool = false
    private(set) var isShowProfileCalled: Bool = false
}

extension MockSCInjector: SCAdjustTrackingInjection {
    func trackEvent(eventName: String) {
        isTrackEventCalled = true
    }
    
    func trackEvent(eventName: String, parameters: [String : String]) {
        isTrackEventCalled = true
    }
    
    func appWillOpen(url: URL) {
        
    }
}

extension MockSCInjector: SCDashboardInjecting {
    func getNewsOverviewController(with itemList: [SCBaseComponentItem]) -> UIViewController {
        return UIViewController()
    }
    
    func getEventsOverviewController(with eventList: SCModelEventList) -> UIViewController {
        return UIViewController()
    }
    
    func showLocationSelector() {
        isShowLocationSelectorCalled = true
    }
    
    func showRegistration() {
        
    }
    
    func showProfile() {
        isShowProfileCalled = true
    }
    
    func showLogin(completionOnSuccess: (() -> Void)?) {
        
    }
}

extension MockSCInjector: SCDisplayEventInjecting {
    func getEventDetailController(with event: OSCA.SCModelEvent, isCityChanged: Bool, cityId: Int?) -> UIViewController {
        return UIViewController()
    }
    
    func getEventDetailController(with event: SCModelEvent) -> UIViewController {
        return UIViewController()
    }
}

extension MockSCInjector: SCLegalInfoInjecting {
    
    func registerRemotePushForApplication() {
        
    }
    
    func getDataPrivacyController(preventSwipeToDismiss: Bool, shouldPushSettingsController: Bool) -> UIViewController {
        return UIViewController()
    }
    
    func getInfoNoticeController(title: String, content: String, insideNavCtrl: Bool) -> UIViewController {
        return UIViewController()
    }
    
    func getDataPrivacyNoticeController(insideNavCtrl: Bool) -> UIViewController {
        return UIViewController()
    }
    
    func getDataPrivacyFirstRunController(preventSwipeToDismiss: Bool, completionHandler: (() -> Void)?) -> UIViewController {
        return UIViewController()
    }
    
    func getDataPrivacySettingsController(shouldPushDataPrivacyController: Bool, preventSwipeToDismiss: Bool, isFirstRunSettings: Bool, completionHandler: (() -> Void)?) -> UIViewController {
        return UIViewController()
    }
}

extension MockSCInjector: SCEditPasswordInjecting {
    func getEditPasswordFinishedViewController(email: String) -> UIViewController {
        return UIViewController()
    }
    
    func getPWDForgottenViewController(email: String, completionOnSuccess: ((String, Bool, Bool?, String?) -> Void)?) -> UIViewController {
        return UIViewController()
    }
}

extension MockSCInjector: SCRegistrationInjecting {
    func getProfileEditDateOfBirthViewController(in flow: OSCA.DateOfBirth, completionHandler: ((String?) -> Void)?) -> UIViewController {
        return UIViewController()
    }
    
    func getRegistrationViewController(completionOnSuccess: ((String, Bool?, String?) -> Void)?) -> UIViewController {
        return UIViewController()
    }
    
    func getRegistrationConfirmEMailVC(registeredEmail: String, shouldHideTopImage: Bool, presentationType: SCRegistrationConfirmEMailType, isError: Bool?, errorMessage: String?, completionOnSuccess: (() -> Void)?) -> UIViewController {
        return UIViewController()
    }
    
    func getRegistrationConfirmEMailFinishedVC(shouldHideTopImage: Bool, presentationType: SCRegistrationConfirmEMailType, completionOnSuccess: (() -> Void)?) -> UIViewController {
        return UIViewController()
    }
}

extension MockSCInjector: SCBasicPOIGuideServiceInjecting {
    func getBasicPOIGuideCategoryViewController(with poiCategory: [OSCA.POICategoryInfo], includeNavController: Bool, completionAfterDismiss: (() -> Void)?) -> UIViewController {
        return UIViewController()
    }
    
    func getBasicPOIGuideListMapViewController(with poi: [OSCA.POIInfo], poiCategory: [OSCA.POICategoryInfo], item: OSCA.SCBaseComponentItem) -> UIViewController {
        return UIViewController()
    }
    
    
}

extension MockSCInjector: SCDisplayBasicPOIGuideInjecting {
    func getBasicPOIGuideDetailController(with poi: POIInfo) -> UIViewController {
        return UIViewController()
    }
}

extension MockSCInjector: SCBasicPOIGuideDetailInjecting {
    func getBasicPOIGuideDetailMapController(latitude: Double, longitude: Double, zoomFactor: Float, address: String, locationName: String, tintColor: UIColor) -> UIViewController {
        return UIViewController()
    }
    
    func getBasicPOIGuideLightBoxController(_with imageURL: OSCA.SCImageURL, _and credit: String) -> UIViewController {
        return UIViewController()
    }
}

extension MockSCInjector: SCLoginInjecting {
    func getForgottenViewController(email: String, completionOnSuccess: ((String, Bool, Bool?, String?) -> Void)?) -> UIViewController {
        return UIViewController()
    }
    
    func getTempBlockedViewController(email: String) -> UIViewController {
        return UIViewController()
    }
}

extension MockSCInjector: SCWebContentInjecting {
    func getWebContentViewController(for url: String, title: String?, insideNavCtrl: Bool, itemServiceParams: [String : String]?, serviceFunction: String?) -> UIViewController {
        return UIViewController()
    }
    
    func getWebContentViewController(for url: String, title: String?, insideNavCtrl: Bool) -> UIViewController {
        return UIViewController()
    }
    
    func getWebContentViewController(forHtmlString htmlString: String, title: String?, insideNavCtrl: Bool) -> UIViewController {
        return UIViewController()
    }
    
    func getTextViewContentViewController(forHtmlString htmlString: String, title: String?, insideNavCtrl: Bool) -> UIViewController {
        return UIViewController()
    }
    
    func getTextInWebViewContentViewController(forHtmlString htmlString: String, title: String?, insideNavCtrl: Bool) -> UIViewController {
        return UIViewController()
    }
}

extension MockSCInjector: SCPWDRestoreUnlockInjecting {
    func getRestoreUnlockFinishedViewController(email: String) -> UIViewController {
        return UIViewController()
    }
}
