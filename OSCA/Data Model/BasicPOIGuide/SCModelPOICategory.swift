//
//  SCModelPOICategory.swift
//  OSCA
//
//  Created by Harshada Deshmukh on 01/03/21.
//  Copyright © 2021 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import Foundation

struct SCModelPOICategory {
    let categoryGroupIcon : SCImageURL?
    let categoryGroupId : String
    let categoryGroupName : String
    let categoryList : [SCModelPOICategoryList]
}

struct SCHttpModelPOICategory: Decodable {
    let categoryGroupIcon : String?
    let categoryGroupId : String
    let categoryGroupName : String
    let categoryList : [SCHttpModelPOICategoryList]?

    func toModel() -> SCModelPOICategory {
        
        var categoryGroupIconURL : SCImageURL?
        
        if let categoryGroupIconURLString = categoryGroupIcon {
            categoryGroupIconURL = SCImageURL(urlString: categoryGroupIconURLString , persistence: false)
            SCImageLoader.sharedInstance.prefetchImage(imageURL: categoryGroupIconURL!)
        }
        
        return SCModelPOICategory(categoryGroupIcon: categoryGroupIconURL, categoryGroupId: categoryGroupId, categoryGroupName: categoryGroupName, categoryList: categoryList!.map{ $0.toModel()})
    }

}

