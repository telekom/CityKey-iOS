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

/**
 * @brief SCModelBranch. is the data model the branches of the marketplaces
 *
 */
struct SCModelBranch {
    
    let id: String
    let parentID: String!
    let branchTitle: String
    let branchDescription: String?
    let imageURL: SCImageURL?
    let iconURL: SCImageURL?
    let marketplaces: [SCModelMarketplace]
    
    func toBaseCompontentItem(tintColor: UIColor, categoryTitle: String, cellType: SCBaseComponentItemCellType) -> SCBaseComponentItem {
        return SCBaseComponentItem(itemID : self.id,
                                   itemTitle: self.branchTitle,
                                   itemTeaser : nil,
                                   itemSubtitle: nil,
                                   itemImageURL: self.imageURL,
                                   itemImageCredit: nil,
                                   itemThumbnailURL: nil,
                                   itemIconURL: self.iconURL,
                                   itemURL: nil,
                                   itemDetail: nil,
                                   itemHtmlDetail: false,
                                   itemCategoryTitle: categoryTitle,
                                   itemColor: tintColor,
                                   itemCellType: cellType,
                                   itemLockedDueAuth: false,
                                   itemLockedDueResidence: false,
                                   itemIsNew: false,
                                   itemFunction: nil,
                                   itemContext: .overview)
    }
}

/**
 * SCHttpModelBranch  to decode Content from JSON
 */
struct SCHttpModelBranch: Decodable {
    
    let branchId: Int
    let branch: String
    let description: String
    let image: String?
    let icon: String?
    let parent_id: String?
    let marketplaceList: [SCHttpModelMarketplace]?
    
    func toModel() -> SCModelBranch {
        
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
        
        return SCModelBranch(id: String(branchId), // TODO: check if id could be an Int
            parentID: parent_id,
            branchTitle: branch,
            branchDescription: description,
            imageURL: imageURL,
            iconURL: iconURL,
            marketplaces: marketplaceList!.map{ $0.toModel()})
    }
}

