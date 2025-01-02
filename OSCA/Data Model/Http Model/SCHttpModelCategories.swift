//
//  SCHttpModelCategories.swift
//  SmartCity
//
//  Created by Alexander Lichius on 10.10.19.
//  Copyright © 2019 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import Foundation

class SCHttpEventCategoriesResult {
    static func toCategoriesList(_ result: [SCHttpModelCategories]) -> [SCModelCategory] {
        let categoryList: [SCModelCategory] = result.map {
            let categoryName = $0.categoryName
            let id = $0.id
            let category = SCModelCategory(categoryName: categoryName, id: Int(id))
            return category
        }
        return categoryList
    }
}

struct SCHttpModelCategoryContent: Decodable {
    var content: [SCHttpModelCategories]
}

struct SCHttpModelCategories: Decodable {
    var categoryName: String
    var id: Double
}
