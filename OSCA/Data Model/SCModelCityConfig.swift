//
//  SCModelCityConfig.swift
//  SmartCity
//
//  Created by Michael on 15.03.19.
//  Copyright © 2019 Michael. All rights reserved.
//

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
