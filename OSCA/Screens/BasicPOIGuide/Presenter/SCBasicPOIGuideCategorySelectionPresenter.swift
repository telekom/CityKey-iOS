/*
Created by Harshada Deshmukh on 26/02/21.
Copyright © 2021 Deutsche Telekom AG - VTI Organization. All rights reserved.

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

SPDX-FileCopyrightText: 2025 Deutsche Telekom AG, Harshada Deshmukh
SPDX-License-Identifier: Apache-2.0 AND LicenseRef-Deutsche-Telekom-Brand
License-Filename: LICENSES/Apache-2.0.txt LICENSES/LicenseRef-Deutsche-Telekom-Brand.txt
*/

import UIKit
import MapKit

class SCBasicPOIGuideCategorySelectionPresenter {

    weak private var display: SCBasicPOIGuideDisplaying?

    private let basicPOIGuideWorker: SCBasicPOIGuideWorking
    private let cityContentSharedWorker: SCCityContentSharedWorking
    private let injector: SCToolsInjecting & SCBasicPOIGuideServiceInjecting & SCAdjustTrackingInjection

    private var poiCategory: [POICategoryInfo]?
    private var presentation: [POICategoryInfo]?
    
    private var errorWhileLoading = false
	private let userDefaultsHelper: UserDefaultsHelping

    init(basicPOIGuideWorker: SCBasicPOIGuideWorking, cityContentSharedWorker: SCCityContentSharedWorking,
		 injector: SCToolsInjecting & SCBasicPOIGuideServiceInjecting & SCAdjustTrackingInjection, poiCategory: [POICategoryInfo],
		 userDefaultsHelper: UserDefaultsHelping = UserdefaultHelper()) {

        self.basicPOIGuideWorker = basicPOIGuideWorker
        self.cityContentSharedWorker = cityContentSharedWorker
        self.injector = injector
        self.poiCategory = poiCategory
        
		self.userDefaultsHelper = userDefaultsHelper
        self.loadCategoryData()
        self.setupNotifications()
    }
    
    deinit {
        SCDataUIEvents.discardNotifications(for: self)
    }
    
    private func setupNotifications() {
        SCDataUIEvents.registerNotifications(for: self, on: .didChangePOICategory, with: #selector(refreshUIContent))
    }
    
    @objc private func refreshUIContent() {
        self.poiCategory = self.basicPOIGuideWorker.getCityPOICategories() ?? []
        
        if self.poiCategory?.count == 0 && self.errorWhileLoading {
            self.display?.showOverlayWithGeneralError()
            
        } else if self.poiCategory?.count == 0{
            self.display?.showOverlayWithActivityIndicator()
            
        } else {
            self.display?.hideOverlay()
            
            if let presentation = self.poiCategory  {
                self.updateUI(with: presentation)
            }
        }
    }
    
    private func updateUI(with presentation: [POICategoryInfo]) {
        self.presentation = presentation
        self.display?.updateAllPOICategoryItems(with: presentation)
        self.display?.showPOICategoryMarker(for: SCUserDefaultsHelper.getPOICategory() ?? "", color: kColor_cityColor)
    }
    
    
    private func loadCategoryData(){
        self.basicPOIGuideWorker.triggerPOICategoriesUpdate(for: self.cityContentSharedWorker.getCityID(), errorBlock: { (error) in
            if error != nil {
                if  case .noInternet = error! {
                    self.display?.showErrorDialog(SCWorkerError.noInternet, retryHandler: {self.loadCategoryData()}, showCancelButton: true, additionalButtonTitle: nil, additionButtonHandler: nil)
                }
                else{
                    self.display?.showErrorDialog(error!, retryHandler: {self.loadCategoryData()}, showCancelButton: true)
                }
                
                self.errorWhileLoading = true
            }
            self.refreshUIContent()
        })
    }
    
}

// MARK: - SCPresenting
extension SCBasicPOIGuideCategorySelectionPresenter: SCPresenting {
    
    func viewDidLoad() {
        self.display?.setupUI()
        self.refreshUIContent()
    }
    
    func viewWillAppear() {
        self.refreshUIContent()
    }
    
    func viewDidAppear() {
        
    }
}

// MARK: - SCBasicPOIGuidePresenting
extension SCBasicPOIGuideCategorySelectionPresenter: SCBasicPOIGuidePresenting {
    
    func setDisplay(_ display: SCBasicPOIGuideDisplaying){
        self.display = display
    }
    
    func categoryWasSelected(categoryName: String, categoryID: Int, categoryGroupIcon: String){
        
        let cityID = self.cityContentSharedWorker.getCityID()
        
        self.injector.trackEvent(eventName: AnalyticsKeys.EventName.changePOICategory)

        self.basicPOIGuideWorker.triggerPOIUpdate(for: cityID, latitude: Double(SCUserDefaultsHelper.getCurrentLocation().coordinate.latitude), longitude: Double(SCUserDefaultsHelper.getCurrentLocation().coordinate.longitude), categoryId: categoryID, errorBlock: { (error) in

            guard error == nil else {
                if  case .noInternet = error! {
                    self.display?.showErrorDialog(SCWorkerError.noInternet, retryHandler: {self.categoryWasSelected(categoryName: categoryName, categoryID: categoryID, categoryGroupIcon: categoryGroupIcon)}, showCancelButton: true, additionalButtonTitle: nil, additionButtonHandler: nil)
                }else{
                    self.display?.showErrorDialog(error!, retryHandler: {self.categoryWasSelected(categoryName: categoryName, categoryID: categoryID, categoryGroupIcon: categoryGroupIcon)}, showCancelButton: true)
                }
                return
            }

            DispatchQueue.main.async { [weak self] in
				guard let self = self else { return }

                // available when when we will dismiss the category selection controller
				self.userDefaultsHelper.setPOICategory(poiCategory: categoryName)
				self.userDefaultsHelper.setPOICategoryID(poiCategoryID: categoryID)
				self.userDefaultsHelper.setPOICategoryGroupIcon(poiCategory: categoryGroupIcon)
				self.userDefaultsHelper.setPOIInfo(poiInfo: self.basicPOIGuideWorker.getCityPOI() ?? [])
				self.userDefaultsHelper.setSelectedCityID(id: self.cityContentSharedWorker.getCityID())

                SCDataUIEvents.postNotification(for: .didChangePOI)
                
                SCUtilities.delay(withTime: 0.0, callback: {
                    self.display?.dismiss()
                })
            }

        })
    }
    
    func closeButtonWasPressed(){
        self.display?.dismiss()
    }
    
    func didPressGeneralErrorRetryBtn() {
        self.display?.showOverlayWithActivityIndicator()
        SCUtilities.delay(withTime: 0.3, callback: {
            self.refreshUIContent()
        })
        
    }
}
