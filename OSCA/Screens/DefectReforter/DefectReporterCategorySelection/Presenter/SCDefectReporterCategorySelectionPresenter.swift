//
//  SCDefectReporterCategorySelectionPresenter.swift
//  OSCA
//
//  Created by Harshada Deshmukh on 06/05/21.
//  Copyright © 2021 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import Foundation
import UIKit

class SCDefectReporterCategorySelectionPresenter {
    
    weak private var display: SCDefectReporterCategorySelectionViewDisplay?
    private let injector: SCServicesInjecting & SCDefectReporterInjecting
    private let worker: SCDefectReporterWorking
    var category: [SCModelDefectCategory]?
    private let serviceData: SCBaseComponentItem
    var serviceFlow: Services = .defectReporter

    init(serviceData: SCBaseComponentItem,
         injector: SCServicesInjecting & SCDefectReporterInjecting,
         worker : SCDefectReporterWorking,
         category : [SCModelDefectCategory] ) {
        
        self.injector = injector
        self.worker = worker
        self.category = category
        self.serviceData = serviceData
    }
}

extension SCDefectReporterCategorySelectionPresenter : SCDefectReporterCategorySelectionPresenting {
    
    func viewDidLoad() {
        
        display?.reloadCategoryList(self.category ?? [])
        display?.setNavigation(title: LocalizationKeys.SCDefectReporterCategorySelectionPresenter.dr001ChooseCategoryLabel.localized())
    }
         
    func setDisplay(_ display : SCDefectReporterCategorySelectionViewDisplay) {
        self.display = display
    }

    func didSelectCategory(_ category : SCModelDefectCategory) {
            
        // Handle case for subcategory
        if category.subCategories.count != 0 {
            let controller = self.injector.getDefectReporterSubCategoryViewController(category: category, subCategoryList: category.subCategories, serviceData: self.serviceData, service: serviceFlow)
            self.display?.push(viewController: controller)
        }
        else{
            switch serviceFlow {
            case .defectReporter:
                let controller = self.injector.getDefectReporterLocationViewController(category: category, subCategory: nil,
                                                                                       serviceData: self.serviceData,
                                                                                       includeNavController: true,
                                                                                       service: serviceFlow,
                                                                                       completionAfterDismiss: nil)
                self.display?.present(viewController: controller)
            case .fahrradParken(let flow):
                switch flow {
                case .viewRequest:
                    let controller = self.injector.getFahrradparkenReportedLocationViewController(category: category, subCategory: nil,
                                                                                                  serviceData: self.serviceData,
                                                                                                  includeNavController: false,
                                                                                                  service: serviceFlow,
                                                                                                  completionAfterDismiss: nil)
                    self.display?.push(viewController: controller)
                case .submitRequest:
                    let controller = self.injector.getFahrradparkenReportedLocationViewController(category: category, subCategory: nil,
                                                                                                  serviceData: self.serviceData,
                                                                                                  includeNavController: true,
                                                                                                  service: serviceFlow,
                                                                                                  completionAfterDismiss: nil)
                    self.display?.present(viewController: controller)
                }
            
            }
        }
    }

}
