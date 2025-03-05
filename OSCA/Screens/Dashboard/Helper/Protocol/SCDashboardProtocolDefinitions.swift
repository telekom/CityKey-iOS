/*
Created by Robert Swoboda - Telekom on 12.06.19.
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

struct SCDashboardFlags: Equatable {
    let showTips: Bool
    let showOffers: Bool
    let showDiscounts: Bool
    
    static func showAll() -> SCDashboardFlags {
        return SCDashboardFlags(showTips: true, showOffers: true, showDiscounts: true)
    }
    static func showNone() -> SCDashboardFlags {
        return SCDashboardFlags(showTips: false, showOffers: false, showDiscounts: false)
    }
}

protocol SCDashboardDisplaying: AnyObject, SCDisplaying  {
    
    // var dashboardPresenter: SCDashboardPresenting { get set }
    
    func setHeaderImageURL(_ url: SCImageURL?)
    func setCoatOfArmsImageURL(_ url: SCImageURL)
    
    func setWelcomeText(_ text: String)
    func setCityName(_ name: String)
    func setWeatherInfo(_ info: String)
    
    func customize(color: UIColor)
    func resetUI()

    func updateNews(with dataItems: [SCBaseComponentItem])
    func updateEvents(with dataItems: [SCModelEvent]?, favorites: [SCModelEvent]?)

    func showNewsActivityInfoOverlay()
    func showNewsErrorInfoOverlay(infoText: String)
    func hideNewsInfoOverlay()
    func showEventsActivityInfoOverlay()
    func showEventsErrorInfoOverlay(infoText: String)
    func hideEventsInfoOverlay()

    func configureContent()

    func navigationController() -> UINavigationController?
    func push(viewController: UIViewController)
    func present(viewController: UIViewController)
    func presentDPNViewController(viewController : UIViewController)
    func showNavigationBar(_ visible : Bool)

    func endRefreshing()
    func endRefreshingEventContent()
    
    func showChangeLocationToolTip()
    func hideChangeLocationToolTip()
    
    func handleAppPreviewBannerView()
}

protocol SCDashboardPresenting: SCPresenting {
    
    func setDisplay(_ display: SCDashboardDisplaying)
    
    func didSelectCarouselItem(item: SCBaseComponentItem)
    func didSelectListItem(item: SCBaseComponentItem)
    func didSelectListEventItem(item: SCModelEvent, isCityChanged: Bool, cityId: Int?)
    func didPressMoreNewsBtn()
    func didPressMoreEventsBtn()

    func locationButtonWasPressed()
    func profileButtonWasPressed()
    
    func getDashboardFlags() -> SCDashboardFlags

    func needsToReloadData()
    func fetchEventDetail(eventId: String, cityId: Int?, isCityChanged: Bool)
}

protocol SCNewsOverviewDisplaying: AnyObject {
    func present(viewController: UIViewController)
    func push(viewController: UIViewController)
    func showNavigationBar(_ visible : Bool)
    func updateNews(with dataItems: [SCBaseComponentItem])
}

protocol SCNewsOverviewPresenting: SCPresenting {
    func setDisplay(_ display: SCNewsOverviewDisplaying)
    
    func setNewsItems(_ items: [SCBaseComponentItem])
    func didSelectListItem(item: SCBaseComponentItem)
}

