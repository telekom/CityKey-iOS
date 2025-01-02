//
//  SCModelDefectCategory.swift
//  OSCA
//
//  Created by Harshada Deshmukh on 04/05/21.
//  Copyright © 2021 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import Foundation

struct SCModelDefectCategory: Equatable {
    let serviceCode: String
    let serviceName: String
    let subCategories: [SCModelDefectSubCategory]
    let description: String?
}

struct SCHttpModelDefectCategory: Decodable {
    let serviceCode: String
    let serviceName: String
    let subCategories: [SCHttpModelDefectSubCategory]?
    let description: String?

    enum CodingKeys: String, CodingKey {
        case serviceCode = "service_code"
        case serviceName = "service_name"
        case subCategories = "sub_categories"
        case description = "description"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        serviceCode = try values.decodeIfPresent(String.self, forKey: .serviceCode)!
        serviceName = try values.decodeIfPresent(String.self, forKey: .serviceName)!
        subCategories = try values.decodeIfPresent([SCHttpModelDefectSubCategory].self, forKey: .subCategories)
        description = try values.decodeIfPresent(String.self, forKey: .description)
    }

    func toModel() -> SCModelDefectCategory {
        
        return SCModelDefectCategory(serviceCode: serviceCode,
                                     serviceName: serviceName,
                                     subCategories: subCategories!.map{ $0.toModel()},
                                     description: description)
    }

}
