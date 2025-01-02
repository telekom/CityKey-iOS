//
//  SCDashboardOverviewPresenter.swift
//  SmartCity
//
//  Created by Robert Swoboda - Telekom on 21.06.19.
//  Copyright © 2019 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

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
