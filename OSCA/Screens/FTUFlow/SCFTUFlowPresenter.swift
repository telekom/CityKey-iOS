/*
Created by Michael on 25.01.20.
Copyright © 2020 Deutsche Telekom AG - VTI Organization. All rights reserved.

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

protocol SCFTUFlowDisplaying: AnyObject, SCDisplaying  {
    func push(viewController: UIViewController)
    func present(viewController: UIViewController)
    func showActivityView()
    func hideActivityView()
    func dismiss(completion: (() -> Void)?)
}

protocol SCFTUFlowPresenting: SCPresenting {
    func setDisplay(_ display: SCFTUFlowDisplaying)
    
    func loginBtnWasPressed()
    func registerBtnWasPressed()
    func skipButtonWasPressed()
   
}

class SCFTUFlowPresenter {
    
    weak private var display: SCFTUFlowDisplaying?
    
    private var appContentSharedWorker: SCAppContentSharedWorking
    private let cityContentSharedWorker: SCCityContentSharedWorking
    private let authProvider: SCAuthStateProviding
    private let refreshHandler: SCSharedWorkerRefreshHandling
    private let injector: SCProfileInjecting & SCToolsInjecting & SCToolsShowing & SCLegalInfoInjecting & SCRegistrationInjecting & SCWebContentInjecting & MoEngageAnalyticsInjection
    
    private var email: String?
    private weak var presentedVC: UIViewController?

    init(appContentSharedWorker: SCAppContentSharedWorking, cityContentSharedWorker: SCCityContentSharedWorking, refreshHandler : SCSharedWorkerRefreshHandling, authProvider: SCAuthStateProviding, injector: SCProfileInjecting & SCToolsInjecting & SCToolsShowing & SCLegalInfoInjecting & SCRegistrationInjecting & SCWebContentInjecting & MoEngageAnalyticsInjection) {
        
        self.appContentSharedWorker = appContentSharedWorker
        self.cityContentSharedWorker = cityContentSharedWorker
        self.authProvider = authProvider
        self.refreshHandler = refreshHandler
        self.injector = injector
        self.setupNotifications()
    }
    
    deinit {
        SCDataUIEvents.discardNotifications(for: self)
    }

    private func setupNotifications() {
        SCDataUIEvents.registerNotifications(for: self, on: .didChangeCityContent, with: #selector(didChangeCityContent))
    }

    @objc private func didChangeCityContent() {
        self.display?.hideActivityView()
    }

    private func sortCityArrayAlphabetically(array: [CityLocationInfo]) -> [CityLocationInfo]{
        var arrayToSort = array
        
        arrayToSort.sort { (city1, city2) -> Bool in
            return city1.cityName < city2.cityName
        }
        
        return arrayToSort
    }
 
    private func preloadData(){
      
        // first load impressum and data Privacy
        self.appContentSharedWorker.triggerTermsUpdate(errorBlock: { (error) in
            if error != nil {
                self.display?.showErrorDialog(error!, retryHandler: {self.preloadData()}, showCancelButton: false)
                return
            }
            
            if self.appContentSharedWorker.trackingPermissionFinished == false {
//                let dataPrivacyVC = self.injector.getDataPrivacyController(presentationType: .trackingPermission ,insideNavCtrl: true)
                let dataPrivacyVC = self.injector.getDataPrivacyFirstRunController(preventSwipeToDismiss: true) { [weak self] in
                    guard let strongSelf = self else {
                        return
                    }
                    strongSelf.registerForPush()
                }
                self.display?.present(viewController: dataPrivacyVC)
            }
            

            // when impressum and data privacy are loaded then we need data for the city selection
            self.loadCitiesForFTUProcess(completionOnSuccess: {
                
                // special case: when the is already logged in and is in the first time
                // usage, then we will jump to the city selector
                if self.authProvider.isUserLoggedIn(){
                    self.showCitySelector()
                }
            })
        })
    }

    private func loadCitiesForFTUProcess(completionOnSuccess: (() -> Void)? = nil){
        self.cityContentSharedWorker.triggerCitiesUpdate{ (error) in
            if error != nil {
                self.display?.showErrorDialog(error!, retryHandler: {self.loadCitiesForFTUProcess(completionOnSuccess : completionOnSuccess)}, showCancelButton: false)
                return
            }
            
            completionOnSuccess?()
        }
    }
    
    private func showCitySelector(){
        if self.cityContentSharedWorker.getCityID() == kNoCityIDAvaiable {
            let citySelector = self.injector.getLocationViewController(presentationMode: .firstTime, includeNavController: false, completionAfterDismiss: nil)
            self.display?.push(viewController: citySelector)
        } else {
            dismissFTU()
        }
        
    }
    
    func dismissFTU() {
        
        DispatchQueue.main.async {
            SCDataUIEvents.postNotification(for: .didShowToolTip)
            self.display?.dismiss(completion: nil)
        }
        setupMoEngageUserAttributes()
        self.appContentSharedWorker.firstTimeUsageFinished = true
        UserDefaults.standard.set(true, forKey: "firstTimeUsageFinished")
    }
    
    private func registerForPush() {
        injector.registerRemotePushForApplication()
    }
    
    private func setupMoEngageUserAttributes() {
        injector.setupMoEngageUserAttributes()
    }
}

extension SCFTUFlowPresenter: SCPresenting {
    func viewDidLoad() {
        self.preloadData()
    }
    
    func viewWillAppear() {
    }
    
    func viewDidAppear() {
    }
}

extension SCFTUFlowPresenter : SCFTUFlowPresenting {
    
    func setDisplay(_ display: SCFTUFlowDisplaying) {
        self.display = display
    }
    
    func loginBtnWasPressed() {
        
        let loginViewController = self.injector.getLoginViewController(dismissAfterSuccess: true) {
            self.showCitySelector()
        }
        self.display?.present(viewController:loginViewController)
        
    }
    
    func registerBtnWasPressed() {
        let navCtrl = UINavigationController()
        navCtrl.modalTransitionStyle = .coverVertical

        let registrationViewController = self.injector.getRegistrationViewController(completionOnSuccess: { (email, isError, errorMessage) in
            navCtrl.dismiss(animated: true, completion: {
                let confirmViewController = self.injector.getRegistrationConfirmEMailVC(registeredEmail:email, shouldHideTopImage: false, presentationType: .confirmMailForRegistration, isError: isError, errorMessage: errorMessage,  completionOnSuccess: {
                    self.presentedVC?.dismiss(animated: true, completion:{
                        self.loginBtnWasPressed()
                    })
                    self.presentedVC = nil
                })
                self.presentedVC = confirmViewController
                self.display?.present(viewController: confirmViewController)
            })
        })
        

        navCtrl.viewControllers = [registrationViewController]
        
        
        self.display?.present(viewController: navCtrl)
    }

    func skipButtonWasPressed(){
        //self.showCitySelector()//TODO: do not show the city selector, instead show the dashboard with the first available city
        self.dismissFTU()
    }

}
