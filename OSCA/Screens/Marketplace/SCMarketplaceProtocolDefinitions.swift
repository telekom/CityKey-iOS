//
//  SCMarketPlaceProtocolDefinitions.swift
//  SmartCity
//
//  Created by Robert Swoboda - Telekom on 18.06.19.
//  Copyright © 2019 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

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
