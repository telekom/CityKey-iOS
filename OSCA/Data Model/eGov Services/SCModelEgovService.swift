/*
Created by Bharat Jagtap on 21/04/21.
Copyright © 2021 Deutsche Telekom AG - VTI Organization. All rights reserved.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    https://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
 
In accordance with Sections 4 and 6 of the License, the following exclusions apply:

    1. Trademarks & Logos – The names, logos, and trademarks of the Licensor are not covered by this License and may not be used without separate permission.
    2. Design Rights – Visual identities, UI/UX designs, and other graphical elements remain the property of their respective owners and are not licensed under the Apache License 2.0.
    3: Non-Coded Copyrights – Documentation, images, videos, and other non-software materials require separate authorization for use, modification, or distribution.

These elements are not considered part of the licensed Work or Derivative Works unless explicitly agreed otherwise. All elements must be altered, removed, or replaced before use or distribution. All rights to these materials are reserved, and Contributor accepts no liability for any infringing use. By using this repository, you agree to indemnify and hold harmless Contributor against any claims, costs, or damages arising from your use of the excluded elements.

SPDX-FileCopyrightText: 2025 Deutsche Telekom AG, Bharat Jagtap
SPDX-License-Identifier: Apache-2.0 AND LicenseRef-Deutsche-Telekom-Brand
License-Filename: LICENSES/Apache-2.0.txt LICENSES/LicenseRef-Deutsche-Telekom-Brand.txt
*/

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
