//
//  SCDefectReporterSubCategoryPresenter.swift
//  OSCA
//
//  Created by Harshada Deshmukh on 06/05/21.
//  Copyright © 2021 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import Foundation
import UIKit

class SCDefectReporterSubCategoryPresenter {
    
    weak private var display: SCDefectReporterSubCategoryViewDisplay?
    private let injector: SCServicesInjecting & SCDefectReporterInjecting
    private let worker: SCDefectReporterWorking
    var category: SCModelDefectCategory?
    var subCategory: [SCModelDefectSubCategory]?
    private let serviceData: SCBaseComponentItem
    var serviceFlow: Services = .defectReporter

    init(serviceData: SCBaseComponentItem,
         injector: SCServicesInjecting & SCDefectReporterInjecting,
         worker : SCDefectReporterWorking,
         category: SCModelDefectCategory,
         subCategory : [SCModelDefectSubCategory] ) {
        
        self.injector = injector
        self.worker = worker
        self.category = category
        self.subCategory = subCategory
        self.serviceData = serviceData
    }
}

extension SCDefectReporterSubCategoryPresenter : SCDefectReporterSubCategoryPresenting {
    
    func viewDidLoad() {
      
        display?.reloadSubCategoryList(self.subCategory ?? [])
        display?.setNavigation(title: self.category!.serviceName)
    }
         
    func setDisplay(_ display : SCDefectReporterSubCategoryViewDisplay) {
        self.display = display
    }

    func didSelectSubCategory(_ subCategory : SCModelDefectSubCategory) {
        
        switch serviceFlow {
        case .defectReporter:
            let controller = self.injector.getDefectReporterLocationViewController(category: self.category!,
                                                                                   subCategory: subCategory,
                                                                                   serviceData: self.serviceData,
                                                                                   includeNavController: true,
                                                                                   service: serviceFlow, completionAfterDismiss: nil)
            self.display?.present(viewController: controller)
        case .fahrradParken(let flow):
            switch flow {
            case .viewRequest:
                let controller = self.injector.getFahrradparkenReportedLocationViewController(category: category!,
                                                                                              subCategory: nil,
                                                                                              serviceData: self.serviceData,
                                                                                              includeNavController: false,
                                                                                              service: serviceFlow,
                                                                                              completionAfterDismiss: nil)
                self.display?.push(viewController: controller)
            case .submitRequest:
                let controller = self.injector.getFahrradparkenReportedLocationViewController(category: category!,
                                                                                              subCategory: nil,
                                                                                              serviceData: self.serviceData,
                                                                                              includeNavController: true,
                                                                                              service: serviceFlow,
                                                                                              completionAfterDismiss: nil)
                self.display?.present(viewController: controller)
            }
        
        }
    }

}
