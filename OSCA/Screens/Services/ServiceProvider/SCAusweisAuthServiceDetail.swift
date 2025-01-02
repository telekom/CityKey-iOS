//
//  SCAusweisAuthServiceDetail.swift
//  OSCA
//
//  Created by Bharat Jagtap on 22/02/21.
//  Copyright © 2021 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import Foundation
import UIKit


class SCAusweisAuthServiceDetail: SCServiceDetailProvider {

    private let serviceData: SCBaseComponentItem
    private let injector: SCServicesInjecting & SCAdjustTrackingInjection
    private let userCityContentSharedWorker: SCUserCityContentSharedWorking

    init(serviceData: SCBaseComponentItem,
         injector: SCServicesInjecting & SCAdjustTrackingInjection,
         userCityContentSharedWorker: SCUserCityContentSharedWorking) {
        self.serviceData = serviceData
        self.injector = injector
        self.userCityContentSharedWorker = userCityContentSharedWorker
    }

    func getServiceTitle() -> String {
        return serviceData.itemTitle
    }

    func getBadgeDescriptionText() -> String? {
        return serviceData.helpLinkTitle;
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
        //injector.getAppointmentOverviewController(serviceData: serviceData)
        return injector.getServicesMoreInfoViewController(for: self, injector: injector)
    }

    func getButtonActionController() -> UIViewController? {
        if let detailBtnAction = serviceData.itemBtnActions?.first,
            let createMeetingUri = detailBtnAction.modelServiceAction?.iosUri,
            let actionUrl = URL(string: createMeetingUri) {
            return injector.getTEVISViewController(for: actionUrl.absoluteString, serviceData: serviceData)
        }
        return nil
    }

    func getButtonActionController(month: String?, completion: @escaping (UIViewController?, SCWorkerError?, Bool) -> Void) {
        
        /*
        if let detailBtnAction = serviceData.itemBtnActions?.first,
            let createMeetingUri = detailBtnAction.modelServiceAction?.iosUri,
            let actionUrl = URL(string: createMeetingUri) {
            let controller = injector.getTEVISViewController(for: actionUrl.absoluteString)
            completion(controller, nil, false)
        }
        completion(nil, nil, false)
         */
        guard let url = serviceData.itemBtnActions?.first?.modelServiceAction?.iosUri else {
            completion(nil, nil , false)
            return
        }
        let title = serviceData.itemTitle
        let serviceWebDetails = SCModelEgovServiceWebDetails(serviceTitle: title , serviceURL: url, serviceType: "eidform")
        let controller = injector.getAusweisAuthServicesDetailController(for: serviceWebDetails)
        completion(controller, nil, true)
        
    }
}
