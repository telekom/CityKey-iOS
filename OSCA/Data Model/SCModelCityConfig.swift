/*
Created by Michael on 15.03.19.
Copyright © 2019 Michael. All rights reserved.

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

SPDX-FileCopyrightText: 2025 Deutsche Telekom AG, Copyright © 2019 Michael
SPDX-License-Identifier: Apache-2.0 AND LicenseRef-Deutsche-Telekom-Brand
License-Filename: LICENSES/Apache-2.0.txt LICENSES/LicenseRef-Deutsche-Telekom-Brand.txt
*/

import UIKit

//
//  SCModelCityConfig.swift
//  SmartCity
//
//  Created by Robert Swoboda on 15.03.19.
//  Copyright © 2019 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import Foundation

/**
 * @brief SCModelCityConfig.swift is the data model for city configuration, mostly flags for UI
 */

struct SCModelCityConfig: Decodable {
    let showFavouriteServices: Bool?
    let showHomeDiscounts: Bool?
    let showHomeOffers: Bool?
    let showHomeTips: Bool?
    let showFavouriteMarketplaces: Bool?
    let showNewServices: Bool?
    let showNewMarketplaces: Bool?
    let showMostUsedServices: Bool?
    let showMostUsedMarketplaces: Bool?
    let showCategories: Bool?
    let showBranches: Bool?
    let showDiscounts: Bool?
    let showOurMarketPlaces: Bool?
    let showOurServices: Bool?
    let showMarketplacesOption: Bool?
    let showServicesOption: Bool?
    let stickyNewsCount: Int?

    static func showAll() -> SCModelCityConfig {
        return SCModelCityConfig(showFavouriteServices: true,
                                 showHomeDiscounts: true,
                                 showHomeOffers: true,
                                 showHomeTips: true,
                                 showFavouriteMarketplaces: true,
                                 showNewServices: true,
                                 showNewMarketplaces: true,
                                 showMostUsedServices: true,
                                 showMostUsedMarketplaces: true,
                                 showCategories: true,
                                 showBranches: true,
                                 showDiscounts: true,
                                 showOurMarketPlaces: true,
                                 showOurServices: true,
                                 showMarketplacesOption: false,
                                 showServicesOption: false,
                                 stickyNewsCount: 4)
    }


    static func showNone() -> SCModelCityConfig {
        return SCModelCityConfig(showFavouriteServices: false,
                                 showHomeDiscounts: false,
                                 showHomeOffers: false,
                                 showHomeTips: false,
                                 showFavouriteMarketplaces: false,
                                 showNewServices: false,
                                 showNewMarketplaces: false,
                                 showMostUsedServices: false,
                                 showMostUsedMarketplaces: false,
                                 showCategories: false,
                                 showBranches: false,
                                 showDiscounts: false,
                                 showOurMarketPlaces: false,
                                 showOurServices: false,
                                 showMarketplacesOption: false,
                                 showServicesOption: false,
                                 stickyNewsCount: 4)
    }
    
    func toMarketplacePresentation() -> SCMarketplaceFlags {
        return SCMarketplaceFlags(showFavoriteMarketplaces: self.showFavouriteMarketplaces ?? false,
                                  showNewMarketplaces: self.showNewMarketplaces ?? false,
                                  showMostUsedMarketplaces: self.showMostUsedMarketplaces ?? false,
                                  showBranches: self.showBranches ?? false,
                                  showDiscounts: self.showDiscounts ?? false,
                                  showOurMarketplaces: self.showOurMarketPlaces ?? false)
    }
    
    func toServicesPresentation() -> SCServicesFlags {
        return SCServicesFlags(showFavouriteServices: self.showFavouriteServices ?? false,
                               showNewServices: self.showNewServices ?? false,
                               showMostUsedServices: self.showMostUsedServices ?? false,
                               showCategories: self.showCategories ?? false,
                               showOurServices: self.showOurServices ?? false)
    }
    
    func toDashboardPresentation() -> SCDashboardFlags {
        return SCDashboardFlags(showTips: self.showHomeTips ?? false,
                                showOffers: self.showHomeOffers ?? false,
                                showDiscounts: self.showHomeDiscounts ?? false)
    }

}
