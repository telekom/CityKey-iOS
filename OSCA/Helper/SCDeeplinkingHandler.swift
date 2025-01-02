//
//  SCDeeplinkingHandler.swift
//  SmartCity
//
//  Created by Alexander Lichius on 03.02.20.
//  Copyright © 2020 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import Foundation
import UIKit
import TTGSnackbar

enum deeplinks: String {
    case infobox
    case services
    case news
    case events
    case home
}

protocol SCDeeplinkingHanding: AnyObject {
    func deeplinkWithUri(_ uri: String)
}

class SCDeeplinkingHandler: SCDeeplinkingHanding {
    private var appContentSharedWorker: SCAppContentSharedWorking
    private var injector: SCLegalInfoInjecting
    private let cityContentSharedWorker: SCCityContentSharedWorking
    static let shared: SCDeeplinkingHanding = SCDeeplinkingHandler()
    private init(appContentSharedWorker: SCAppContentSharedWorking = SCAppContentSharedWorker(requestFactory: SCRequest()),
         injector: SCLegalInfoInjecting = SCInjector(),
         cityContentSharedWorker: SCCityContentSharedWorking = SCCityContentSharedWorker(requestFactory: SCRequest())) {
        self.appContentSharedWorker = appContentSharedWorker
        self.injector = injector
        self.cityContentSharedWorker = cityContentSharedWorker
    }
    func deeplinkWithUri(_ uri: String) {
        if let host = hostFor(uri) {
            if let deeplink = deeplinks(rawValue: host) {
                switch deeplink {
                case .home:
                    deeplinkToHome()
                case .infobox:
                    let queryParams = getQueryItems(uri)
                    let deeplinkMessageId = queryParams["messageId"]
                    deeplinkToInbox(deeplinkMessageId: deeplinkMessageId)
                case .services:
                    if let pathComponent = self.pathComponentFor(uri) {
                        deeplinkToService(name: pathComponent, month: getQueryItems(uri)["month"])
                    }
                case .news:
                    let queryParams = getQueryItems(uri)
                    let modelMessage = SCHttpModelMessage(contentId: Int(queryParams["contentID"] ?? "0") ?? 0, uid: 0,
                                                          contentTeaser: queryParams["contentTeaser"] ?? "", contentDetails: queryParams["contentDetails"] ?? "",
                                                          contentSubtitle: queryParams["contentSubtitle"] ?? "", contentSource: queryParams["contentSource"],
                                                          contentImage: queryParams["contentImage"],
                                                          imageCredit: queryParams["imageCredit"],
                                                          thumbnail: queryParams["thumbnail"],
                                                          thumbnailCredit: nil,
                                                          contentCategory: nil,
                                                          contentCreationDate: queryParams["contentCreationDate"],
                                                          sticky: false).toModel()
                    if appContentSharedWorker.trackingPermissionFinished && appContentSharedWorker.firstTimeUsageFinished {
                        deeplinkToNews(with: mapMessagesToItems(for: .news, message: modelMessage))
                        SCInjector().trackEvent(eventName: AnalyticsKeys.Widget.newsWidgetTapped)
                    }
                case .events:
                    let queryParams = getQueryItems(uri)
                    let eventId = queryParams["eventId"] ?? ""
                    let cityId = Int(queryParams["cityId"] ?? "0") ?? 0
                    let storedSelectedCity = cityContentSharedWorker.getCityID()
                    if cityId != storedSelectedCity {
                        deeplinkToEventDetail(eventId: eventId, cityId: cityId, isCityChanged: true)
                    } else {
                        deeplinkToEventDetail(eventId: eventId, cityId: cityId)
                    }
                }
            }
        }
    }
    
    func getQueryItems(_ urlString: String) -> [String : String] {
        var queryItems: [String : String] = [:]
        let components: NSURLComponents? = getURLComonents(urlString)
        for item in components?.queryItems ?? [] {
            queryItems[item.name] = item.value?.removingPercentEncoding
        }
        return queryItems
    }
    
    func getURLComonents(_ urlString: String?) -> NSURLComponents? {
        var components: NSURLComponents? = nil
        let linkUrl = URL(string: urlString?.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) ?? "")
        if let linkUrl = linkUrl {
            components = NSURLComponents(url: linkUrl, resolvingAgainstBaseURL: true)
        }
        return components
    }

    private func deeplinkToHome() {
        SCUtilities.dismissAnyPresentedViewController { () -> Void? in
            let tabBarController = SCUtilities.topViewController() as? UITabBarController
            if let indexForInbox = self.indexForHomeController() {
                tabBarController?.selectedIndex = indexForInbox
                let selectedViewController = tabBarController?.selectedViewController as? UINavigationController
                selectedViewController?.popToRootViewController(animated: true)
            }
            return nil
        }
    }
    
    private func deeplinkToInbox(deeplinkMessageId: String?) {
        SCUtilities.dismissAnyPresentedViewController { () -> Void? in
            let tabBarController = SCUtilities.topViewController() as? UITabBarController
            if let indexForInbox = self.indexForInboxController() {
                tabBarController?.selectedIndex = indexForInbox
                let selectedViewController = tabBarController?.selectedViewController as? UINavigationController
                selectedViewController?.popToRootViewController(animated: true)
                let hasUserInfoboxDetailViewController = selectedViewController?.containsViewController(ofKind: SCUserInfoBoxViewController.self)
                if let hasUserInfoboxDetailVC = hasUserInfoboxDetailViewController, true == hasUserInfoboxDetailVC{
                    let userInfoboxDetailViewController = selectedViewController?.hasViewController(ofKind: SCUserInfoBoxViewController.self) as? SCUserInfoBoxViewController
                    userInfoboxDetailViewController?.presenter.infoboxMessageDetailScreen(deeplinkMessageId: deeplinkMessageId,
                                                                                         isRefreshUserInfoBoxRequired: true)
                }
                else{
                    let userInfoBoxViewController = selectedViewController?.viewControllers.first as? SCUserInfoBoxViewController
                    userInfoBoxViewController?.presenter.infoboxMessageDetailScreen(deeplinkMessageId: deeplinkMessageId,
                                                                                   isRefreshUserInfoBoxRequired: false)
                }
            }
            return nil
        }
    }
    
    func deeplinkToEventDetail(eventId: String, cityId: Int?, isCityChanged: Bool = false) {
        SCUtilities.dismissAnyPresentedViewController { () -> Void? in
            let tabBarController = SCUtilities.topViewController() as? UITabBarController
            if let indexForNewsTab = self.indexForNewsController() {
                tabBarController?.selectedIndex = indexForNewsTab
                let selectedViewController = tabBarController?.selectedViewController as? UINavigationController
                selectedViewController?.popToRootViewController(animated: true)
                
                let hasDashBoardViewController = selectedViewController?.containsViewController(ofKind: SCDashboardViewController.self)
                
                if let hasDashBoardVC = hasDashBoardViewController,
                   true == hasDashBoardVC {
                    let dashboardViewController = selectedViewController?.hasViewController(ofKind: SCDashboardViewController.self) as? SCDashboardViewController
                    dashboardViewController?.presenter.fetchEventDetail(eventId: eventId, cityId: cityId, isCityChanged: isCityChanged)
                } else {
                    let dashboardViewController = selectedViewController?.viewControllers.first as? SCDashboardViewController
                    dashboardViewController?.presenter.fetchEventDetail(eventId: eventId, cityId: cityId, isCityChanged: isCityChanged)
                }
            }
            return nil
        }
    }
    
    private func deeplinkToService(name: String, month: String?) {
        SCUtilities.dismissAnyPresentedViewController { () -> Void? in
            let tabBarController = SCUtilities.topViewController() as? UITabBarController
            if let indexForServiceTab = self.indexForServiceController() {
                tabBarController?.selectedIndex = indexForServiceTab
                let selectedViewController = tabBarController?.selectedViewController as? UINavigationController
                selectedViewController?.popToRootViewController(animated: true)
                
                // BugFix: From Appointments list, deep-linking leads to app crash.
                let appointmentOverviewController = selectedViewController?.containsViewController(ofKind: SCAppointmentOverviewController.self)
                let wasteCalendarViewController = selectedViewController?.containsViewController(ofKind: SCWasteCalendarViewController.self)

                if appointmentOverviewController == true || wasteCalendarViewController == true{
                    let servicesViewController = selectedViewController?.hasViewController(ofKind: SCServicesViewController.self) as? SCServicesViewController
                    servicesViewController?.showDeepLinkedService(name: name, month: month)
                }
                else{
                    let servicesViewController = selectedViewController?.viewControllers.first as? SCServicesDisplaying
                    servicesViewController?.showDeepLinkedService(name: name, month: month)
                }
                
            }
            return nil
        }
    }
    
    private class func schemeFor(_ uri: String) -> String? {
        let components = URLComponents(string: uri)
        return components?.scheme?.lowercased()
    }

    private func pathComponentFor(_ uri: String, componentIndex : Int) -> String? {
        let url = URL(string: uri)
        if let pathComponents = url?.pathComponents {
            if pathComponents.count > componentIndex {
                return pathComponents[componentIndex].lowercased()
            }
            
        }
        return nil
    }

    private class func queryItemsFor(_ uri: String) -> [URLQueryItem]? {
        let components = URLComponents(string: uri)
        return components?.queryItems
    }

    private func hostFor(_ uri: String) -> String? {
        let components = URLComponents(string: uri) //osca://service/appointment
        return components?.host?.lowercased()
    }

    private func pathComponentFor(_ uri: String) -> String? {
        let url = URL(string: uri)
        if let path = url?.path {
            return path.lowercased()
        }
        return nil
    }

    private class func indexForControllerOfType<T>(viewControllerType: T) -> Int? {
        if let mainTabBarController = SCUtilities.topViewController() as? UITabBarController {
            if let index = mainTabBarController.viewControllers?.firstIndex(where: {$0.navigationController?.viewControllers.first is T}) {
                return index
            }
        }
        return nil
    }

    private func indexForHomeController() -> Int? {
        if let mainTabBarController = SCUtilities.topViewController() as? UITabBarController {
            if let homeIndex = (mainTabBarController.viewControllers?.firstIndex(where: {
                let viewController = $0 as? UINavigationController
                return viewController?.viewControllers.first is SCDashboardDisplaying
                
            })) {
                return homeIndex
            }
        }
        return nil
    }

    private func indexForInboxController() -> Int? {
        if let mainTabBarController = SCUtilities.topViewController() as? UITabBarController {
            if let inboxIndex = (mainTabBarController.viewControllers?.firstIndex(where: {
                let viewController = $0 as? UINavigationController
                return viewController?.viewControllers.first is SCUserInfoBoxDisplaying
                
            })) {
                return inboxIndex
            }
        }
        
        return nil
    }
    
    private func indexForServiceController() -> Int? {
        if let mainTabBarController = SCUtilities.topViewController() as? UITabBarController {
            if let inboxIndex = (mainTabBarController.viewControllers?.firstIndex(where: {
                let viewController = $0 as? UINavigationController
                return viewController?.viewControllers.first is SCServicesDisplaying
                
            })) {
                return inboxIndex
            }
        }
        
        return nil
    }
    
    private class func indexForMarketplaceController() -> Int? {
        if let mainTabBarController = SCUtilities.topViewController() as? UITabBarController {
            if let inboxIndex = (mainTabBarController.viewControllers?.firstIndex(where: {
                let viewController = $0 as? UINavigationController
                return viewController?.viewControllers.first is SCMarketplaceDisplaying
                
            })) {
                return inboxIndex
            }
        }
        
        return nil
    }
    
    private class func indexForDashboardController() -> Int? {
        if let mainTabBarController = SCUtilities.topViewController() as? UITabBarController {
            if let inboxIndex = (mainTabBarController.viewControllers?.firstIndex(where: {
                let viewController = $0 as? UINavigationController
                return viewController?.viewControllers.first is SCDashboardDisplaying
                
            })) {
                return inboxIndex
            }
        }
        
        return nil
    }
    
    private func deeplinkToNews(with model: SCBaseComponentItem) {
        SCUtilities.dismissAnyPresentedViewController { () -> Void? in
            let tabBarController = SCUtilities.topViewController() as? UITabBarController
            if let indexForNewsTab = self.indexForNewsController() {
                tabBarController?.selectedIndex = indexForNewsTab
                let selectedViewController = tabBarController?.selectedViewController as? UINavigationController
                selectedViewController?.popToRootViewController(animated: true)
                
                let hasDashBoardViewController = selectedViewController?.containsViewController(ofKind: SCDashboardViewController.self)
                
                if let hasDashBoardVC = hasDashBoardViewController,
                   true == hasDashBoardVC {
                    let dashBoardVC = selectedViewController?.hasViewController(ofKind: SCDashboardViewController.self) as? SCDashboardViewController
                    dashBoardVC?.routeToNewsDetail(with: model)
                } else {
                    let dashboardVC = selectedViewController?.viewControllers.first as? SCDashboardViewController
                    dashboardVC?.routeToNewsDetail(with: model)
                }
            }
            return nil
        }
    }
    
    private func indexForNewsController() -> Int? {
        if let mainTabBarController = SCUtilities.topViewController() as? UITabBarController {
            if let newsIndex = (mainTabBarController.viewControllers?.firstIndex(where: {
                let viewController = $0 as? UINavigationController
                return viewController?.viewControllers.first is SCDashboardViewController
                
            })) {
                return newsIndex
            }
        }
        
        return nil
    }

    
    private func mapMessagesToItems(for type: SCModelMessageType, message: SCModelMessage) -> SCBaseComponentItem {

        var itemCategoryTitle = ""
        var itemCellType = SCBaseComponentItemCellType.not_specified
        
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        
        switch type {
        case .info:
            itemCategoryTitle = "h_001_home_title_news".localized()
            itemCellType = .not_specified
        case .news:
            itemCategoryTitle = "h_001_home_title_news".localized()
            itemCellType = .not_specified
        case .tip:
            itemCategoryTitle = "h_001_home_title_tips".localized()
            itemCellType = .carousel_big
        case .offer:
            itemCategoryTitle = "h_001_home_title_offers".localized()
            itemCellType = .carousel_big
        case .discount:
            itemCategoryTitle = "h_001_home_title_discounts".localized()
            itemCellType = .carousel_small
        case .unknown:
            itemCategoryTitle = ""
            itemCellType = .not_specified
        case .event:
            itemCategoryTitle = "h_001_home_title_events"
            itemCellType = .not_specified
        }
        
        
        var titleText: String = ""
        if type == .news || type == .event {
            titleText = stringFromDate(date: message.date)//dateFormatter.string(from: message.date) // get the date from appropriate helper
        } else {
            titleText = message.title
        }
        
        return SCBaseComponentItem(itemID: message.id, itemTitle: titleText, itemTeaser: message.shortText, itemSubtitle: message.subtitleText, itemImageURL: message.imageURL,itemImageCredit: message.imageCredit, itemThumbnailURL: message.thumbnailURL, itemIconURL: message.imageURL, itemURL: message.contentURL, itemDetail: message.detailText, itemHtmlDetail: false, itemCategoryTitle: itemCategoryTitle, itemColor : kColor_cityColor, itemCellType: itemCellType, itemLockedDueAuth: false, itemLockedDueResidence:false, itemIsNew: false, itemFunction : nil, itemContext:.none)
    }


    
}
