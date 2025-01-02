//
//  SCFahrradparkenServiceDetail.swift
//  OSCA
//
//  Created by Bhaskar N S on 19/05/23.
//  Copyright © 2023 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import Foundation
import UIKit

enum Services {
    case defectReporter
    case fahrradParken(flow: FahrradParkenFlow)
}
enum FahrradParkenFlow {
    case submitRequest
    case viewRequest
}

class SCFahrradparkenServiceDetail: SCServiceDetailProvider {

    private let serviceData: SCBaseComponentItem
    private let injector: SCServicesInjecting & SCAdjustTrackingInjection
    private let cityContentSharedWorker: SCCityContentSharedWorking
    private let fahrradParkenReporterWorker: SCFahrradParkenReporterWorking = SCFahrradParkenReporterWoker(requestFactory: SCRequest())
    private var primaryButtonTitle: String = ""
    private var secondayButtonTitle: String = ""
    
    init(serviceData: SCBaseComponentItem,
         injector: SCServicesInjecting & SCAdjustTrackingInjection,
         cityContentSharedWorker: SCCityContentSharedWorking) {
        self.serviceData = serviceData
        self.injector = injector
        self.cityContentSharedWorker = cityContentSharedWorker
        if let actions = serviceData.itemBtnActions {
            for action in actions {
                if let serviceAction = action.modelServiceAction {
                    if serviceAction.actionOrder == 2 {
                        primaryButtonTitle = serviceAction.visibleText
                    } else if serviceAction.actionOrder == 1 {
                        secondayButtonTitle = serviceAction.visibleText
                    }
                }
            }
        }
    }
    
    func getServiceTitle() -> String {
        serviceData.itemTitle
    }
    
    func getBadgeDescriptionText() -> String? {
        nil
    }
    
    func getBadgeCount() -> String {
        "0"
    }
    
    func getButtonText() -> String {
        return primaryButtonTitle
    }
    
    func getSecondaryButtonText() -> String? {
        return secondayButtonTitle
    }
    
    func getPushController() -> UIViewController {
        return UIViewController()
    }
    
    func getButtonActionController() -> UIViewController? {
        return nil
    }
    
    func getButtonActionController(month: String?, completion: @escaping (UIViewController?, SCWorkerError?, Bool) -> Void) {
        let cityId = cityContentSharedWorker.getCityID()
        fahrradParkenReporterWorker.getFahrradparkenCategories(cityId: "\(cityId)") { (categories, error) in

            guard error == nil else {
                completion(nil, error, false)
                return
            }

            let defectReporterCategoryViewController = self.injector.getDefectReporterCategoryViewController(categoryList: categories,
                                                                                                             serviceData: self.serviceData,
                                                                                                             serviceFlow: .fahrradParken(flow: .submitRequest))

            completion(defectReporterCategoryViewController, nil, true)
        }
    }
    
    func getServiceStatusButtonActionController(completion: @escaping (UIViewController?, SCWorkerError?, Bool) -> Void) {
        let cityId = cityContentSharedWorker.getCityID()
        fahrradParkenReporterWorker.getFahrradparkenCategories(cityId: "\(cityId)") { (categories, error) in

            guard error == nil else {
                completion(nil, error, false)
                return
            }

            let defectReporterCategoryViewController = self.injector.getDefectReporterCategoryViewController(categoryList: categories,
                                                                                                             serviceData: self.serviceData,
                                                                                                             serviceFlow: .fahrradParken(flow: .viewRequest))
            completion(defectReporterCategoryViewController, nil, true)
        }
    }
    
    func getServiceID() -> String {
        serviceData.itemID
    }
    
    func submitDefect(cityId: String, defectRequest: SCModelDefectRequest, completion: @escaping ((_ uniqueId : String?, _ error: SCWorkerError?) -> Void)) {
        fahrradParkenReporterWorker.submitDefect(cityId: cityId, defectRequest: defectRequest, completion: completion)
    }
    
    func uploadDefectImage(cityId: String, imageData: Data, completion: @escaping ((_ mediaURL : String?, _ error: SCWorkerError?) -> Void)) {
        fahrradParkenReporterWorker.uploadDefectImage(cityId: cityId, imageData: imageData, completion: completion)
    }
}
