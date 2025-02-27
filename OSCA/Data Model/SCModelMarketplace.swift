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

SPDX-FileCopyrightText: 2025 Deutsche Telekom AG, Michael
SPDX-License-Identifier: Apache-2.0 AND LicenseRef-Deutsche-Telekom-Brand
License-Filename: LICENSES/Apache-2.0.txt LICENSES/LicenseRef-Deutsche-Telekom-Brand.txt
*/

import UIKit

/**
 * @brief SCModelMarketplace is the data model for all kind of marketplaces
 *
 * Contains all types of marketplaces
 */
struct SCModelMarketplace {
    
    let id: String
    let marketplaceTitle: String
    let marketplaceDescription: String?
    let marketplaceFunction: String?
    let imageURL: SCImageURL?
    let iconURL: SCImageURL?
    let authNeeded: Bool
    let isNew: Bool
    let rank: Int
    
    func toBaseCompontentItem(tintColor: UIColor, categoryTitle: String, cellType: SCBaseComponentItemCellType, context: SCBaseComponentItemContext) -> SCBaseComponentItem {
        return SCBaseComponentItem(itemID : self.id,
                                   itemTitle: self.marketplaceTitle,
                                   itemTeaser : nil,
                                   itemSubtitle: nil,
                                   itemImageURL: self.imageURL,
                                   itemImageCredit: nil,
                                   itemThumbnailURL: nil,
                                   itemIconURL: self.iconURL,
                                   itemURL: nil,
                                   itemDetail: self.marketplaceDescription,
                                   itemHtmlDetail: true,
                                   itemCategoryTitle: categoryTitle,
                                   itemColor: tintColor,
                                   itemCellType: cellType,
                                   itemLockedDueAuth: !(!self.authNeeded || SCAuth.shared.isUserLoggedIn()),
                                   itemLockedDueResidence: false,
                                   itemIsNew: self.isNew,
                                   itemFunction: self.marketplaceFunction,
                                   itemContext: context)
    }
}

/**
 * SCHttpModelMarketplace  to decode Content from JSON
 */
struct SCHttpModelMarketplace: Decodable {
    
    let marketplaceId: Int
    let marketplace: String
    let description: String
    let image: String?
    let icon: String?
    let function: String?
    let restricted: Bool
    let isNew: Bool
    let rank: Int

    func toModel() -> SCModelMarketplace {
        
        // prefetch Images

        var imageURL : SCImageURL?
        var iconURL : SCImageURL?

        if let imageURLString = image {
            imageURL = SCImageURL(urlString: imageURLString , persistence: false)
            SCImageLoader.sharedInstance.prefetchImage(imageURL: imageURL!)
        }
        
        if let iconURLString = icon {
            iconURL = SCImageURL(urlString: iconURLString , persistence: false)
            SCImageLoader.sharedInstance.prefetchImage(imageURL: iconURL!)
        }

        return SCModelMarketplace(id: String(marketplaceId), // TODO: check if id could be an Int
            marketplaceTitle: marketplace,
            marketplaceDescription: description,
            marketplaceFunction: function,
            imageURL: imageURL,
            iconURL: iconURL,
            authNeeded: restricted,
            isNew: isNew,
            rank: rank)
    }
}
