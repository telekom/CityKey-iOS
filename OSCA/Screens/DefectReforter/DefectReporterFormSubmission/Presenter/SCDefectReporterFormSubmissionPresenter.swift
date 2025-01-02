//
//  SCDefectReporterFormSubmissionPresenter.swift
//  OSCA
//
//  Created by Harshada Deshmukh on 09/05/21.
//  Copyright © 2021 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import UIKit

class SCDefectReporterFormSubmissionPresenter {
    
    weak private var display: SCDefectReporterFormSubmissionViewDisplay?
    
    private let injector: SCAdjustTrackingInjection & SCDefectReporterInjecting
    private let cityContentSharedWorker: SCCityContentSharedWorking
    var category: SCModelDefectCategory?
    var subCategory : SCModelDefectSubCategory?
    var uniqueId: String
    var utitlies: SCUtilityUsable
    let serviceFlow: Services
    let reporterEmailId: String?

    init(injector: SCAdjustTrackingInjection & SCDefectReporterInjecting,
         cityContentSharedWorker: SCCityContentSharedWorking,
         uniqueId: String,
         category: SCModelDefectCategory,
         subCategory: SCModelDefectSubCategory? = nil,
         utitlies: SCUtilityUsable = SCUtilities(),
         serviceFlow: Services, reporterEmailId: String?) {

        self.injector = injector
        self.cityContentSharedWorker = cityContentSharedWorker
        self.uniqueId = uniqueId
        self.category = category
        self.subCategory = subCategory
        self.utitlies = utitlies
        self.serviceFlow = serviceFlow
        self.reporterEmailId = reporterEmailId
    }
    
}

extension SCDefectReporterFormSubmissionPresenter: SCPresenting {
    
    func viewDidLoad() {
        trackEvent()
        self.display?.setNavigation(title: self.subCategory != nil ? self.subCategory!.serviceName : self.category!.serviceName)
        self.display?.setupUI(category: self.category!, subCategory: self.subCategory ?? nil, uniqueId: self.uniqueId)
    }
    
    private func trackEvent() {
        var eventName: String
        switch serviceFlow {
        case .defectReporter:
            // SMARTC-13058 : Track additional events via Adjust - Defect Reporter
            // User submits a defect by pressing the submit button
            eventName = AnalyticsKeys.EventName.defectSubmitted
        case .fahrradParken(_):
            eventName = AnalyticsKeys.EventName.FahrradparkenSubmitted
        }
        self.injector.trackEvent(eventName: eventName)
    }
}

extension SCDefectReporterFormSubmissionPresenter : SCDefectReporterFormSubmissionPresenting {
    
    func setDisplay(_ display: SCDefectReporterFormSubmissionViewDisplay) {
        self.display = display
    }
    
    func okBtnWasPressed(){
        self.handleBackNavigationFlow()
    }
    
    private func handleBackNavigationFlow(){
        utitlies.dismissAnyPresentedViewController { [weak self] in
            guard let strongSelf = self else {
                return
            }
            let tabBarController = strongSelf.utitlies.topViewController() as? UITabBarController
            if let indexForServiceTab = strongSelf.utitlies.indexForServiceController() {
                tabBarController?.selectedIndex = indexForServiceTab
                let selectedViewController = tabBarController?.selectedViewController as? UINavigationController

                let controller = selectedViewController?.hasViewController(ofKind: SCServiceDetailViewController.self) as! SCServiceDetailViewController
                selectedViewController?.popToViewController(controller, animated: true)
            }
        }
    }
    
    func getCityName() -> String? {
        return cityContentSharedWorker.getCityContentData(for: cityContentSharedWorker.getCityID())?.city.name
    }
    
    func getCityId() -> Int {
        return cityContentSharedWorker.getCityID()
    }
    
    func showFeedbackLabel() -> Bool {
        switch serviceFlow {
        case .defectReporter:
            return true
        case .fahrradParken(_):
            let email = reporterEmailId ?? ""
            return email.isEmpty ? false : true
        }
    }
    
    func getServiceFlow() -> Services {
        return serviceFlow
    }
}
