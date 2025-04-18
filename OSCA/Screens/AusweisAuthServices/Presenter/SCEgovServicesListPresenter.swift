
/*
Created by Bharat Jagtap on 22/04/21.
Copyright © 2021 Deutsche Telekom AG - VTI Organization. All rights reserved.

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

SPDX-FileCopyrightText: 2025 Deutsche Telekom AG, Bharat Jagtap
SPDX-License-Identifier: Apache-2.0 AND LicenseRef-Deutsche-Telekom-Brand
License-Filename: LICENSES/Apache-2.0.txt LICENSES/LicenseRef-Deutsche-Telekom-Brand.txt
*/

import Foundation
import  UIKit

protocol SCEgovServicesListPresenting : SCPresenting {
    func setDisplay(_ display : SCEgovServicesListViewDisplay)
    func didSelectService(_ service : SCModelEgovService)
    
    func getServiceTitle(service: SCModelEgovService) -> String
    func getServiceDescription(service: SCModelEgovService) -> String
    func getServiceIcon(service: SCModelEgovService) -> UIImage
    func getServiceLinkTitle(service: SCModelEgovService) -> String
}

class SCEgovServicesListPresenter {
    
    weak private var display: SCEgovServicesListViewDisplay?
    private let userCityContentSharedWorker: SCUserCityContentSharedWorking
    private let injector: SCEgovServiceInjecting & SCServicesInjecting & SCAdjustTrackingInjection
    private let serviceDetail: SCServiceDetailProvider
    private let worker: SCEgovServiceWorking
    var group : SCModelEgovGroup
    
    init(userCityContentSharedWorker: SCUserCityContentSharedWorking,
         injector: SCEgovServiceInjecting & SCServicesInjecting & SCAdjustTrackingInjection,
         serviceDetail: SCServiceDetailProvider,
         worker : SCEgovServiceWorking,
         group : SCModelEgovGroup ) {
        
        self.userCityContentSharedWorker = userCityContentSharedWorker
        self.injector = injector
        self.serviceDetail = serviceDetail
        self.worker = worker
        self.group = group
    }
}

extension SCEgovServicesListPresenter : SCEgovServicesListPresenting {
    
    func viewDidLoad() {
      
        display?.reloadServicesList(self.group.services)
        display?.setNavigationTitle(self.group.groupName)
    }
    
    func viewWillAppear() {
        
    }
    
    func viewDidAppear() {
        
    }
         
    func setDisplay(_ display : SCEgovServicesListViewDisplay) {
        self.display = display
    }

    func didSelectService(_ service : SCModelEgovService) {
        if !service.longDescription.isEmpty || service.links.count > 1 {
            
            let controller = injector.getEgovServiceLongDescriptionViewController(service: service)
            self.display?.pushViewController(controller)
            
        } else {
            
            guard let link = service.links.first else { return }
            if link.linkType != "eidform" {
                if let urlToOpen = URL(string: link.link), UIApplication.shared.canOpenURL(urlToOpen) {
                    self.injector.trackEvent(eventName: AnalyticsKeys.EventName.openEGovExternalURL)
                    SCInternalBrowser.showURL(urlToOpen, withBrowserType: .safari, title: service.serviceName)
                }
            } else {
                let serviceWebDetails = SCModelEgovServiceWebDetails(serviceTitle: service.serviceName, serviceURL: link.link, serviceType: link.linkType)
                let controller = injector.getAusweisAuthServicesDetailController(for: serviceWebDetails)
                self.display?.pushViewController(controller)
            }
        }
        
    }
    
    func getServiceTitle(service: SCModelEgovService) -> String {
        return service.serviceName
    }
    
    func getServiceDescription(service: SCModelEgovService) -> String {
        return service.shortDescription
    }
    
    func getServiceIcon(service: SCModelEgovService) -> UIImage {
        
        if !service.longDescription.isEmpty || service.links.count > 1  {
            return UIImage(named: "eGov_Service_MoreInfo_Icon" )!
        }
        
        guard let linkType = service.links.first?.linkType else {
            return UIImage(named: "eGov_Service_Website_Icon")!
        }
        
        if let imageName =
            ["eidform" : "eGov_Service_Eid_Icon",
             "form": "eGov_Service_Form_Icon",
             "pdf": "eGov_Service_Pdf_Icon",
             "web": "eGov_Service_Website_Icon"][linkType] {
            
            return UIImage(named: imageName)!
            
        } else {
            return UIImage(named: "eGov_Service_Website_Icon")!
        }
        
    }
    
   
    
    func getServiceLinkTitle(service: SCModelEgovService) -> String {
        
        if !service.longDescription.isEmpty || service.links.count > 1 {
            return "apnmt_002_more_info_button".localized()
        }
        
        if let linkTitle = service.links.first?.title {
            if !linkTitle.isEmpty { return linkTitle }
        }
        
        guard let linkType = service.links.first?.linkType else { return "" }
        
        switch linkType {
        case "eidform":
            return "egovs_002_services_type_form_eid".localized()
        case "pdf":
            return "egovs_002_services_type_pdf".localized()
        case "form":
            return "egovs_002_services_type_form".localized()
        case "web":
            return "egovs_002_services_type_web".localized()
        default:
            return "egovs_002_services_type_web".localized()
        }
    }

    
}
