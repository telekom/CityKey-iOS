//
//  SCUserInfoBoxProtocolDefinitions.swift
//  SmartCity
//
//  Created by Michael on 17.06.19.
//  Copyright © 2019 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import UIKit

enum SCInfoBoxOverlayState {
    case error
    case noItems
    case noUnreadItems
    case loading
    case none
}

struct SCUserInfoBoxMessageItem {
    let userInfoId: Int
    let messageId: Int
    let description: String
    let details: String
    let headline: String
    var isRead: Bool
    let icon: String?
    let creationDate: Date
    let category: String
    let attachmentCount: Int
    let tintColor : UIColor
    let model : Any
}

protocol FooterViewDelegate: AnyObject {
    func updateOverlay(state : SCInfoBoxOverlayState)
    func showEmptyView()
    func getView() -> UIView
}

protocol SCUserInfoBoxDisplaying: AnyObject, SCDisplaying {
    
    var userInfoBoxPresenter: SCUserInfoBoxPresenting { get set }
    
    func setupUI(title: String)
    func setFooterViewController(controller: FooterViewDelegate)
    func updateUI(items: [SCUserInfoBoxMessageItem])
    func updateOverlay(state : SCInfoBoxOverlayState)
    func showEmptyView()
    func refreshNavBar()
    func isFirstTimeUsageVisible() -> Bool
    func addFirstTimeUsage()
    func removeFirstTimeUsage()
    func endRefreshing()
    
    func present(viewController: UIViewController)
    func showNavigationBar(_ visible : Bool)
    func push(viewController: UIViewController)
    
    func handleAppPreviewBannerView()
}

protocol SCUserInfoBoxPresenting: SCPresenting {
    func setDisplay(_ display: SCUserInfoBoxDisplaying)
    
    func locationButtonWasPressed()
    func profileButtonWasPressed()
    func loginButtonWasPressed()
    func registerButtonWasPressed()
    func impressumButtonWasPressed()
    func dataPrivacyButtonWasPressed()
    func segmentedControlWasPressed(index : Int)

    func markAsRead(_ read : Bool, item: SCUserInfoBoxMessageItem)
    func deleteItem(_ item: SCUserInfoBoxMessageItem)
    func displayItem(_ item: SCUserInfoBoxMessageItem)
    func needsToReloadData()
    func infoboxMessageDetailScreen(deeplinkMessageId: String?, isRefreshUserInfoBoxRequired: Bool)
}
