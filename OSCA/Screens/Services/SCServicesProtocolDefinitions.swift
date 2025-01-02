//
//  SCServicesProtocolDefinitions.swift
//  SmartCity
//
//  Created by Robert Swoboda - Telekom on 13.06.19.
//  Copyright © 2019 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import UIKit

struct SCServicesOverviewSectionItem {
    var itemID : String
    var itemTitle : String
    var itemColor : UIColor
    var listItems : [SCBaseComponentItem]
}

struct SCServicesFlags {
    let showFavouriteServices: Bool
    let showNewServices: Bool
    let showMostUsedServices: Bool
    let showCategories: Bool
    let showOurServices: Bool
    
    static func showAll() -> SCServicesFlags {
        return SCServicesFlags(showFavouriteServices: true, showNewServices: true, showMostUsedServices: true, showCategories: true, showOurServices: true)
    }
    static func showNone() -> SCServicesFlags {
        return SCServicesFlags(showFavouriteServices: false, showNewServices: false, showMostUsedServices: false, showCategories: false, showOurServices: false)
    }
}

protocol SCServicesDisplaying: AnyObject, SCDisplaying {
    
    func setHeaderImageURL(_ url: SCImageURL?)
    func setCoatOfArmsImageURL(_ url: SCImageURL)
    func setServiceDesc(_ serviceDesc: String?)
    func customize(color: UIColor)
    
    func updateNewServices(with dataItems: [SCBaseComponentItem])
    func updateAllServices(with dataItems: [SCBaseComponentItem])
    func updateMostRecents(with dataItems: [SCBaseComponentItem])
    func updateFavorites(with dataItems: [SCBaseComponentItem])
    func updateCategories(with dataItems: [SCBaseComponentItem])
    func updateHeaderView()
    
    func showActivityInfoOverlay()
    func showErrorInfoOverlay()
    func hideInfoOverlay()

    func configureContent()
    func resetUI()

    func toggleFavoritesEditing()
    func cancelFavDeletionMode()

    func pushDeepLinked(viewControllers: [UIViewController])
    func push(viewController: UIViewController)
    func present(viewController: UIViewController)
    func showNavigationBar(_ visible : Bool)

    func showNeedsToLogin(with text : String, cancelCompletion: (() -> Void)?, loginCompletion: @escaping (() -> Void))
    func showNotAvailableAlert()
    
    func endRefreshing()
    
    func showDeepLinkedService(name: String, month: String?)
    
    func handleAppPreviewBannerView()
}

protocol SCServicesPresenting: SCPresenting {
    func setDisplay(_ display: SCServicesDisplaying)
        
    func locationButtonWasPressed()
    func profileButtonWasPressed()
    func editFavoritesButtonWasPressed()
    func showAllButtonWasPressed()
    func showDeepLinkedService(name: String, month: String?)
    
    func itemSelected(_ item: SCBaseComponentItem)
    
    func getServicesFlags() -> SCServicesFlags

    func needsToReloadData()
}

protocol SCServicesOverviewDisplaying: AnyObject, SCDisplaying {
    
    func push(viewController: UIViewController)
    
    func present(viewController: UIViewController)
    
    func showNavigationBar(_ visible : Bool)

    func updateServices(with items: [SCServicesOverviewSectionItem])
    
    func showNeedsToLogin(with text : String, cancelCompletion: (() -> Void)?, loginCompletion: @escaping (() -> Void))

    func endRefreshing()
}

protocol SCServicesOverviewPresenting: SCPresenting {
    
    func setDisplay(_ display: SCServicesOverviewDisplaying)
    
    func didSelectListItem(item: SCBaseComponentItem)
    
    func needsToReloadData()
}
