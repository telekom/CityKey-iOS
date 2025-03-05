/*
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

SPDX-FileCopyrightText: 2025 Deutsche Telekom AG
SPDX-License-Identifier: Apache-2.0 AND LicenseRef-Deutsche-Telekom-Brand
License-Filename: LICENSES/Apache-2.0.txt LICENSES/LicenseRef-Deutsche-Telekom-Brand.txt
*/
//
//  SCSharedWorkerRefreshHandler.swift
//  SmartCity
//
//  Created by Michael on 30.11.19.
//  Copyright © 2019 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import UIKit

protocol SCSharedWorkerRefreshHandling: AnyObject  {
    var display: SCDisplaying? { get set }
    func renewSession(completion: @escaping ()->() )
    func reloadContent(force : Bool)
    func reloadUserInfoBox()
    func reloadServices()
    func showCitySelector()
}

class SCSharedWorkerRefreshHandler: SCSharedWorkerRefreshHandling {
  
    private let cityContentSharedWorker: SCCityContentSharedWorking
    private let userContentSharedWorker: SCUserContentSharedWorking
    private let userCityContentSharedWorker: SCUserCityContentSharedWorking
    private let appContentSharedWorker: SCAppContentSharedWorking
    private let authProvider: SCAuthTokenProviding & SCLogoutAuthProviding
    var display: SCDisplaying?

    var isInitialLoadingFinished: Bool = false {
        didSet {
            if oldValue == false && isInitialLoadingFinished == true {
                // so when the data are available the first time, then we will send
                // notification, that MainPresenter is ready for displaying
                SCUtilities.delay(withTime: 0.0, callback: {SCDataUIEvents.postNotification(for: .isInitialLoadingFinished) })
            }
        }
    }

    init(cityContentSharedWorker: SCCityContentSharedWorking, userContentSharedWorker: SCUserContentSharedWorking, userCityContentSharedWorker: SCUserCityContentSharedWorking, appContentSharedWorker : SCAppContentSharedWorking, authProvider: SCAuthTokenProviding & SCLogoutAuthProviding, display: SCDisplaying?) {

        self.cityContentSharedWorker = cityContentSharedWorker
        self.userContentSharedWorker = userContentSharedWorker
        self.userCityContentSharedWorker = userCityContentSharedWorker
        self.appContentSharedWorker = appContentSharedWorker
        self.authProvider = authProvider
        self.display = display
    }

    func renewSession(completion: @escaping () -> ()) {
        debugPrint("renewSession")
        SCFileLogger.shared.write("renewSession", withTag: .logout)
        self.authProvider.renewAccessTokenIfValid { result in
            
            debugPrint("renewSession completion")
            SCFileLogger.shared.write("renewSession completion \(result)", withTag: .logout)
            completion()
        }
        
    }
    
    func reloadContent(force : Bool){
        // when logged in: get user content
        if authProvider.isUserLoggedIn(){
            if force {
                self.triggerUserDataUpdate()
           } else {
                if !self.userContentSharedWorker.userDataState.dataInitialized {
                    self.triggerUserDataUpdate()
                } else {
                    if !self.userCityContentSharedWorker.favoriteEventsDataState.dataInitialized {
                        self.triggerUserCityFavoriteEvents()
                    }
                    if !self.userContentSharedWorker.isInfoBoxDataAvailable(){
                        self.triggerInfoBoxDataUpdate()
                    }
                    if !userCityContentSharedWorker.isAppointmentsDataAvailable() {
                        triggerAppointmentsDataUpdate()
                    }
                }
            }
        }
        
        if force {
            self.triggerCityContentDataUpdate()
            // app content will be loaded only on force
            self.triggerAppContentDataUpdate()

        } else {
            if self.cityContentSharedWorker.isCityContentAvailable(for: self.cityContentSharedWorker.getCityID()) {
                self.triggerCityContentDataUpdate()
            }
        }
        
        self.refreshInitialLoadingState()
    }
    
    func reloadUserInfoBox(){
        self.triggerInfoBoxDataUpdate()
    }
    
    func reloadServices() {
        self.triggerCityContentDataUpdate()
    }
    
    func showCitySelector() {
        SCDataUIEvents.postNotification(for: .cityNotAvailable)
    }
    
    private func triggerUserCityFavoriteEvents() {
        if self.userContentSharedWorker.userDataState.dataInitialized {
            self.userCityContentSharedWorker.triggerFavoriteEventsUpdate() { (error) in
                if error != nil {
                }
                self.refreshInitialLoadingState()
            }
        }
    }

    private func triggerAppointmentsDataUpdate() {
        if userContentSharedWorker.userDataState.dataInitialized {
            userCityContentSharedWorker.triggerAppointmentsUpdate { (error) in
                self.refreshInitialLoadingState()
            }
        }
    }


    private func triggerCityContentDataUpdate() {
        // kein contentModel? -> dann triggern!
        
        self.cityContentSharedWorker.triggerCityContentUpdate(for: self.cityContentSharedWorker.getCityID(), errorBlock: { (error) in
            if error != nil {
                switch error {
                case .fetchFailed(let errorDetail):
                    if errorDetail.errorCode == "service.inactive" {
                        SCUserDefaultsHelper.setCityStatus(status: false)
                        self.display?.showCityNotAvailableDialog(retryHandler: {self.showCitySelector()}, showCancelButton: false, additionalButtonTitle: nil, additionButtonHandler: nil)
                    } else {
                        self.display?.showErrorDialog(error!, retryHandler: self.triggerCityContentDataUpdate, showCancelButton: self.isInitialLoadingFinished)
                    }
                case .noInternet:
                    SCDataUIEvents.postNotification(for: .launchScreenNoInternet)
                    self.display?.showNoInternetAvailableDialog(retryHandler: self.triggerCityContentDataUpdate, showCancelButton: self.isInitialLoadingFinished)
                default:
                    SCFileLogger.shared.write("Harshada -> triggerCityContentDataUpdate | SCSharedWorkerRefreshHandler: requestFailed-> \(String(describing: error))", withTag: .logout)
                    debugPrint("Harshada -> triggerCityContentDataUpdate | SCSharedWorkerRefreshHandler: requestFailed-> \(String(describing: error))")
                    
                    self.display?.showErrorDialog(error!, retryHandler: {self.reloadContent(force: true)}, showCancelButton: self.isInitialLoadingFinished)
                }
            }
            self.refreshInitialLoadingState()
        })
    }

    private func triggerAppContentDataUpdate() {
        self.appContentSharedWorker.triggerTermsUpdate(errorBlock: { (error) in
            if error != nil {
                SCFileLogger.shared.write("Harshada -> triggerAppContentDataUpdate | SCSharedWorkerRefreshHandler: requestFailed-> \(String(describing: error))", withTag: .logout)
                debugPrint("Harshada -> triggerAppContentDataUpdate | SCSharedWorkerRefreshHandler: requestFailed-> \(String(describing: error))")

//                self.display?.showErrorDialog(error!, retryHandler: {self.reloadContent(force: true)}, showCancelButton: self.isInitialLoadingFinished)
            }
            self.refreshInitialLoadingState()
        })
    }

    private func triggerInfoBoxDataUpdate() {
        if authProvider.isUserLoggedIn(){
            
            SCFileLogger.shared.write("SCSharedWorkerRefreshHandler -> triggerInfoBoxDataUpdate", withTag: .logout)
            self.userContentSharedWorker.triggerInfoBoxDataUpdate{ (error) in
                
                //when unexpected unauthorized the do a logout
                if error != nil {
                    switch error! {
                    case .unauthorized:
                        SCFileLogger.shared.write("SCSharedWorkerRefreshHandler -> triggerInfoBoxDataUpdate -> .unauthorized -> self.authProvider.logout(logoutReason: .technicalReason .. )  ", withTag: .logout)
                        self.authProvider.logout(logoutReason: .technicalReason ,completion: {self.reloadContent(force: true)})
                    default:
                        SCFileLogger.shared.write("Harshada -> triggerInfoBoxDataUpdate | SCSharedWorkerRefreshHandler: requestFailed-> \(String(describing: error))", withTag: .logout)
                        debugPrint("Harshada -> triggerInfoBoxDataUpdate | SCSharedWorkerRefreshHandler: requestFailed-> \(String(describing: error))")

//                        self.display?.showErrorDialog(error!, retryHandler: {self.triggerInfoBoxDataUpdate()}, showCancelButton: self.isInitialLoadingFinished)
                    }
                    
                    return
                }
                
                self.refreshInitialLoadingState()
                
            }
        }
    }

    private func triggerUserDataUpdate() {
        if authProvider.isUserLoggedIn(){
            self.userContentSharedWorker.triggerUserDataUpdate{ (error) in
                
                //when unexpected unauthorized the do a logout
                if error != nil {
                    switch error! {
                    case .unauthorized:
                        self.authProvider.logout(logoutReason: .technicalReason ,completion: {self.reloadContent(force: true)})
                    case .noInternet:
                        SCDataUIEvents.postNotification(for: .launchScreenNoInternet)
                        self.display?.showNoInternetAvailableDialog(retryHandler: self.triggerUserDataUpdate, showCancelButton: self.isInitialLoadingFinished)
                    default:
                        SCFileLogger.shared.write("Harshada -> triggerUserDataUpdate | SCSharedWorkerRefreshHandler: requestFailed-> \(String(describing: error))", withTag: .logout)
                        debugPrint("Harshada -> triggerUserDataUpdate | SCSharedWorkerRefreshHandler: requestFailed-> \(String(describing: error))")

                        // Handled endless spinner
                        self.display?.showErrorDialog(error!, retryHandler: {self.reloadContent(force: true)}, showCancelButton: self.isInitialLoadingFinished)
                    }
                    
                    return
                }

                self.refreshInitialLoadingState()
                self.triggerUserCityFavoriteEvents()
                self.triggerInfoBoxDataUpdate()
                self.triggerAppointmentsDataUpdate()

            }
        }
    }

    private func refreshInitialLoadingState(){
        if self.cityContentSharedWorker.isCityContentAvailable(for: self.cityContentSharedWorker.getCityID()){
            
            if authProvider.isUserLoggedIn(){
                if self.userContentSharedWorker.userDataState.dataInitialized  {
                    self.isInitialLoadingFinished = true
                }
            } else {
                self.isInitialLoadingFinished = true
            }

        }
    }

}
