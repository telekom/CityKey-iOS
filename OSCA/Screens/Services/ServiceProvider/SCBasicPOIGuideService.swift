//
//  SCBasicPOIGuideService.swift
//  OSCA
//
//  Created by Harshada Deshmukh on 26/02/21.
//  Copyright © 2021 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import Foundation
import UIKit

class SCBasicPOIGuideService: SCServiceDetailProvider, SCDisplaying {

    private let serviceData: SCBaseComponentItem
    private let injector: SCServicesInjecting & SCBasicPOIGuideServiceInjecting & SCAdjustTrackingInjection
    private let cityContentSharedWorker: SCCityContentSharedWorking
    private let basicPOIGuideWorker: SCBasicPOIGuideWorking

    init(serviceData: SCBaseComponentItem,
         injector: SCServicesInjecting & SCBasicPOIGuideServiceInjecting & SCAdjustTrackingInjection,
         cityContentSharedWorker: SCCityContentSharedWorking,
         basicPOIGuideWorker: SCBasicPOIGuideWorking) {
        self.serviceData = serviceData
        self.injector = injector
        self.cityContentSharedWorker = cityContentSharedWorker
        self.basicPOIGuideWorker = basicPOIGuideWorker
    }
    
    func getServiceTitle() -> String {
        return serviceData.itemTitle
    }

    func getBadgeDescriptionText() -> String? {
        return serviceData.helpLinkTitle
        //return "survey_001_data_protection_btn".localized()
    }
    
    func getServiceID() -> String {
        serviceData.itemID
    }

    func getButtonText() -> String {
        return serviceData.itemBtnActions?.first?.title ?? ""
    }

    func getBadgeCount() -> String {
        return "0"
    }

    func getPushController() -> UIViewController {
        return injector.getServicesMoreInfoViewController(for: self, injector: injector)
    }

    func getButtonActionController() -> UIViewController? {
        return nil
    }

    func getButtonActionController(month: String?, completion: @escaping (UIViewController?, SCWorkerError?, Bool) -> Void) {
        
        let cityId = cityContentSharedWorker.getCityID()
        basicPOIGuideWorker.getCityPOICategories(cityId: "\(cityId)") { (poiCategories, error) in

            guard error == nil else {
                completion(nil, error, false)
                return
            }

            let basicPOIGuideListMapViewController = self.injector.getBasicPOIGuideListMapViewController(with: self.basicPOIGuideWorker.getCityPOI() ?? [], poiCategory: self.basicPOIGuideWorker.getCityPOICategories() ?? [], item: self.serviceData)
            completion(basicPOIGuideListMapViewController, nil, true)
        
        }
          
    }
}
