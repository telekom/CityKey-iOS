/*
Created by Bharat Jagtap on 08/11/21.
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
import UIKit

protocol SCEgovServiceLongDescriptionPresenting : SCPresenting {

    func setDisplay(_ display : SCEgovServiceLongDescriptionDisplay)
    func getTitle() -> String
    func getServiceIcon(link: SCModelEgovServiceLink) -> UIImage
    func getServiceLinkTitle(link: SCModelEgovServiceLink) -> String
    func didSelectLink(link: SCModelEgovServiceLink)
}

class SCEgovServiceLongDescriptionPresenter {
    
    weak var display : SCEgovServiceLongDescriptionDisplay?
    var service: SCModelEgovService
    var injector : SCEgovServiceInjecting & SCServicesInjecting & SCAdjustTrackingInjection
    
    init(service : SCModelEgovService, injector: SCEgovServiceInjecting & SCServicesInjecting & SCAdjustTrackingInjection) {
        self.service = service
        self.injector = injector
    }
}

extension SCEgovServiceLongDescriptionPresenter : SCEgovServiceLongDescriptionPresenting {
    
    func viewDidLoad() {
        
        if let attrString =  service.longDescription.htmlAttributedString?.trimmedAttributedString(set: .whitespacesAndNewlines) {
            let htmlAttributedString = NSMutableAttributedString(attributedString: attrString)
            htmlAttributedString.replaceFont(with: UIFont.systemFont(ofSize: (UIScreen.main.bounds.size.width) == 320 ? 14.0 : 16.0, weight: UIFont.Weight.medium), color: UIColor(named: "CLR_LABEL_TEXT_BLACK")!)
            display?.setHtmlDescription(text: htmlAttributedString)
        }
        display?.setServiceLinks(service.links)
    }
    
    func viewWillAppear() {
        
    }
    
    func viewDidAppear() {
        
    }
        
    func setDisplay(_ display : SCEgovServiceLongDescriptionDisplay) {
        self.display = display
    }
    
    func getTitle() -> String {
        return service.serviceName
    }
    
    func getServiceIcon(link: SCModelEgovServiceLink) -> UIImage {
        
        if let imageName =
            ["eidform" : "eGov_Service_Eid_Icon",
             "form": "eGov_Service_Form_Icon",
             "pdf": "eGov_Service_Pdf_Icon",
             "web": "eGov_Service_Website_Icon"][link.linkType] {
            
            return UIImage(named: imageName)!
            
        } else {
            return UIImage(named: "eGov_Service_Website_Icon")!
        }
        
    }
    
    func getServiceLinkTitle(link: SCModelEgovServiceLink) -> String {
       
        if !link.title.isEmpty { return link.title }
       
        switch link.linkType {
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

    func didSelectLink(link: SCModelEgovServiceLink) {
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
