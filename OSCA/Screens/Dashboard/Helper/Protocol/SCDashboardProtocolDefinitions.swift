//
//  SCDashboardProtocolDefinitions.swift
//  SmartCity
//
//  Created by Robert Swoboda - Telekom on 12.06.19.
//  Copyright © 2019 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

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

