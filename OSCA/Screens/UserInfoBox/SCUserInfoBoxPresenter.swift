//
//  SCUserInfoBoxPresenter.swift
//  SmartCity
//
//  Created by Michael on 14.06.19.
//  Copyright © 2019 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import UIKit
import TTGSnackbar

class SCUserInfoBoxPresenter {
    
    weak private var display: SCUserInfoBoxDisplaying?
    
    private let userInfoBoxWorker: SCUserInfoBoxWorking
    private let userContentSharedWorker: SCUserContentSharedWorking
    private let appContentSharedWorker: SCAppContentSharedWorking
    private let authProvider: SCLogoutAuthProviding
    private let injector: SCUserInfoBoxInjecting & SCLegalInfoInjecting & SCAdjustTrackingInjection & SCWebContentInjecting
    private let refreshHandler : SCSharedWorkerRefreshHandling

    private var model: SCModelProfile?
 
    private var showAllMessages : Bool = false
    private let auth: SCAuthStateProviding
    private var deeplinkMsgId: String?

    init(userInfoBoxWorker: SCUserInfoBoxWorking, userContentSharedWorker: SCUserContentSharedWorking, appContentSharedWorker: SCAppContentSharedWorking, authProvider: SCLogoutAuthProviding, injector: SCUserInfoBoxInjecting & SCLegalInfoInjecting & SCAdjustTrackingInjection & SCWebContentInjecting, refreshHandler : SCSharedWorkerRefreshHandling,
         auth: SCAuthStateProviding) {
        
        self.userInfoBoxWorker = userInfoBoxWorker
        self.userContentSharedWorker = userContentSharedWorker
        self.appContentSharedWorker = appContentSharedWorker
        self.refreshHandler = refreshHandler

        self.authProvider = authProvider
        self.injector = injector
        self.auth = auth
        
        self.setupNotifications()
    }
    
    deinit {
        SCDataUIEvents.discardNotifications(for: self)
    }
    
    private func setupNotifications() {
        SCDataUIEvents.registerNotifications(for: self, on: .didChangeCityContent, with: #selector(didChangeContent))
        SCDataUIEvents.registerNotifications(for: self, on: .userDidSignOut, with: #selector(onDidSignOut))
        SCDataUIEvents.registerNotifications(for: self, on: .userDidSignIn, with: #selector(onDidSignIn))
        SCDataUIEvents.registerNotifications(for: self, on: .didChangeUserDataState, with: #selector(didChangeContent))
        SCDataUIEvents.registerNotifications(for: self, on: .didReceiveInfoBoxData, with: #selector(didReceiveInfoBoxContent))
        SCDataUIEvents.registerNotifications(for: self, on: .infoBoxDataLoadingFailed, with: #selector(contentLoadingFailed))
        SCDataUIEvents.registerNotifications(for: self, on: .didUpdateAppPreviewMode, with: #selector(handleAppPreviewModeChange))
    }
    
    @objc private func handleDeeplink() {
        guard let deeplinkMsgId = deeplinkMsgId else {
            return
        }
        DispatchQueue.main.async {
            self.infoboxMessageDetailScreen(deeplinkMessageId: deeplinkMsgId, isRefreshUserInfoBoxRequired: false)
        }
    }
    
    @objc private func handleAppPreviewModeChange() {
        self.display?.handleAppPreviewBannerView()
    }
    
    @objc private func contentLoadingFailed() {
        self.display?.endRefreshing()
        self.refreshUIContent()
    }
    
    @objc private func didReceiveInfoBoxContent() {
        self.display?.endRefreshing()
        self.refreshUIContent()
        handleDeeplink()
    }
    
    @objc private func didChangeContent() {
        self.display?.endRefreshing()
        self.refreshUIContent()
    }
    
    @objc func onDidSignIn() {
        self.display?.removeFirstTimeUsage()
        self.refreshUIContent()
        self.display?.refreshNavBar()
    }
    
    @objc func onDidSignOut() {
        self.display?.removeFirstTimeUsage()
        self.display?.addFirstTimeUsage()
        self.display?.refreshNavBar()
        self.display?.updateUI(items: [])
    }
    
    private func refreshUIContent() {
        
        if !SCAuth.shared.isUserLoggedIn() {
            self.display?.removeFirstTimeUsage()
            self.display?.addFirstTimeUsage()
            return
        }
        
        // no data available (never loaded) and is Loading
        if self.userContentSharedWorker.isUserDataLoading() && !self.userContentSharedWorker.isInfoBoxDataAvailable() {
            self.display?.updateOverlay(state: .loading)
            return
        }

        // is not loadiung and error was occurerd and data were never been loaded
        if !self.userContentSharedWorker.isInfoBoxDataAvailable() && !self.userContentSharedWorker.isUserDataLoading() && self.userContentSharedWorker.isInfoBoxDataLoadingFailed(){
            self.display?.updateOverlay(state: .error)
            return
        }

        if let infoBoxData = self.userContentSharedWorker.getInfoBoxData() {
            self.display?.updateOverlay(state: .none)

            // this is the only reason, why cityContentSharedWorker is here. Discuss?
            let tintColor = kColor_cityColor//UIColor(named: "CLR_OSCA_BLUE")!
            
            var items = [SCUserInfoBoxMessageItem]()
            
            let sortedInfoBoxData = infoBoxData.sorted {
                $0.creationDate > $1.creationDate
            }
            
            for infoItem in sortedInfoBoxData {
                
                // show all messages or only unread message. This depends on the showAllMessages flag
                if self.showAllMessages || infoItem.isRead == false {
                    items.append(SCUserInfoBoxMessageItem(userInfoId: infoItem.userInfoId, messageId: infoItem.messageId, description: infoItem.description, details: infoItem.details, headline: infoItem.headline, isRead: infoItem.isRead, icon: infoItem.category.categoryIcon, creationDate: infoItem.creationDate, category: infoItem.category.categoryName, attachmentCount:  infoItem.attachments.count, tintColor: tintColor, model: infoItem))
                    
                }
            }
            
            self.display?.updateUI(items: items)
            
            if items.count == 0 {
                self.display?.updateOverlay(state: self.showAllMessages ? .noItems : .noUnreadItems)
                //self.display?.showEmptyView()
            }
        } else {
            self.display?.updateOverlay(state: .noItems)
        }
    }
    
}

extension SCUserInfoBoxPresenter: SCPresenting {
    func viewDidLoad() {
        self.injector.trackEvent(eventName: AnalyticsKeys.EventName.openInfobox)
        self.display?.setupUI(title: "b_001_infobox_title".localized())
        if (!SCAuth.shared.isUserLoggedIn()){
            self.display?.addFirstTimeUsage()
            self.display?.refreshNavBar()            
        }
        self.setFooterViewController()
        self.refreshUIContent()
    }
    
    func viewWillAppear() {
        self.refreshUIContent()
    }
    
    func viewDidAppear() {
        SCUtilities.delay(withTime: 0.0, callback:{
            self.display?.refreshNavBar()
        })
    }
}

extension SCUserInfoBoxPresenter : SCUserInfoBoxPresenting {
    
    func setFooterViewController() {
        let viewController = UIStoryboard(name: "UserInfoBoxScreen", bundle: nil).instantiateViewController(withIdentifier: "SCUserInfoBoxFooterViewController") as! FooterViewDelegate
        self.display?.setFooterViewController(controller: viewController)
    }

    func setDisplay(_ display: SCUserInfoBoxDisplaying) {
        self.display = display
    }
    
    func locationButtonWasPressed() {
        self.injector.showLocationSelector()
    }
    
    func profileButtonWasPressed() {
        self.injector.showProfile()
    }

    func loginButtonWasPressed(){
        self.injector.showLogin(completionOnSuccess: {
            self.needsToReloadData()
        })
    }
    
    func registerButtonWasPressed(){
        self.injector.showRegistration()
    }
    
    func impressumButtonWasPressed() {
        if let legalNotice = self.appContentSharedWorker.getLegalNotice(){
            let legalNoticeController = self.injector.getWebContentViewController(for: legalNotice, title: "i_001_imprint_title".localized(), insideNavCtrl: true)

            self.display?.present(viewController: legalNoticeController)
        }
    }
    
    func dataPrivacyButtonWasPressed() {
        
//        let dataPrivacy = self.injector.getDataPrivacyController(presentationType: .dataPrivacy, insideNavCtrl: true)
//        self.display?.present(viewController: dataPrivacy)

    }

    func markAsRead(_ read : Bool, item: SCUserInfoBoxMessageItem) {
        if !SCUtilities.isInternetAvailable() {
            self.display?.showErrorDialog(.noInternet, retryHandler: nil)
            SCUtilities.delay(withTime: 0.25, callback: {self.refreshUIContent()})
            return
        }

        self.userContentSharedWorker.markInfoBoxItem(id: item.userInfoId, read: read)
        SCUtilities.delay(withTime: 0.25, callback: {self.refreshUIContent()})
        SCDataUIEvents.postNotification(for: .didChangeUserInfoItems)
        self.userInfoBoxWorker.changeReadState(id: item.userInfoId, newReadState: read, completion: {(error) in
            
            if error != nil {
                self.userContentSharedWorker.markInfoBoxItem(id: item.userInfoId, read: !read)
                SCDataUIEvents.postNotification(for: .didChangeUserInfoItems)

                switch error {
                case .noInternet:
                    self.display?.showErrorDialog(error!, retryHandler: nil)
                    return
                default:
                    break
                }

                self.refreshHandler.reloadUserInfoBox()
                SCUtilities.delay(withTime: 0.0, callback: {self.refreshUIContent()})
                
                let snackbar = TTGSnackbar(
                    message: read ? "b_006_snackbar_mark_read_failed".localized() : "b_006_snackbar_mark_unread_failed".localized(),
                    duration: .middle
                )
                snackbar.setCustomStyle()
                snackbar.show()

            }
        })
    }
    
    func deleteItem(_ item: SCUserInfoBoxMessageItem) {
        if !SCUtilities.isInternetAvailable() {
            self.display?.showErrorDialog(.noInternet, retryHandler: nil)
            SCUtilities.delay(withTime: 0.25, callback: {self.refreshUIContent()})
            return
        }
        
        self.userContentSharedWorker.removeInfoBoxItem(id: item.userInfoId)
        SCUtilities.delay(withTime: 0.25, callback: {self.refreshUIContent()})
        SCDataUIEvents.postNotification(for: .didChangeUserInfoItems)

        let snackbar = TTGSnackbar(
            message: "b_006_snackbar_delete_success".localized(),
            duration: .middle,
            actionText: "b_006_snackbar_delete_undo".localized(),
            actionBlock: { (snackbar) in
                self.userInfoBoxWorker.deleteMessage(id: item.userInfoId, delete: false, completion: {(error) in
                    
                    if error != nil {
                        self.display?.showErrorDialog(error!, retryHandler: nil)
                    } else {
                        self.refreshHandler.reloadUserInfoBox()
                    }
                })
        }
        )
        snackbar.setCustomStyle()
        snackbar.show()

        self.userInfoBoxWorker.deleteMessage(id: item.userInfoId, delete: true, completion: {(error) in
        
            
            if error != nil {
                
                switch error {
                case .noInternet:
                    self.display?.showErrorDialog(error!, retryHandler: nil)
                    return
                default:
                    break
                }
                
                let snackbar = TTGSnackbar(
                    message: "b_006_snackbar_delete_failed".localized(),
                    duration: .middle
                )
                snackbar.setCustomStyle()
                snackbar.show()
                
            }
        })
    }
  
    func displayItem(_ item: SCUserInfoBoxMessageItem){
        
        if let model = item.model as? SCModelInfoBoxItem{
            let detailViewController = self.injector.getUserInfoboxDetailController(with: model, completionAfterDelete: { self.deleteItem(item)})
            
            self.display?.push(viewController: detailViewController)
        }
    }

    func segmentedControlWasPressed(index: Int) {
        self.showAllMessages = index == 1
        self.refreshUIContent()
    }

    func needsToReloadData(){
        self.refreshHandler.reloadUserInfoBox()
        self.refreshUIContent()
    }
    
    func infoboxMessageDetailScreen(deeplinkMessageId: String?, isRefreshUserInfoBoxRequired: Bool) {
        self.deeplinkMsgId = deeplinkMessageId
        guard auth.isUserLoggedIn(),
              let infoBoxData = userContentSharedWorker.getInfoBoxData(),
              let deeplinkMsgId = deeplinkMessageId,
              let deeplinkIntMessageId = Int(deeplinkMsgId) else {
            self.deeplinkMsgId = deeplinkMessageId
            self.needsToReloadData()
            return
        }
        if isRefreshUserInfoBoxRequired {
            needsToReloadData()
        } else {
            if userContentSharedWorker.isInfoBoxDataAvailable() {
                if infoBoxData.contains(where: {$0.messageId == deeplinkIntMessageId}) {
                    let item = infoBoxData.first(where: {$0.messageId == deeplinkIntMessageId})
                    guard let item = item else{
                        return
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: {
                        let messageItem = SCUserInfoBoxMessageItem(userInfoId: item.userInfoId, messageId: item.messageId,
                                                                   description: item.description, details: item.details,
                                                                   headline: item.headline,isRead: item.isRead,
                                                                   icon: item.category.categoryIcon,creationDate: item.creationDate,
                                                                   category: item.category.categoryName,
                                                                   attachmentCount: item.attachments.count ,
                                                                   tintColor: kColor_cityColor, model: item )
                        self.display?.push(viewController: self.injector.getUserInfoboxDetailController(with: item, completionAfterDelete: {self.deleteItem(messageItem)}))
                        self.deeplinkMsgId = nil
                        self.markAsRead(true, item: messageItem)
                    })
                } else {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: {
                        SCDeeplinkingHandler.shared.deeplinkWithUri("citykey://home/")
                    })
                }
            }
        }
    }
}
