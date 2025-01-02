//
//  SCModelBranch.swift
//  SmartCity
//
//  Created by Michael on 15.11.18.
//  Copyright © 2018 Michael. All rights reserved.
//

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

