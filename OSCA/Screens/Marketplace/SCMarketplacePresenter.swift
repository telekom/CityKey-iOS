//
//  SCMarketplacePresenter.swift
//  SmartCity
//
//  Created by Robert Swoboda - Telekom on 18.06.19.
//  Copyright © 2019 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import UIKit

struct SCMarketplacePresentationModel {
    
    let marketplaceHeaderImageUrl: SCImageURL
    let cityCoatOfArmsImageUrl: SCImageURL
    let cityTintColor: UIColor
    
    let marketplaceFlags: SCMarketplaceFlags
    
    let allMarketplaces: [SCBaseComponentItem]
    let newMarketplaces: [SCBaseComponentItem]
    let mostRecent: [SCBaseComponentItem]
    let favorites: [SCBaseComponentItem]
    let branches: [SCBaseComponentItem]
    let discounts: [SCBaseComponentItem]
    
    static func fromModel(_ model: SCCityContentModel, userContentWorker: SCUserContentSharedWorking) -> SCMarketplacePresentationModel {
        
        let tintColor = kColor_cityColor
        
        /*let allTitle = "s_002_marketplaces_title_ours".localized()
        let newTitle = "s_002_marketplaces_title_new".localized()
        let mostRecentTitle = "s_001_services_002_marketplaces_title_most_used".localized()
        let discountsTitle = "h_001_home_title_discounts".localized()
        let branchesTitle =  "s_002_marketplaces_title_branches".localized()
        
        let allMarketplaces = model.allMarketplaces().map {
            $0.toBaseCompontentItem(tintColor: tintColor, categoryTitle: allTitle, cellType: .tiles_icon, context: .none)
        }
        
        let newMarketplaces = model.newMarketplaces().map {
            $0.toBaseCompontentItem(tintColor: tintColor, categoryTitle: newTitle, cellType: .carousel_iconBigText, context: .none)
        }
        
        let mostRecent = model.mostUsedMarketplaces().map {
            $0.toBaseCompontentItem(tintColor: tintColor, categoryTitle: mostRecentTitle, cellType: .carousel_iconSmallText, context: .none)
        }*/
        /*
        let discounts = model.messages.compactMap { (message) -> SCBaseComponentItem? in
            if message.type == .discount {
                return message.toBaseCompontentItem(tintColor: tintColor, categoryTitle: discountsTitle, cellType: .carousel_small, context: .none)
            } else {
                return nil
            }
        }
        
        let branches = model.branches.map {
            $0.toBaseCompontentItem(tintColor: tintColor, categoryTitle: branchesTitle, cellType: .not_specified)
        }
        
        let favorites = [SCBaseComponentItem]()*/
        return SCMarketplacePresentationModel(marketplaceHeaderImageUrl: model.city.marketplaceImageUrl,
                                              cityCoatOfArmsImageUrl: model.city.municipalCoatImageUrl,
                                              cityTintColor: tintColor,
                                              marketplaceFlags: model.cityConfig.toMarketplacePresentation(),
                                              allMarketplaces: [],
                                              newMarketplaces: [],
                                              mostRecent: [],
                                              favorites: [],
                                              branches: [],
                                              discounts: [])
    }
}

class SCMarketplacePresenter {
    
    weak private var display: SCMarketplaceDisplaying?
    
    private let marketplaceWorker: SCMarketplaceWorking
    private let cityContentSharedWorker: SCCityContentSharedWorking
    private let userContentSharedWorker: SCUserContentSharedWorking
    private let authProvider: SCAuthTokenProviding & SCLogoutAuthProviding
    private let injector: SCMarketplaceInjecting
    private let refreshHandler : SCSharedWorkerRefreshHandling

    private var presentation: SCMarketplacePresentationModel?
    
    init(marketplaceWorker: SCMarketplaceWorking, cityContentSharedWorker: SCCityContentSharedWorking, userContentSharedWorker: SCUserContentSharedWorking, authProvider: SCAuthTokenProviding & SCLogoutAuthProviding, injector: SCMarketplaceInjecting, refreshHandler : SCSharedWorkerRefreshHandling) {
        
        self.marketplaceWorker = marketplaceWorker
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
        self.display?.resetUI()
        self.refreshUIContent()
    }
    
    private func refreshUIContent(){
        if let contentModel = self.cityContentSharedWorker.getCityContentData(for: self.cityContentSharedWorker.getCityID()){
            self.display?.endRefreshing()
            
            self.updateUI(with: SCMarketplacePresentationModel.fromModel(contentModel, userContentWorker: self.userContentSharedWorker))
            
        }
    }
    
    private func updateUI(with presentation: SCMarketplacePresentationModel) {
        
        self.presentation = presentation
        
        self.display?.setHeaderImageURL(presentation.marketplaceHeaderImageUrl)
        self.display?.setCoatOfArmsImageURL(presentation.cityCoatOfArmsImageUrl)
        self.display?.customize(color: presentation.cityTintColor)
        
        self.display?.updateAllMarketplace(with: presentation.allMarketplaces)
        self.display?.updateNewMarketplace(with: presentation.newMarketplaces)
        self.display?.updateDiscounts(with: presentation.discounts)
        self.display?.updateRecents(with: presentation.mostRecent)
        self.display?.updateBranches(with: presentation.branches)
        self.display?.updateFavorites(with: presentation.favorites)
        
        self.display?.configureContent()
    }
}

// MARK: - SCPresenting
extension SCMarketplacePresenter: SCPresenting {
    
    func viewDidLoad() {
        self.refreshUIContent()
    }
    
    func viewWillAppear() {
        self.display?.cancelFavDeletionMode()
    }
    
    func viewDidAppear() {
    }
}

// MARK: - SCMarketplacePresenting
extension SCMarketplacePresenter: SCMarketplacePresenting {
   
    func setDisplay(_ display: SCMarketplaceDisplaying) {
        self.display = display
    }
    
    func locationButtonWasPressed() {
        self.display?.cancelFavDeletionMode()
        self.injector.showLocationSelector()        
    }
    
    func profileButtonWasPressed() {
        self.display?.cancelFavDeletionMode()
        self.injector.showProfile()
    }
    
    func editFavoritesButtonWasPressed() {
        self.display?.toggleFavoritesEditing()
    }
    
    func showAllButtonWasPressed() {
        self.display?.cancelFavDeletionMode()
        self.showMarketplaceOverview(for: nil)
    }
    
    func itemSelected(_ item: SCBaseComponentItem) {
        
        self.display?.cancelFavDeletionMode()

        if item.itemContext == .overview {
            self.showMarketplaceOverview(for: item)
        } else {
            self.showContent(displayContentType: .news, navTitle: LocalizationKeys.SCMarketplacePresenter.s002MarketplacesTitle.localized(), title: LocalizationKeys.SCMarketplacePresenter.s002MarketplacesTitle.localized(), teaser: item.itemTitle, subtitle: "", details: item.itemDetail, imageURL: item.itemImageURL, photoCredit : item.itemImageCredit, contentURL:item.itemURL, tintColor : item.itemColor, serviceFunction: item.itemFunction, lockedDueAuth: item.itemLockedDueAuth, lockedDueResidence: item.itemLockedDueResidence, btnActions: item.itemBtnActions)
        }
    }
    
    func needsToReloadData() {
        self.display?.cancelFavDeletionMode()
        self.refreshHandler.reloadContent(force: true)
        self.refreshUIContent()
    }
    
    func getMarketplaceFlags() -> SCMarketplaceFlags {
        return self.presentation?.marketplaceFlags ?? SCMarketplaceFlags.showNone()
    }
}

// MARK: - private helpers for SCMarketplacePresenting
extension SCMarketplacePresenter {
    
    private func showMarketplaceOverview(for item: SCBaseComponentItem?) {
        
        let viewController = self.injector.getMarketplaceOverviewController(for: item)
        
        self.display?.push(viewController: viewController)
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
        
        
                
        self.display?.push(viewController: contentViewController)
    }
}
