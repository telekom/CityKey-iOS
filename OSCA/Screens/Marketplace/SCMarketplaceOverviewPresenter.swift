//
//  SCMarketplaceOverviewPresenter.swift
//  SmartCity
//
//  Created by Robert Swoboda - Telekom on 23.06.19.
//  Copyright © 2019 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import UIKit

class SCMarketplaceOverviewPresenter {
    
    public var selectedBranchID : String?

    weak private var display: SCMarketplaceOverviewDisplaying?
    
    private let cityContentSharedWorker: SCCityContentSharedWorking
    private let userContentSharedWorker: SCUserContentSharedWorker
    private let authProvider: SCAuthTokenProviding & SCLogoutAuthProviding
    private let refreshHandler : SCSharedWorkerRefreshHandling

    private let injector: SCServicesInjecting
    
    private var presentation: [SCMarketplaceOverviewSectionItem]?
    
    init(selectedBranchID: String?, cityContentSharedWorker: SCCityContentSharedWorking,  userContentSharedWorker: SCUserContentSharedWorker, authProvider: SCAuthTokenProviding & SCLogoutAuthProviding, injector: SCServicesInjecting, refreshHandler : SCSharedWorkerRefreshHandling) {
        
        self.selectedBranchID = selectedBranchID
        
        self.cityContentSharedWorker = cityContentSharedWorker
        self.userContentSharedWorker = userContentSharedWorker
        self.authProvider = authProvider
        self.refreshHandler = refreshHandler

        self.injector = injector
        
        self.setupNotifications()
    }
    
    deinit {
        SCDataUIEvents.discardNotifications(for: self)
    }
    
    private func setupNotifications() {
        SCDataUIEvents.registerNotifications(for: self, on: .didChangeLocation, with: #selector(didChangeLocation))
        SCDataUIEvents.registerNotifications(for: self, on: .didChangeCityContent, with: #selector(didChangeContent))
        SCDataUIEvents.registerNotifications(for: self, on: .userDidSignOut, with: #selector(didChangeLoginLogout))
        SCDataUIEvents.registerNotifications(for: self, on: .userDidSignIn, with: #selector(didChangeLoginLogout))
        SCDataUIEvents.registerNotifications(for: self, on: .didChangeUserDataState, with: #selector(didChangeContent))
        SCDataUIEvents.registerNotifications(for: self, on: .cityContentLoadingFailed, with: #selector(contentLoadingFailed))
        SCDataUIEvents.registerNotifications(for: self, on: .citiesLoadingFailed, with: #selector(contentLoadingFailed))
        SCDataUIEvents.registerNotifications(for: self, on: .userDataLoadingFailed, with: #selector(contentLoadingFailed))
        SCDataUIEvents.registerNotifications(for: self, on: .didChangeFavoriteEventsDataState, with: #selector(didChangeContent))
    }
    
    @objc private func contentLoadingFailed() {
        self.display?.endRefreshing()
        self.refreshUIContent()
    }
    
    @objc private func didChangeContent() {
        self.refreshUIContent()
    }
    
    @objc private func didChangeLoginLogout() {
        self.refreshUIContent()
    }
    
    @objc private func didChangeLocation() {
        self.refreshUIContent()
    }
    
    private func refreshUIContent(){
        /*if let contentModel = self.cityContentSharedWorker.getCityContentData(for: self.cityContentSharedWorker.getCityID()){
            self.display?.endRefreshing()
            
            let presentation = self.getSectionItemsFor(branchID: self.selectedBranchID, in: [contentModel.branches], tintColor: kColor_cityColor)
            
            debugPrint("SCMarketplaceOverviewPresenter-updateContent presentation=", presentation)
            self.updateUI(with: presentation)

        }*/
    }

    private func updateUI(with presentation: [SCMarketplaceOverviewSectionItem]) {
        self.display?.updateMarketplaces(with: presentation)
    }
    
    private func getSectionItemsFor(branchID: String?, in branches: [SCModelBranch], tintColor: UIColor) -> [SCMarketplaceOverviewSectionItem] {
        
        var items = [SCMarketplaceOverviewSectionItem]()
        
        for branch in branches {
            
            var subItems = [SCBaseComponentItem]()
            
            // add all brsanches or only the selected
            if branchID == nil || branch.id == branchID {
                for mp in branch.marketplaces {
                    subItems.append(SCBaseComponentItem(itemID : mp.id, itemTitle: mp.marketplaceTitle, itemTeaser : nil, itemSubtitle: nil, itemImageURL: mp.imageURL, itemImageCredit: nil, itemThumbnailURL: nil, itemIconURL: mp.iconURL, itemURL: nil, itemDetail: mp.marketplaceDescription, itemHtmlDetail: true ,itemCategoryTitle : LocalizationKeys.SCMarketplaceOverviewPresenter.s002MarketplacesTitleBranches.localized(),itemColor : tintColor, itemCellType: .not_specified, itemLockedDueAuth: !(!mp.authNeeded || SCAuth.shared.isUserLoggedIn()), itemLockedDueResidence:false, itemIsNew: mp.isNew, itemFunction : nil, itemBtnActions: nil, itemContext:.none))
                }
                
                let item = SCMarketplaceOverviewSectionItem(itemID : branch.id, itemTitle: branch.branchTitle, itemColor: tintColor, listItems: subItems.sorted {$0.itemTitle < $1.itemTitle})
                
                items.append(item)
            }
        }
        
        return items.sorted {
            $0.itemTitle < $1.itemTitle
        }
    }
}

// MARK: - SCPresenting
extension SCMarketplaceOverviewPresenter: SCPresenting {
    
    func viewDidLoad() {
        self.refreshUIContent()
    }
    
    func viewWillAppear() {
        
    }
    
    func viewDidAppear() {
        
    }
}

// MARK: - SCMarketplacePresenting
extension SCMarketplaceOverviewPresenter: SCMarketplaceOverviewPresenting {
    
    func setDisplay(_ display: SCMarketplaceOverviewDisplaying) {
        self.display = display
    }
    
    func didSelectListItem(item: SCBaseComponentItem) {
        self.showContent(displayContentType: .marketplace, navTitle: LocalizationKeys.SCMarketplacePresenter.s002MarketplacesTitle.localized(), title: LocalizationKeys.SCMarketplacePresenter.s002MarketplacesTitle.localized(), teaser: item.itemTitle, subtitle: "", details: item.itemDetail, imageURL: item.itemImageURL, photoCredit : item.itemImageCredit, contentURL:item.itemURL, tintColor : item.itemColor, serviceFunction: item.itemFunction, lockedDueAuth: item.itemLockedDueAuth, lockedDueResidence: item.itemLockedDueResidence, btnActions: item.itemBtnActions)
    }
        
    func needsToReloadData() {
        self.refreshHandler.reloadContent(force: true)
        self.refreshUIContent()
    }
    
    private func showContent(displayContentType : SCDisplayContentType,
                             navTitle : String,
                             title : String,
                             teaser : String,
                             subtitle : String,
                             details : String?,
                             imageURL : SCImageURL?,
                             photoCredit : String?,
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
        
        
        
        // a small delay on hiding the navigation bar to make it a little bit nicer
        SCUtilities.delay(withTime: 0.3, callback: {self.display?.showNavigationBar(false)})
        
        self.display?.push(viewController: contentViewController)
    }
}
