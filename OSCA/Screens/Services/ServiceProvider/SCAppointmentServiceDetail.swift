//
//  ServiceDetailProvider.swift
//  OSCA
//
//  Created by Rutvik Kanbargi on 04/09/20.
//  Copyright © 2020 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import UIKit

protocol SCServiceDetailProvider {
    func getServiceTitle() -> String
    func getBadgeDescriptionText() -> String?
    func getBadgeCount() -> String
    func getButtonText() -> String
    func getPushController() -> UIViewController
    func getButtonActionController() -> UIViewController?
    func getButtonActionController(month: String?, completion: @escaping (UIViewController?, SCWorkerError?, Bool) -> Void)
    func getServiceID() -> String
    func getSecondaryButtonText() -> String?
    func getServiceStatusButtonActionController(completion: @escaping (UIViewController?, SCWorkerError?, Bool) -> Void)
    func submitDefect(cityId: String, defectRequest: SCModelDefectRequest, completion: @escaping ((_ uniqueId : String?, _ error: SCWorkerError?) -> Void))
    func uploadDefectImage(cityId: String, imageData: Data, completion: @escaping ((_ mediaURL : String?, _ error: SCWorkerError?) -> Void))
}

// this is used to make below methods optional in SCServiceDetailProvider
extension SCServiceDetailProvider {
    func getSecondaryButtonText() -> String? {
        return nil
    }
    
    func getServiceStatusButtonActionController(completion: @escaping (UIViewController?, SCWorkerError?, Bool) -> Void) {
        
    }
    
    func submitDefect(cityId: String, defectRequest: SCModelDefectRequest, completion: @escaping ((_ uniqueId : String?, _ error: SCWorkerError?) -> Void)) {
        
    }
    
    func uploadDefectImage(cityId: String, imageData: Data, completion: @escaping ((_ mediaURL : String?, _ error: SCWorkerError?) -> Void)) {
        
    }
}

class SCAppointmentServiceDetail: SCServiceDetailProvider {

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
        return serviceData.helpLinkTitle ?? LocalizationKeys.SCAppointmentOverviewController.apnmt002PageTitle.localized()
    }

    func getButtonText() -> String {
        return serviceData.itemBtnActions?.first?.title ?? ""
    }

    func getBadgeCount() -> String {
        return "\(userCityContentSharedWorker.getAppointments().filter { $0.isRead == false }.count)"
    }

    func getPushController() -> UIViewController {
        injector.getAppointmentOverviewController(serviceData: serviceData)
    }
    
    func getServiceID() -> String {
        serviceData.itemID
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
        if let detailBtnAction = serviceData.itemBtnActions?.first,
            let createMeetingUri = detailBtnAction.modelServiceAction?.iosUri,
            let actionUrl = URL(string: createMeetingUri) {
            let controller = injector.getTEVISViewController(for: actionUrl.absoluteString , serviceData : self.serviceData )
            completion(controller, nil, false)
        }
        completion(nil, nil, false)
    }
}
