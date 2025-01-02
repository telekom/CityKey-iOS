//
//  SCModelEgovSubService.swift
//  OSCA
//
//  Created by Bharat Jagtap on 21/04/21.
//  Copyright © 2021 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import Foundation

struct SCModelEgovSubService : Hashable {
    
    let link, linkType: String
    let isFavorite: Bool
    let subServiceId: Int
    let subServiceName: String
    let subServiceOrder: Int
    let subServiceDetail, subServiceDescription: String
}


struct SCHTTPModelEgovSubService: Codable {
    
    let link, linkType: String
    let isFavorite: Bool
    let subServiceId: Int
    let subServiceName: String
    let subServiceOrder: Int
    let subServiceDetail, subServiceDescription: String

    enum CodingKeys: String, CodingKey {
        case link, linkType, isFavorite
        case subServiceId
        case subServiceName, subServiceOrder, subServiceDetail, subServiceDescription
    }
    
    func toModel() -> SCModelEgovSubService {
        
        return SCModelEgovSubService(link: self.link,
                                     linkType: self.linkType,
                                     isFavorite: self.isFavorite,
                                     subServiceId: self.subServiceId,
                                     subServiceName: self.subServiceName,
                                     subServiceOrder: self.subServiceOrder,
                                     subServiceDetail: self.subServiceDetail,
                                     subServiceDescription: self.subServiceDescription)
    }
}
