//
//  SCModelEgovServiceLink.swift
//  OSCA
//
//  Created by Bharat Jagtap on 08/11/21.
//  Copyright © 2021 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import Foundation

struct SCModelEgovServiceLink: Hashable {
    
    let link: String
    let title: String
    let linkType: String
}

struct SCHTTPModelEgovServiceLink : Codable{
    
    let link: String
    let title: String
    let linkType: String

    enum CodingKeys: String, CodingKey {
        case link, linkType, title
    }
    
    func toModel() -> SCModelEgovServiceLink {
        return SCModelEgovServiceLink(link: link, title: title, linkType: linkType)
    }
}
