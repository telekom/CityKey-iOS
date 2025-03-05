/*
Created by Robert Swoboda - Telekom on 18.06.19.
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

struct SCMarketplaceFlags {
    let showFavoriteMarketplaces: Bool
    let showNewMarketplaces: Bool
    let showMostUsedMarketplaces: Bool
    let showBranches: Bool
    let showDiscounts: Bool
    let showOurMarketplaces: Bool
    
    static func showAll() -> SCMarketplaceFlags {
        return SCMarketplaceFlags(showFavoriteMarketplaces: true, showNewMarketplaces: true, showMostUsedMarketplaces: true, showBranches: true, showDiscounts: true, showOurMarketplaces: true)
    }
    
    static func showNone() -> SCMarketplaceFlags {
        return SCMarketplaceFlags(showFavoriteMarketplaces: false, showNewMarketplaces: false, showMostUsedMarketplaces: false, showBranches: false, showDiscounts: false, showOurMarketplaces: false)
    }
}

struct SCMarketplaceOverviewSectionItem {
    var itemID : String
    var itemTitle : String
    var itemColor : UIColor
    var listItems : [SCBaseComponentItem]
}

protocol SCMarketplaceDisplaying: AnyObject, SCDisplaying {
    
    func setHeaderImageURL(_ url: SCImageURL?)
    func setCoatOfArmsImageURL(_ url: SCImageURL)

    func customize(color: UIColor)
    
    func updateAllMarketplace(with dataItems: [SCBaseComponentItem])
    func updateNewMarketplace(with dataItems: [SCBaseComponentItem])
    func updateDiscounts(with dataItems: [SCBaseComponentItem])
    func updateRecents(with dataItems: [SCBaseComponentItem])
    func updateBranches(with dataItems: [SCBaseComponentItem])
    func updateFavorites(with dataItems: [SCBaseComponentItem])
    
    func configureContent()
    func resetUI()

    func toggleFavoritesEditing()
    func cancelFavDeletionMode()

    func push(viewController: UIViewController)
    func present(viewController: UIViewController)
    func showNavigationBar(_ visible : Bool)
    
    func endRefreshing()
}

protocol SCMarketplacePresenting: SCPresenting {
    func setDisplay(_ display: SCMarketplaceDisplaying)

    func locationButtonWasPressed()
    func profileButtonWasPressed()
    func editFavoritesButtonWasPressed()
    func showAllButtonWasPressed()
    
    func getMarketplaceFlags() -> SCMarketplaceFlags
    
    func itemSelected(_ item: SCBaseComponentItem)

    func needsToReloadData()
}

protocol SCMarketplaceOverviewDisplaying: AnyObject, SCDisplaying {
    
    func push(viewController: UIViewController)
    func present(viewController: UIViewController)
    func showNavigationBar(_ visible : Bool)
    func updateMarketplaces(with items: [SCMarketplaceOverviewSectionItem])
    
    func endRefreshing()
}

protocol SCMarketplaceOverviewPresenting: SCPresenting {
    
    func setDisplay(_ display: SCMarketplaceOverviewDisplaying)
    
    func didSelectListItem(item: SCBaseComponentItem)
    
    func needsToReloadData()
}
