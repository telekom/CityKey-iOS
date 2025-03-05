/*
Created by Michael on 26.06.19.
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

SPDX-FileCopyrightText: 2025 Deutsche Telekom AG, Michael
SPDX-License-Identifier: Apache-2.0 AND LicenseRef-Deutsche-Telekom-Brand
License-Filename: LICENSES/Apache-2.0.txt LICENSES/LicenseRef-Deutsche-Telekom-Brand.txt
*/

import UIKit

class SCServicesOverviewPresenter {
    
    public var selectedServiceCategoryID: String?
    
    weak private var display: SCServicesOverviewDisplaying?
    
    private let cityContentSharedWorker: SCCityContentSharedWorking
    private let userContentSharedWorker: SCUserContentSharedWorker
    private let authProvider: SCAuthTokenProviding & SCLogoutAuthProviding

    private let injector: SCServicesInjecting & SCWebContentInjecting
    
    private var presentation: [SCServicesOverviewSectionItem]?
    private let refreshHandler : SCSharedWorkerRefreshHandling

    init(selectedServiceCategoryID: String?, cityContentSharedWorker: SCCityContentSharedWorking,  userContentSharedWorker: SCUserContentSharedWorker, authProvider: SCAuthTokenProviding & SCLogoutAuthProviding, injector: SCServicesInjecting & SCWebContentInjecting, refreshHandler : SCSharedWorkerRefreshHandling) {
        
        self.selectedServiceCategoryID = selectedServiceCategoryID
        
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
        SCDataUIEvents.registerNotifications(for: self, on: .didChangeServiceContentState, with: #selector(didChangeContent))
        SCDataUIEvents.registerNotifications(for: self, on: .cityContentLoadingFailed, with: #selector(contentLoadingFailed))
        SCDataUIEvents.registerNotifications(for: self, on: .citiesLoadingFailed, with: #selector(contentLoadingFailed))
        SCDataUIEvents.registerNotifications(for: self, on: .userDataLoadingFailed, with: #selector(didChangeContent))
        SCDataUIEvents.registerNotifications(for: self, on: .didChangeFavoriteEventsDataState, with: #selector(contentLoadingFailed))
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
        if let services = self.cityContentSharedWorker.getServices(for: self.cityContentSharedWorker.getCityID()){
            self.display?.endRefreshing()
            
            let presentation = self.getSectionItemsFor(serviceCategoryID: self.selectedServiceCategoryID, in: services, tintColor: kColor_cityColor)
            
            debugPrint("SCServicesOverviewPresenter-updateContent presentation=", presentation)
            self.updateUI(with: presentation)
        }
    }
    
    private func updateUI(with presentation: [SCServicesOverviewSectionItem]) {
        self.display?.updateServices(with: presentation)
    }
    
    private func getSectionItemsFor(serviceCategoryID: String?, in serviceCategories: [SCModelServiceCategory], tintColor: UIColor) -> [SCServicesOverviewSectionItem] {
        
        var items = [SCServicesOverviewSectionItem]()
        
        for category in serviceCategories {
            
            var subItems = [SCBaseComponentItem]()
            
            // add all brsanches or only the selected
            if serviceCategoryID == nil || category.id == serviceCategoryID {
                for service in category.services {
                    subItems.append(SCBaseComponentItem(itemID : service.id, itemTitle: service.serviceTitle, itemTeaser : nil, itemSubtitle: nil, itemImageURL: service.imageURL, itemImageCredit: nil, itemThumbnailURL: nil, itemIconURL: service.iconURL, itemURL: nil, itemDetail: service.serviceDescription, itemHtmlDetail: true ,itemCategoryTitle : LocalizationKeys.SCServicesViewController.s001services002MarketplacesTitleCategories.localized(),itemColor : tintColor, itemCellType: .not_specified, itemLockedDueAuth: !(!service.authNeeded || SCAuth.shared.isUserLoggedIn()), itemLockedDueResidence:false, itemIsNew: service.isNew, itemFunction : service.serviceFunction, itemContext:.none))
                }
                
                let item = SCServicesOverviewSectionItem(itemID : category.id, itemTitle: category.categoryTitle, itemColor: tintColor, listItems: subItems.sorted {$0.itemTitle < $1.itemTitle})
                
                items.append(item)
            }
        }
        
        return items.sorted {
            $0.itemTitle < $1.itemTitle
        }
    }
}

// MARK: - SCPresenting
extension SCServicesOverviewPresenter: SCPresenting {
    
    func viewDidLoad() {
        self.refreshUIContent()
    }
    
    func viewWillAppear() {
        
    }
    
    func viewDidAppear() {
        
    }
}

// MARK: - SCServicesPresenting
extension SCServicesOverviewPresenter: SCServicesOverviewPresenting {
    
    func setDisplay(_ display: SCServicesOverviewDisplaying) {
        self.display = display
    }
    
    func didSelectListItem(item: SCBaseComponentItem) {
        
        if item.itemFunction != nil && item.itemFunction!.isAbsoluteUrlString() {
            self.showWebview(title: item.itemTitle,  urlString: item.itemFunction!, itemLockedDueAuth: item.itemLockedDueAuth)
        } else {
            self.showContent(displayContentType: .service, navTitle: LocalizationKeys.SCServicesViewController.s001ServicesTitle.localized(), title: LocalizationKeys.SCServicesViewController.s001ServicesTitle.localized(), teaser: item.itemTitle, subtitle: "", details: item.itemDetail, imageURL: item.itemImageURL, photoCredit : item.itemImageCredit, contentURL:nil, tintColor : item.itemColor, serviceFunction: item.itemFunction, lockedDueAuth: item.itemLockedDueAuth, lockedDueResidence: item.itemLockedDueResidence, btnActions: item.itemBtnActions, serviceType: item.serviceType)
        }

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
                             btnActions: [SCComponentDetailBtnAction]? = nil,
                             serviceType: String?) {
        
        let successBlock = {
            let contentViewController = SCDisplayContent.getMessageDetailController(displayContentType : displayContentType,
                                                                                 navTitle : navTitle,
                                                                                 title : "",
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
                                                                                 serviceType: serviceType,
                                                                                 beforeDismissCompletion: { SCUtilities.delay(withTime: 0.1, callback: {self.display?.showNavigationBar(true)})})
             
             
             
             self.display?.push(viewController: contentViewController)
        }
        
        if !SCAuth.shared.isUserLoggedIn() && lockedDueAuth ?? false {
            self.display?.showNeedsToLogin(with: "dialog_login_required_message", cancelCompletion: {},loginCompletion: {
                self.injector.showLogin {
                    successBlock()
                }
            })
        } else {
            successBlock()
        }
    }
    
    private func showWebview(title : String?, urlString : String, itemLockedDueAuth: Bool) {
        
        let successBlock = {
            let viewController = self.injector.getWebContentViewController(for: urlString, title : title, insideNavCtrl: false)
            self.display?.present(viewController: viewController)
        }
        
        if !SCAuth.shared.isUserLoggedIn() && itemLockedDueAuth {
            self.display?.showNeedsToLogin(with: "dialog_login_required_message", cancelCompletion: {},loginCompletion: {
                self.injector.showLogin {
                    successBlock()
                }
            })
        } else {
            successBlock()
        }
    }

}
