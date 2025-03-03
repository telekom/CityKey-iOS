/*
Created by Michael on 13.11.18.
Copyright © 2018 Michael. All rights reserved.

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

SPDX-FileCopyrightText: 2025 Deutsche Telekom AG, Copyright © 2018 Michael
SPDX-License-Identifier: Apache-2.0 AND LicenseRef-Deutsche-Telekom-Brand
License-Filename: LICENSES/Apache-2.0.txt LICENSES/LicenseRef-Deutsche-Telekom-Brand.txt
*/

import UIKit

enum displayContentType {
    case news
    case proposal
    case userinfo
    case service
    case marketplace
}

/**
 * This class holds some funtions to help Controllers to display
 * content and informations
 */

class SCDisplayHelper: NSObject, UIViewControllerTransitioningDelegate {

    static let transitionDelegate = SCBubbleTransitionDelegate()
    
    var startPoint : CGPoint?

    /**
     *
     * Class method to show detailed messages, city content, userinfos
     *
     * @param viewController The view controller who should present the  controller
     * @param url if this parameter is set, the content of the url will be presented
     *         in the webcontent controller
     * @param htmlString if the url is set to nil then the controller will prseent the content
     *          of the htmlString
     * @param title the title for the navigation bar
     */
    static func showContent(for viewController: UIViewController,
                            displayContentType : displayContentType,
                            navTitle : String,
                            title : String,
                            teaser : String,
                            details : String?,
                            imageURL : SCImageURL?,
                            topBtnTitle : String?,
                            bottomBtnTitle : String?,
                            contentURL : URL?,
                            serviceFunction :  String? = nil,
                            lockedDueAuth : Bool? = false,
                            lockedDueResidence : Bool? = false,
                            topBtnCompletion: (() -> Void)? = nil,
                            bottomBtnCompletion: (() -> Void)? = nil) {
        
        
        var storyboardID : String!
        
        switch displayContentType {
        case .news:
            storyboardID = "MessageDetailType2"
        case .proposal:
            storyboardID = "MessageDetailType2"
        case .userinfo:
            storyboardID = "MessageDetailType1"
        case .service:
            storyboardID = "MessageDetailType2"
        case .marketplace:
            storyboardID = "MessageDetailType2"
        }
        
        let navViewController:UINavigationController = UIStoryboard(name: "MessageDetailScreen", bundle: nil).instantiateViewController(withIdentifier: storyboardID) as! UINavigationController
        let contentController = navViewController.viewControllers[0] as! SCMessageDetailVC
        navViewController.transitioningDelegate = transitionDelegate
        navViewController.modalPresentationStyle = .overCurrentContext
        navViewController.presentAboveTabbar()
        
             contentController.setContent(navTitle : navTitle,
                                         title : title,
                                         teaser : teaser,
                                         details : details,
                                         imageURL : imageURL,
                                         topBtnTitle : topBtnTitle,
                                         bottomBtnTitle : bottomBtnTitle,
                                         contentURL : contentURL,
                                         lockedDueAuth : lockedDueAuth,
                                         lockedDueResidence : lockedDueResidence,
                                         topBtnCompletion: topBtnCompletion,
                                         bottomBtnCompletion: bottomBtnCompletion)
    
        
 
        
        
        viewController.present(navViewController, animated: true, completion: nil)
    }


    
}
