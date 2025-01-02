//
//  SCDefectReporterLocationPresenter.swift
//  OSCA
//
//  Created by Harshada Deshmukh on 09/05/21.
//  Copyright © 2021 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import UIKit
import MapKit

class SCDefectReporterLocationPresenter {
    
    weak private var display: SCDefectReporterLocationViewDisplay?
    
    private let injector: SCAdjustTrackingInjection & SCDefectReporterInjecting
    private let cityContentSharedWorker: SCCityContentSharedWorking
    var category: SCModelDefectCategory?
    var subCategory: SCModelDefectSubCategory?
    private let serviceData: SCBaseComponentItem
    private let utilities: SCUtilityUsable
    var serviceFlow: Services = .defectReporter

    init(serviceData: SCBaseComponentItem,
         injector: SCAdjustTrackingInjection & SCDefectReporterInjecting,
         cityContentSharedWorker: SCCityContentSharedWorking,
         category: SCModelDefectCategory,
         subCategory: SCModelDefectSubCategory? = nil,
         utilities: SCUtilityUsable = SCUtilities()) {

        self.injector = injector
        self.cityContentSharedWorker = cityContentSharedWorker
        self.category = category
        self.subCategory = subCategory
        self.serviceData = serviceData
        self.utilities = utilities
    }
    
}

extension SCDefectReporterLocationPresenter : SCDefectReporterLocationPresenting {
    
    func setDisplay(_ display: SCDefectReporterLocationViewDisplay) {
        self.display = display
    }

    func closeButtonWasPressed() {
        self.display?.dismiss(completion: nil)
    }
    
    func savePositionBtnWasPressed() {
        utilities.dismissAnyPresentedViewController { [weak self] in
            guard let strongSelf = self else {
                return
            }
            let tabBarController = strongSelf.utilities.topViewController() as? UITabBarController
            if let indexForServiceTab = strongSelf.utilities.indexForServiceController() {
                tabBarController?.selectedIndex = indexForServiceTab
                let selectedViewController = tabBarController?.selectedViewController as? UINavigationController

                let controller = strongSelf.injector.getDefectReporterFormViewController(category: strongSelf.category!,
                                                                                         subCategory: strongSelf.subCategory,
                                                                                         serviceData: strongSelf.serviceData,
                                                                                         serviceFlow: strongSelf.serviceFlow)
                let defectReporterFormViewController = selectedViewController?.containsViewController(ofKind: SCDefectReporterFormViewController.self)
                if defectReporterFormViewController != true {
                    selectedViewController?.pushViewController(controller, animated: true)
                }
            }
        }
    }
    
}

