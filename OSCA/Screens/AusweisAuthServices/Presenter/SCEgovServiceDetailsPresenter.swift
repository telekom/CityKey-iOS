/*
Created by Bharat Jagtap on 21/04/21.
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

SPDX-FileCopyrightText: 2025 Deutsche Telekom AG, Bharat Jagtap
SPDX-License-Identifier: Apache-2.0 AND LicenseRef-Deutsche-Telekom-Brand
License-Filename: LICENSES/Apache-2.0.txt LICENSES/LicenseRef-Deutsche-Telekom-Brand.txt
*/

import Foundation
import UIKit

protocol SCEgovServiceDetailsPresenting : SCPresenting {
    
    func setDisplay(_ display: SCEgovServiceDetailsDisplay)
    func getServiceImage() -> SCImageURL?
    func getServiceTitle() -> String?
    func getServiceDetails() -> String?
    func getBadgeDescriptionText() -> String?
    func loadGroups()
    func getGroups() -> [SCModelEgovGroup]
    func didSelectGroup(_ group : SCModelEgovGroup)
    func didClickHelpMoreInfoButton()
    
    func didTapOnSearch()
}

class SCEgovServiceDetailsPresenter {
    
    weak private var display: SCEgovServiceDetailsDisplay?
    private let userCityContentSharedWorker: SCUserCityContentSharedWorking
    private let cityContentSharedWorker : SCCityContentSharedWorking
    private let injector: SCEgovServiceInjecting & SCServicesInjecting & SCAdjustTrackingInjection
    private let serviceData: SCBaseComponentItem
    private let serviceDetail: SCServiceDetailProvider
    private let worker: SCEgovServiceWorking
    
    init(userCityContentSharedWorker: SCUserCityContentSharedWorking,
         cityContentSharedWorker : SCCityContentSharedWorking,
         injector: SCEgovServiceInjecting & SCServicesInjecting & SCAdjustTrackingInjection,
         serviceData: SCBaseComponentItem,
         serviceDetail: SCServiceDetailProvider,
         worker : SCEgovServiceWorking) {
        
        self.userCityContentSharedWorker = userCityContentSharedWorker
        self.cityContentSharedWorker = cityContentSharedWorker
        self.injector = injector
        self.serviceData = serviceData
        self.serviceDetail = serviceDetail
        self.worker = worker
    }
    
}

extension SCEgovServiceDetailsPresenter : SCEgovServiceDetailsPresenting {
    
    func setDisplay(_ display: SCEgovServiceDetailsDisplay) {
        self.display = display
    }
        
    func getServiceTitle() -> String? {
        return serviceData.itemTitle
    }

    func getServiceDetails() -> String? {
        return serviceData.itemDetail

//        if let attrString =  serviceData.itemDetail?.htmlAttributedString?.trimmedAttributedString(set: .whitespacesAndNewlines) {
//            let htmlAttributedString = NSMutableAttributedString(attributedString: attrString)
//            htmlAttributedString.replaceFont(with:UIFont.SystemFont.medium.forTextStyle(style: .body, size: (UIScreen.main.bounds.size.width) == 320 ? 14.0 : 16.0, maxSize: nil),color: UIColor(named: "CLR_LABEL_TEXT_BLACK")!)
//            return htmlAttributedString
//        }
//        return nil

    }
    
    func getBadgeDescriptionText() -> String? {
        return serviceDetail.getBadgeDescriptionText()
    }
    
    func getServiceImage() -> SCImageURL? {
        return serviceData.itemImageURL
    }

    func viewDidLoad() {
        loadGroups()
    }
    
    func viewWillAppear() {
        
    }
    
    func viewDidAppear() {
        
    }
    
    func loadGroups() {
        
        display?.displayLoadingIndicator()
        
        self.worker.getEgovGroups( cityId: "\(self.cityContentSharedWorker.getCityID())") { [weak self] (result, error) in

            self?.display?.hideLoadingIndicator()

            if let _ = error {
                
                self?.display?.displayErrorFailedLoadingGroups()
                
            } else if result.count > 0  {
                
                self?.display?.displayGroups(result)
                
            } else {
                self?.display?.displayErrorZeroGroups()
            }
            
        }
    }
    
    func getGroups() -> [SCModelEgovGroup] {
        
        if let groups = self.worker.groups {
            return groups
        } else {
            return []
        }
    }
    
    func didSelectGroup(_ group : SCModelEgovGroup) {
        //MARK: Add "DigitalAdmSubcategories" event
       
        var parameters = [String:String]()
        parameters[AnalyticsKeys.TrackedParamKeys.categoryOfServices] = serviceData.itemTitle
        parameters[AnalyticsKeys.TrackedParamKeys.citySelected] = kSelectedCityName
        parameters[AnalyticsKeys.TrackedParamKeys.cityId] = kSelectedCityId
        parameters[AnalyticsKeys.TrackedParamKeys.subcategoryOfServices] = group.groupName
        parameters[AnalyticsKeys.TrackedParamKeys.userStatus] = SCAuth.shared.isUserLoggedIn() ? AnalyticsKeys.TrackedParamKeys.loggedIn : AnalyticsKeys.TrackedParamKeys.notLoggedIn
        if SCAuth.shared.isUserLoggedIn(), let userProfile = SCUserDefaultsHelper.getProfile() {
            parameters[AnalyticsKeys.TrackedParamKeys.userZipcode] = userProfile.postalCode
        }
        self.injector.trackEvent(eventName: AnalyticsKeys.EventName.digitalAdmSubcategories, parameters: parameters)

        let viewController = self.injector.getEgovServicesListViewController(for: self.serviceDetail, worker: self.worker, injector: self.injector, group : group)
        display?.pushViewController(viewController)
    }
    
    func didClickHelpMoreInfoButton() {
        
        let viewController = self.injector.getEgovServiceHelpViewController(for: serviceDetail, worker: worker, injector: self.injector)
        display?.pushViewController(viewController)
        
    }
            
    
    func didTapOnSearch() {
        
        var servicesArray = [SCModelEgovService]()
        worker.groups?.forEach({ group in
            servicesArray.append(contentsOf: group.services)
        })
        let eGovSearchWorker = SCEgovSearchWorker(services: servicesArray)
        
        let viewController = self.injector.getEgovSearchViewController(worker: eGovSearchWorker, injector: self.injector, serviceDetail: self.serviceDetail)
        
        display?.pushViewController(viewController)

    }
}
