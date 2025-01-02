//
//  SCModelServiceCategory.swift
//  SmartCity
//
//  Created by Michael on 15.11.18.
//  Copyright © 2018 Michael. All rights reserved.
//

import UIKit

/**
 * @brief SCModelServiceCategory is the data model  the categories of the citizen services
 *
 * Contains all types of citizen services categories
 */
struct SCModelServiceCategory {
    
    var id: String
    var parentID: String!
    var categoryTitle: String
    var categoryDescription: String?
    var imageURL: SCImageURL?
    var iconURL: SCImageURL?
    var services: [SCModelService]
    var serviceType: String?
    
    func toBaseCompontentItem(tintColor: UIColor, categoryTitle: String, cellType: SCBaseComponentItemCellType) -> SCBaseComponentItem {
        return SCBaseComponentItem(itemID : self.id,
                                   itemTitle: self.categoryTitle,
                                   itemTeaser : nil,
                                   itemSubtitle: nil,
                                   itemImageURL: self.imageURL,
                                   itemImageCredit: nil,
                                   itemThumbnailURL: nil,
                                   itemIconURL: self.iconURL,
                                   itemURL: nil,
                                   itemDetail: nil,
                                   itemHtmlDetail: true,
                                   itemCategoryTitle: categoryTitle,
                                   itemColor: tintColor,
                                   itemCellType: cellType,
                                   itemLockedDueAuth: false,
                                   itemLockedDueResidence: false,
                                   itemIsNew: false,
                                   itemFunction: nil,
                                   itemContext: .overview,
                                   serviceType: serviceType)
    }
    
    static func dummyTevisServices() -> SCModelServiceCategory {
        return SCModelServiceCategory(id: "1", parentID: nil, categoryTitle: "Tevis Test Services", categoryDescription: nil, imageURL: nil, iconURL: nil, services: [SCModelService(id: "1", serviceTitle: "Tevis WebView", serviceDescription: "Webview Test mit POST Parameter", serviceFunction: "TEVISWEBVIEW", serviceActions: nil, imageURL: nil, iconURL: nil, authNeeded: false, isNew: true, residence: false, rank: 0 , serviceParams: [String:String](), helpLinkTitle: nil, templateId: 0, headerImageURL: nil, serviceType: "test")], serviceType: "test")
    }

}

/**
 * SCHttpModelServiceCategory  to decode Content from JSON
 */
struct SCHttpModelServiceCategory: Decodable {
    
    let categoryId: String
    let category: String
    let description: String
    let image: String?
    let icon: String?
    let parent_id: String?
    let cityServiceList: [SCHttpModelService]?
    
    func toModel() -> SCModelServiceCategory {
        
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
        
        return SCModelServiceCategory(id: String(categoryId), // TODO: check if id could be an Int
            parentID: parent_id,
            categoryTitle: category,
            categoryDescription: description,
            imageURL: imageURL,
            iconURL: iconURL,
            services: cityServiceList!.map{ $0.toModel()}
        )
    }
}

struct SCHttpModelServiceCategories: Decodable {

    let cityServiceCategoryList: [SCHttpModelServiceCategory]

    func toModel() -> [SCModelServiceCategory] {
        return cityServiceCategoryList.map {
            $0.toModel()
        }
    }

}
