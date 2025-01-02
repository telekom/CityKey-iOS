//
//  WasteCalendarService.swift
//  OSCA
//
//  Created by Rutvik Kanbargi on 10/09/20.
//  Copyright © 2020 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

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
