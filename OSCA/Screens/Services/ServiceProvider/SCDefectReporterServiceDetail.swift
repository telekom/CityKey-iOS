//
//  SCDefectReporterServiceDetail.swift
//  OSCA
//
//  Created by Harshada Deshmukh on 04/05/21.
//  Copyright © 2021 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import Foundation
import UIKit

class SCDefectReporterServiceDetail: SCServiceDetailProvider {
    
    private let serviceData: SCBaseComponentItem
    private let injector: SCServicesInjecting & SCAdjustTrackingInjection// & SCDefectReporterInjecting
    private let cityContentSharedWorker: SCCityContentSharedWorking
    private let defectReporterWorker: SCDefectReporterWorking

    init(serviceData: SCBaseComponentItem,
         injector: SCServicesInjecting & SCAdjustTrackingInjection,//& SCDefectReporterInjecting,
         cityContentSharedWorker: SCCityContentSharedWorking,
         defectReporterWorker: SCDefectReporterWorking) {
        self.serviceData = serviceData
        self.injector = injector
        self.cityContentSharedWorker = cityContentSharedWorker
        self.defectReporterWorker = defectReporterWorker
    }

    func getServiceTitle() -> String {
        return serviceData.itemTitle
    }

    func getBadgeDescriptionText() -> String? {
        // HARSHADA TODO - Uncomment when we implementing More info screen
//        return "d_001_defect_reporter_more_info_button".localized()
        return serviceData.helpLinkTitle
    }

    func getButtonText() -> String {
        return serviceData.itemBtnActions?.first?.title ?? LocalizationKeys.SCDefectReporterServiceDetail.d001DefectReporterDetailButtonLabel.localized()
    }
    
    func getServiceID() -> String {
        serviceData.itemID
    }

    func getBadgeCount() -> String {
        return "0"
    }

    func getPushController() -> UIViewController {
        // HARSHADA TODO
        let controller = self.injector.getServicesMoreInfoViewController(for: self, injector: injector)
        return controller

    }

    func getButtonActionController() -> UIViewController? {
        return nil
    }
    
    func getButtonActionController(month: String?, completion: @escaping (UIViewController?, SCWorkerError?, Bool) -> Void) {
        
        let cityId = cityContentSharedWorker.getCityID()
        defectReporterWorker.getDefectCategories(cityId: "\(cityId)") { (defectReporterCategories, error) in

            guard error == nil else {
                completion(nil, error, false)
                return
            }

            let defectReporterCategoryViewController = self.injector.getDefectReporterCategoryViewController(categoryList: defectReporterCategories, serviceData: self.serviceData, serviceFlow: .defectReporter)
            completion(defectReporterCategoryViewController, nil, true)

        }
    }
    
    func submitDefect(cityId: String, defectRequest: SCModelDefectRequest, completion: @escaping ((String?, SCWorkerError?) -> Void)) {
        defectReporterWorker.submitDefect(cityId: cityId, defectRequest: defectRequest, completion: completion)
    }
    
    func uploadDefectImage(cityId: String, imageData: Data, completion: @escaping ((_ mediaURL : String?, _ error: SCWorkerError?) -> Void)) {
        defectReporterWorker.uploadDefectImage(cityId: cityId, imageData: imageData, completion: completion)
    }
}
