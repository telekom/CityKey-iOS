//
//  SCModelDefectSubCategory.swift
//  OSCA
//
//  Created by Harshada Deshmukh on 04/05/21.
//  Copyright © 2021 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import Foundation

struct SCModelDefectSubCategory : Codable, Equatable {

    let serviceCode : String
    let serviceName : String
    let description : String?
    let isAdditionalInfo : Bool?
}

struct SCHttpModelDefectSubCategory: Decodable {
    
    let serviceCode: String
    let serviceName: String
    let description: String?
    let isAdditionalInfo : Bool?

    enum CodingKeys: String, CodingKey {
        case serviceCode = "service_code"
        case serviceName = "service_name"
        case description = "description"
        case additionalInfo = "additional_info"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        serviceCode = try values.decodeIfPresent(String.self, forKey: .serviceCode)!
        serviceName = try values.decodeIfPresent(String.self, forKey: .serviceName)!
        description = try values.decodeIfPresent(String.self, forKey: .description)
        isAdditionalInfo = try values.decodeIfPresent(Bool.self, forKey: .additionalInfo)
    }
    
    func toModel() -> SCModelDefectSubCategory {
        return SCModelDefectSubCategory(serviceCode: serviceCode, serviceName: serviceName, description: description ?? "", isAdditionalInfo: isAdditionalInfo)
    }
}
