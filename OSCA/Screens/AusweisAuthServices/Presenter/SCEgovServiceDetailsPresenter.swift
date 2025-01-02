//
//  SCEgovServiceDetailsPresenter.swift
//  OSCA
//
//  Created by Bharat Jagtap on 21/04/21.
//  Copyright © 2021 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

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
