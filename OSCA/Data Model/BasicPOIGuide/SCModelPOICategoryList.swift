//
//  SCModelPOICategoryList.swift
//  OSCA
//
//  Created by Harshada Deshmukh on 01/03/21.
//  Copyright © 2021 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import Foundation

struct SCModelPOICategoryList : Codable {

    let categoryId : Int
    let categoryName : String
    
}

/**
 * SCModelPOICategoryList  to decode Content from JSON
 */
struct SCHttpModelPOICategoryList: Decodable {
    
    let categoryId: Int
    let categoryName: String

    func toModel() -> SCModelPOICategoryList {
        return SCModelPOICategoryList(categoryId: categoryId, categoryName: categoryName)
    }
}
