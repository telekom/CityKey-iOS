/*
Created by Michael on 15.11.18.
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
import Kingfisher

/**
 * @brief SCModelServiceAction is the data model service actions
 *
 * Contains action item for a service
 */
struct SCModelServiceAction : Decodable, Equatable {
    let action : String
    let buttonDesign : String
    let iosAppStoreUri : String
    let iosUri : String
    let actionOrder : Int
    let actionId : Int
    let visibleText : String
    let actionType: String?
}
/**
 * @brief SCModelService is the data model for all kind of citizen services
 *
 * Contains all types of citizen services
 */
struct SCModelService {
    
    let id: String
    let serviceTitle: String
    let serviceDescription: String?
    let serviceFunction: String?
    let serviceActions: [SCModelServiceAction]?
    let imageURL: SCImageURL?
    let iconURL: SCImageURL?
    let authNeeded: Bool
    let isNew: Bool
    let residence: Bool
    let rank: Int
    let serviceParams : [String:String]?
    let helpLinkTitle: String?
    let templateId: Int?
    let headerImageURL: SCImageURL?
    let serviceType: String?

    func toBaseCompontentItem(tintColor: UIColor, categoryTitle: String,cellType: SCBaseComponentItemCellType, context: SCBaseComponentItemContext) -> SCBaseComponentItem {
        
        var actions : [SCComponentDetailBtnAction]? = nil
        
        if let serviceActions = serviceActions {
            actions = [SCComponentDetailBtnAction]()

            for serviceAction in serviceActions {
                
                var completion: (() -> Void)!
                
                /*if (serviceActions.type) == 2 {
                    completion = {
                        if let uri = URL(string: serviceAction.iosUri), let appStore = URL(string: serviceAction.iosAppStoreUri) {
                            if UIApplication.shared.canOpenURL(uri) {
                                UIApplication.shared.open(uri)
                            } else {
                                UIApplication.shared.open(appStore)
                            }
                        }
                    }
                } else {*/
                    
                    completion = {
                        if let uri = URL(string: serviceAction.iosUri), UIApplication.shared.canOpenURL(uri) {
                            SCInternalBrowser.showURL(uri, withBrowserType: .safari, title: serviceAction.visibleText)
                        }
                    }
               // }
                
                let btnType = serviceAction.buttonDesign == "1" ? SCComponentDetailBtnType.cityColorFull : SCComponentDetailBtnType.cityColorLight
                
                let newAction = SCComponentDetailBtnAction(title: serviceAction.visibleText, btnType:btnType , modelServiceAction: serviceAction, completion: completion)
                
                actions?.append(newAction)
            }
        }
        
        
        
        
        return SCBaseComponentItem(itemID : self.id,
                                   itemTitle: self.serviceTitle,
                                   itemTeaser : nil,
                                   itemSubtitle: nil,
                                   itemImageURL: self.imageURL,
                                   itemImageCredit: nil,
                                   itemThumbnailURL: nil,
                                   itemIconURL: self.iconURL,
                                   itemURL: nil,
                                   itemDetail: self.serviceDescription,
                                   itemHtmlDetail: true,
                                   itemCategoryTitle: categoryTitle,
                                   itemColor: tintColor,
                                   itemCellType: cellType,
                                   itemLockedDueAuth: !(!self.authNeeded || SCAuth.shared.isUserLoggedIn()),
                                   itemLockedDueResidence: !SCFeatureToggler.shared.isUserResidentOfSelectedCity() && self.residence,
                                   itemIsNew: self.isNew,
                                   itemFunction: self.serviceFunction,
                                   itemBtnActions: actions,
                                   itemContext: context,
                                   itemServiceParams: self.serviceParams,
                                   helpLinkTitle: helpLinkTitle,
                                   templateId: templateId,
                                   headerImageURL: headerImageURL,
                                   serviceType: serviceType
        )
    }
}

/**
 * SCHttpModelService  to decode Content from JSON
 */
struct SCHttpModelService: Decodable {
    
    let serviceId: Int
    let service: String
    let serviceAction: [SCModelServiceAction]?
    let description: String?
    let image: String?
    let icon: String?
    let function: String?
    let restricted: Bool?
    let isNew: Bool
    let residence: Bool
    let rank: Int? // TODO: was missing from backend, make un-optional again
    let serviceParams : [String:String]?
    let helpLinkTitle: String?
    let templateId: Int?
    let header_image: String?
    let serviceType: String?
    
    func toModel() -> SCModelService {
        
        // prefetch Images
        
        var imageURL : SCImageURL?
        var iconURL : SCImageURL?
        var headerImageURL : SCImageURL?
        
        if let imageURLString = image {
            imageURL = SCImageURL(urlString: imageURLString , persistence: false)
            if let url = URL(string: imageURLString) {
                KingfisherManager.shared.downloader.downloadImage(with: url, options: [.cacheOriginalImage])
            }
        }
        
        if let iconURLString = icon {
            iconURL = SCImageURL(urlString: iconURLString , persistence: false)
            if let url = URL(string: iconURLString) {
                KingfisherManager.shared.downloader.downloadImage(with: url, options: [.cacheOriginalImage])
            }
        }
        
        if let headerImageURLString = header_image {
            headerImageURL = SCImageURL(urlString: headerImageURLString , persistence: false)
            if let url = URL(string: headerImageURLString) {
                KingfisherManager.shared.downloader.downloadImage(with: url, options: [.cacheOriginalImage])
            }
        }
        
        return SCModelService(id: String(serviceId), // TODO: check if id could be an Int
                              serviceTitle: service,
                              serviceDescription: description,
                              serviceFunction: function,
                              serviceActions: serviceAction,
                              imageURL: imageURL,
                              iconURL: iconURL,
                              authNeeded: restricted ?? false,
                              isNew: isNew,
                              residence: residence,
                              rank: rank ?? 0 ,
                              serviceParams: serviceParams,
                              helpLinkTitle: helpLinkTitle,
                              templateId: templateId,
                              headerImageURL: headerImageURL,
                              serviceType: serviceType)
    }
}

// TODO: this should be deletable
struct SCHttpModelServiceRanking :Decodable {
    var rank: Int
    
    func toModel() -> Int {
        
        return rank
    }
}
