//
//  SCModelEgovService.swift
//  OSCA
//
//  Created by Bharat Jagtap on 21/04/21.
//  Copyright © 2021 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import Foundation
import UIKit

struct SCModelEgovService : Hashable {
        
    let isFavorite: String
    let serviceName: String
    let subServices: [SCModelEgovSubService]
    let serviceDetail: String
    let serviceId : Int

    let longDescription: String
    let shortDescription: String
    let links: [SCModelEgovServiceLink]
    let searchKey: [String]

    ///parent group name
    var groupName: String?
                
    static func == (lhs: SCModelEgovService, rhs: SCModelEgovService) -> Bool {
        return lhs.serviceName == rhs.serviceName
    }
}


struct SCHTTPModelEgovService: Codable {
    
    let isFavorite: String
    let serviceName: String
    let subServices: [SCHTTPModelEgovSubService]
    let serviceDetail: String
    let serviceId : Int

    let longDescription: String
    let shortDescription: String
    let linksInfo: [SCHTTPModelEgovServiceLink]
    let searchKey: [String]
    
    enum CodingKeys: String, CodingKey {
        case isFavorite, serviceName, subServices, serviceDetail
        case serviceId
        case longDescription, shortDescription
        case linksInfo
        case searchKey
    }
    
    func toModel() -> SCModelEgovService {
       
        return SCModelEgovService(isFavorite: self.isFavorite, serviceName: self.serviceName, subServices: self.subServices.map { $0.toModel() }, serviceDetail: self.serviceDetail, serviceId: self.serviceId, longDescription: longDescription, shortDescription: shortDescription, links: self.linksInfo.map { $0.toModel()}, searchKey: self.searchKey)
    }
}
