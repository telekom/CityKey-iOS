/*
Created by Bhaskar N S on 19/05/23.
Copyright © 2023 Deutsche Telekom AG - VTI Organization. All rights reserved.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    https://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

In accordance with Sections 4 and 6 of the License, the following exclusions apply:

    1. Trademarks & Logos – The names, logos, and trademarks of the Licensor are not covered by this License and may not be used without separate permission.
    2. Design Rights – Visual identities, UI/UX designs, and other graphical elements remain the property of their respective owners and are not licensed under the Apache License 2.0.
    3: Non-Coded Copyrights – Documentation, images, videos, and other non-software materials require separate authorization for use, modification, or distribution.

These elements are not considered part of the licensed Work or Derivative Works unless explicitly agreed otherwise. All elements must be altered, removed, or replaced before use or distribution. All rights to these materials are reserved, and Contributor accepts no liability for any infringing use. By using this repository, you agree to indemnify and hold harmless Contributor against any claims, costs, or damages arising from your use of the excluded elements.

SPDX-FileCopyrightText: 2025 Deutsche Telekom AG, Bhaskar N S
SPDX-License-Identifier: Apache-2.0 AND LicenseRef-Deutsche-Telekom-Brand
License-Filename: LICENSES/Apache-2.0.txt LICENSES/LicenseRef-Deutsche-Telekom-Brand.txt
*/

import Foundation
import UIKit
import CoreLocation

class FahrradparkenReportedLocationPresenter: FahrradparkenReportedLocationPresenting {
    weak private var display: FahrradparkenReportedLocationViewDisplay?
    private let injector: SCServicesInjecting & SCDefectReporterInjecting & SCAdjustTrackingInjection
    private let fahrradParkenReporterWorker: SCFahrradParkenReporterWorking
    var category: SCModelDefectCategory?
    var subCategory: SCModelDefectSubCategory?
    private let serviceData: SCBaseComponentItem
    var reportedLocations: [FahrradparkenLocation]?
    private var serviceFlow: Services
    private let utilities: SCUtilityUsable
    private let cityContentSharedWorker: SCCityContentSharedWorking
    
    init(injector: SCServicesInjecting & SCDefectReporterInjecting & SCAdjustTrackingInjection,
         fahrradParkenReporterWorker: SCFahrradParkenReporterWorking,
         serviceData: SCBaseComponentItem, category: SCModelDefectCategory?,
         subCategory: SCModelDefectSubCategory?, serviceFlow: Services,
         utilities: SCUtilityUsable = SCUtilities(),
         cityContentSharedWorker: SCCityContentSharedWorking) {
        self.injector = injector
        self.fahrradParkenReporterWorker = fahrradParkenReporterWorker
        self.category = category
        self.subCategory = subCategory
        self.serviceData = serviceData
        self.serviceFlow = serviceFlow
        self.utilities = utilities
        self.cityContentSharedWorker = cityContentSharedWorker
    }
    func setDisplay(_ display: FahrradparkenReportedLocationViewDisplay) {
        self.display = display
    }
    
    func viewDidLoad() {
        trackEvent()
        display?.updateNavigationTitle(navTitle: getNavTitle())
    }
    
    func didTapMarker(with location: FahrradparkenLocation) {
        let vc = injector.getFahrradParkenReportedLocationDetailsViewController(with: location,
                                                                                serviceData: serviceData, compltionHandler: {
            self.display?.updateMarkerState()
        })
        display?.present(viewController: vc)
    }
    
    func fetchReportedLocations(northEastCoordinate: CLLocationCoordinate2D?, southWestCoordinate: CLLocationCoordinate2D?, limit: Int) {
        let cityId = cityContentSharedWorker.getCityID()
        let request = FahrradparkenServiceRequest(northEast: northEastCoordinate,
                                                  southWest: southWestCoordinate,
                                                  limit: limit,
                                                  serviceCode: getServiceCode())
        display?.showBtnActivityIndicator(true)
        fahrradParkenReporterWorker.getFahrradparkenReportedLocations(cityId: "\(cityId)",
                                                                      request: request) { [weak self] reportedLocations, error in
            guard let strongSelf = self else {
                return
            }
            strongSelf.display?.showBtnActivityIndicator(false)
            guard error == nil else {
                switch error {
                case .fetchFailed(_):
                    break//do nothing
                default:
                    strongSelf.display?.showErrorDialog(with: LocalizationKeys.FahrrahdparkenReportedLocationVC.fa012UnknowErrorTitle.localized(),
                                                        retryHandler: nil, showCancelButton: true,
                                                        additionalButtonTitle: nil, additionButtonHandler: nil)
                }
                strongSelf.display?.clearAllMarkers()
                return
            }
            strongSelf.reportedLocations = reportedLocations
            strongSelf.display?.plotMarkersAtReported(locations: reportedLocations)
        }
    }
    
    func displayError(_ error: SCWorkerError) {
        self.display?.showErrorDialog(error)
    }
    
    private func getServiceCode() -> String {
        if let subcategoryServiceCode = subCategory?.serviceCode {
            return subcategoryServiceCode
        } else if let categoryServiceCode = category?.serviceCode {
            return categoryServiceCode
        }
        return ""
    }
    
    func getServiceFlow() -> Services {
        return serviceFlow
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
    
    private func getNavTitle() -> String? {
        return subCategory?.serviceName != nil ? subCategory?.serviceName : category?.serviceName
    }
    
    func closeButtonWasPressed() {
        self.display?.dismiss(completion: nil)
    }
    
    func getLocationForMap() -> CLLocation {
        let userCurrentLocation: CLLocation = SCUserDefaultsHelper.getCurrentLocation()
        if userCurrentLocation != kSelectedCityLocation {
            return userCurrentLocation
        } else {
            return cityContentSharedWorker.getCityLocation()
        }
    }
    
    private func trackEvent() {
        switch serviceFlow {
        case .fahrradParken(let flow):
            switch flow {
            case .submitRequest:
                break
            case .viewRequest:
                injector.trackEvent(eventName: AnalyticsKeys.EventName.openFahrradparkenExistingDefects)
            }
        default:
            break
        }
    }
}
