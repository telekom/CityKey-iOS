//
//  WasteCalendarService.swift
//  OSCA
//
//  Created by Michael Fischer on 12/07/20.
//  Copyright © 2020 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import Foundation
import UIKit

class SCCitizenSurveyService: SCServiceDetailProvider, SCDisplaying {

    private let serviceData: SCBaseComponentItem
    private let injector: SCServicesInjecting & SCCitizenSurveyServiceInjecting & SCAdjustTrackingInjection
    private let cityContentSharedWorker: SCCityContentSharedWorking
    private let surveyWorker: SCCitizenSurveyWorking

    init(serviceData: SCBaseComponentItem,
         injector: SCServicesInjecting & SCCitizenSurveyServiceInjecting & SCAdjustTrackingInjection,
         cityContentSharedWorker: SCCityContentSharedWorking,
         surveyWorker: SCCitizenSurveyWorking) {
        self.serviceData = serviceData
        self.injector = injector
        self.cityContentSharedWorker = cityContentSharedWorker
        self.surveyWorker = surveyWorker
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
        surveyWorker.getSurveyOverview(ciyId: "\(cityId)") { (surveyList, error) in

            guard error == nil else {
                completion(nil, error, false)
                return
            }

            let citizenSurveyOverviewController = self.injector.getCitizenSurveyOverViewController(surveyList: surveyList, serviceData: self.serviceData)
            completion(citizenSurveyOverviewController, nil, true)
        }
    }
}
