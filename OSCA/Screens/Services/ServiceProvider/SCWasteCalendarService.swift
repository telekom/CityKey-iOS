/*
Created by Rutvik Kanbargi on 10/09/20.
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

SPDX-FileCopyrightText: 2025 Deutsche Telekom AG, Rutvik Kanbargi
SPDX-License-Identifier: Apache-2.0 AND LicenseRef-Deutsche-Telekom-Brand
License-Filename: LICENSES/Apache-2.0.txt LICENSES/LicenseRef-Deutsche-Telekom-Brand.txt
*/

import Foundation
import UIKit

class SCWasteCalendarService: SCServiceDetailProvider, SCDisplaying {

    private let serviceData: SCBaseComponentItem
    private let injector: SCServicesInjecting & SCWasteServiceInjecting & SCAdjustTrackingInjection
    private let wasteCalendarWorker: SCWasteCalendarWorking
    private let cityContentSharedWorker: SCCityContentSharedWorking
    private let dataCache: SCDataCaching
    private weak var delegate: SCWasteAddressViewResultDelegate?

    init(serviceData: SCBaseComponentItem,
         injector: SCServicesInjecting & SCWasteServiceInjecting & SCAdjustTrackingInjection,
         wasteCalendarWorker: SCWasteCalendarWorking,
         cityContentSharedWorker: SCCityContentSharedWorking,
         dataCache: SCDataCaching,
         delegate: SCWasteAddressViewResultDelegate?) {
        self.serviceData = serviceData
        self.injector = injector
        self.wasteCalendarWorker = wasteCalendarWorker
        self.cityContentSharedWorker = cityContentSharedWorker
        self.dataCache = dataCache
        self.delegate = delegate
    }

    func getServiceTitle() -> String {
        return serviceData.itemTitle
    }

    func getBadgeDescriptionText() -> String? {
        return serviceData.helpLinkTitle
    }
    
    func getServiceID() -> String {
        serviceData.itemID
    }

    func getButtonText() -> String {
        return serviceData.itemBtnActions?.first?.title ?? ""
    }

    func getBadgeCount() -> String {
        return ""
    }


    func getPushController() -> UIViewController {
        return injector.getServicesMoreInfoViewController(for: self, injector: injector)
    }

    func getButtonActionController() -> UIViewController? {
        return nil
    }

    func getButtonActionController(month: String? = nil, completion: @escaping (UIViewController?, SCWorkerError?, Bool) -> Void) {
        
        let cityID = cityContentSharedWorker.getCityID()
        let wasteAddress = dataCache.getWasteCalendarAddress(cityID: cityID)
        
        self.wasteCalendarWorker.getWasteCalendar(for: cityID, street: wasteAddress?.streetName, houseNr: wasteAddress?.houseNumber) {
            [weak self] (wasteCalendarItems, wasteCalendarAddress, wasteReminders, error) in

            guard error == nil else {
                switch error! {
                case .fetchFailed(let errorDetail):
                    
                    switch errorDetail.errorCode {
                    case "waste.address.wrong":
                        self?.wasteCalendarWorker.getUserWasteAddress(for: cityID){
                            [weak self] (wasteCalendarAddress, error) in
                            // CALL THE FTU PROCESS WITH CURRENT USER ADDRESS
                            if let serviceData = self?.serviceData {
                                let addresViewController = self?.injector.getWasteAddressController(delegate: self?.delegate, wasteAddress: wasteCalendarAddress, item: serviceData)
                                completion(addresViewController, nil, false)
                            }
                            return
                        }
                    case "waste.address.not.exists":
                        // CALL THE FTU PROCESS
                        if let serviceData = self?.serviceData {
                            let addresViewController = self?.injector.getWasteAddressController(delegate: self?.delegate, wasteAddress: nil, item: serviceData)
                            completion(addresViewController, nil, false)
                        }
                        return
                    case "calendar.not.exist":
                        self?.showErrorDialog(error!, retryHandler: { self?.getButtonActionController(completion: completion)})
                    default:
                        self?.showErrorDialog(error!, retryHandler: { self?.getButtonActionController(completion: completion)})
                    }
                default:
                    self?.showErrorDialog(error!, retryHandler:  { self?.getButtonActionController(completion: completion)})
                }
                completion(nil, error, false)
                return
            }
            
            
            if let serviceData = self?.serviceData {
                let controller = self?.injector.getWasteCalendarViewController(wasteCalendarItems: wasteCalendarItems ?? [], calendarAddress: wasteCalendarAddress, wasteReminders: wasteReminders, item: serviceData, month: month)
                completion(controller, nil, true)
            }
        }
    }
}
