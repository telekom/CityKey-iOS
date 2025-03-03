/*
Created by Michael on 18.07.19.
Copyright © 2019 Deutsche Telekom AG - VTI Organization. All rights reserved.

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

SPDX-FileCopyrightText: 2025 Deutsche Telekom AG, Michael
SPDX-License-Identifier: Apache-2.0 AND LicenseRef-Deutsche-Telekom-Brand
License-Filename: LICENSES/Apache-2.0.txt LICENSES/LicenseRef-Deutsche-Telekom-Brand.txt
*/

import UIKit

class SCDisplayContent: NSObject {

    static func getMessageDetailController(displayContentType : SCDisplayContentType,
                                           navTitle : String,
                                           title : String,
                                           teaser : String,
                                           subtitle : String,
                                           details : String?,
                                           imageURL : SCImageURL?,
                                           photoCredit : String?,
                                           contentURL : URL?,
                                           tintColor : UIColor?,
                                           serviceFunction :  String? = nil,
                                           lockedDueAuth : Bool? = false,
                                           lockedDueResidence : Bool? = false,
                                           btnActions: [SCComponentDetailBtnAction]? = nil,
                                           injector: SCInjecting & SCAdjustTrackingInjection & SCWebContentInjecting,
                                           serviceType: String? = nil,
                                           itemServiceParams : [String:String]? = nil,
                                           beforeDismissCompletion :  (() -> Void)? = nil) -> UIViewController {
        
        var storyboardID : String!
        
        switch displayContentType {
        case .news:
            storyboardID = "MessageDetailType2"
        case .proposal:
            storyboardID = "MessageDetailType2"
        case .service:
            storyboardID = "ServicesInfoDetailVC"
        case .marketplace:
            storyboardID = "MessageDetailType2"
        }
        
        if displayContentType != .service{
            let navViewController:UINavigationController = UIStoryboard(name: "MessageDetailScreen", bundle: nil).instantiateViewController(withIdentifier: storyboardID) as! UINavigationController
            let contentController = navViewController.viewControllers[0] as! SCMessageDetailVC
            
            contentController.displayContentType = displayContentType
            
            contentController.setContent(navTitle : navTitle,
                                         title : title,
                                         teaser : teaser,
                                         subtitle: subtitle,
                                         details : details,
                                         imageURL : imageURL,
                                         photoCredit : photoCredit,
                                         contentURL : contentURL,
                                         tintColor : tintColor,
                                         lockedDueAuth : lockedDueAuth,
                                         lockedDueResidence : lockedDueResidence,
                                         btnActions: btnActions,
                                         injector: injector,
                                         beforeDismissCompletion : beforeDismissCompletion)
            return contentController
        }
        else{
            let navViewController:UINavigationController = UIStoryboard(name: "ServicesInfoDetailScreen", bundle: nil).instantiateViewController(withIdentifier: storyboardID) as! UINavigationController
            let contentController = navViewController.viewControllers[0] as! SCServicesInfoDetailVC
            
            contentController.displayContentType = displayContentType
            
            contentController.setContent(navTitle : navTitle,
                                         details : details,
                                         imageURL : imageURL,
                                         photoCredit : photoCredit,
                                         contentURL : contentURL,
                                         tintColor : tintColor,
                                         lockedDueAuth : lockedDueAuth,
                                         lockedDueResidence : lockedDueResidence,
                                         btnActions: btnActions,
                                         injector: injector,
                                         serviceType: serviceType,
                                         function: serviceFunction,
                                         itemServiceParams: itemServiceParams,
                                         beforeDismissCompletion : beforeDismissCompletion)
            return contentController
        }
    }
}
