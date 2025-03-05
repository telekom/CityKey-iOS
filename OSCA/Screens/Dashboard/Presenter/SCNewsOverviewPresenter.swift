/*
Created by Robert Swoboda - Telekom on 21.06.19.
Copyright © 2019 Deutsche Telekom AG - VTI Organization. All rights reserved.

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

SPDX-FileCopyrightText: 2025 Deutsche Telekom AG, Robert Swoboda
SPDX-License-Identifier: Apache-2.0 AND LicenseRef-Deutsche-Telekom-Brand
License-Filename: LICENSES/Apache-2.0.txt LICENSES/LicenseRef-Deutsche-Telekom-Brand.txt
*/

import UIKit

class SCNewsOverviewPresenter {
    weak private var display: SCNewsOverviewDisplaying?
    var injector: SCAdjustTrackingInjection
    private var items: [SCBaseComponentItem]
    
    init(newsItems: [SCBaseComponentItem], injector: SCAdjustTrackingInjection) {
        self.items = newsItems
        self.injector = injector
    }
    
}

extension SCNewsOverviewPresenter: SCPresenting {
    func viewDidLoad() {
        self.display?.updateNews(with: self.items)
    }
    
    func viewWillAppear() {
        
    }
    
    func viewDidAppear() {
        
    }
}

extension SCNewsOverviewPresenter: SCNewsOverviewPresenting {
    
    func setDisplay(_ display: SCNewsOverviewDisplaying) {
        self.display = display
    }
    
    func setNewsItems(_ items: [SCBaseComponentItem]) {
        self.items = items
    }
    
    func didSelectListItem(item: SCBaseComponentItem) {
        self.injector.trackEvent(eventName: AnalyticsKeys.EventName.openNewsDetailPage)
        showContent(displayContentType: .news, navTitle: LocalizationKeys.SCDashboardVC.h001HomeTitleNews.localized(), title: item.itemTitle, teaser: item.itemTeaser ?? "", subtitle: item.itemSubtitle ?? "", details: item.itemDetail ?? "", imageURL: item.itemImageURL, photoCredit : item.itemImageCredit, topBtnTitle: nil, bottomBtnTitle: nil, contentURL: item.itemURL, tintColor : item.itemColor)
    }
    
    private func showContent(displayContentType : SCDisplayContentType,
                             navTitle : String,
                             title : String,
                             teaser : String,
                             subtitle : String,
                             details : String?,
                             imageURL : SCImageURL?,
                             photoCredit : String?,
                             topBtnTitle : String?,
                             bottomBtnTitle : String?,
                             contentURL : URL?,
                             tintColor : UIColor?,
                             serviceFunction :  String? = nil,
                             lockedDueAuth : Bool? = false,
                             lockedDueResidence : Bool? = false,
                             btnActions: [SCComponentDetailBtnAction]? = nil) {
        
        
        let contentViewController = SCDisplayContent.getMessageDetailController(displayContentType : displayContentType,
                                                                            navTitle : navTitle,
                                                                            title : title,
                                                                            teaser : teaser,
                                                                            subtitle: subtitle,
                                                                            details : details,
                                                                            imageURL : imageURL,
                                                                            photoCredit : photoCredit,
                                                                            contentURL : contentURL,
                                                                            tintColor : tintColor,
                                                                            lockedDueAuth : lockedDueAuth,
                                                                            lockedDueResidence : lockedDueResidence,
                                                                            btnActions: btnActions,
                                                                            injector: self.injector as! SCInjector,
                                                                            beforeDismissCompletion: { SCUtilities.delay(withTime: 0.1, callback: {self.display?.showNavigationBar(true)})})
        
        
        
        self.display?.push(viewController: contentViewController)
    }
}
