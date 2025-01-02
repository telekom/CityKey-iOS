//
//  SCModelMarketplace.swift
//  SmartCity
//
//  Created by Michael on 15.11.18.
//  Copyright © 2018 Michael. All rights reserved.
//

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
