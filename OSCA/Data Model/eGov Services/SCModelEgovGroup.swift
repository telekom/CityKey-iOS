//
//  SCModelEgovGroup.swift
//  OSCA
//
//  Created by Bharat Jagtap on 21/04/21.
//  Copyright © 2021 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import Foundation

struct SCModelEgovGroup {
    
    let groupId: Int
    let groupName: String
    let groupIcon: String
    let services: [SCModelEgovService]

}

struct SCHTTPModelEgovGroup: Codable {
    let groupId: Int
    let groupName: String
    let groupIcon: String
    let services: [SCHTTPModelEgovService]

    enum CodingKeys: String, CodingKey {
        case groupId
        case groupName, groupIcon, services
    }
    
    func toModel() -> SCModelEgovGroup {
        return SCModelEgovGroup(groupId: self.groupId, groupName: self.groupName, groupIcon: self.groupIcon, services: self.services.map {
            
            var serviceModel = $0.toModel()
            serviceModel.groupName = groupName
            return serviceModel
            
        } )
    }
}
