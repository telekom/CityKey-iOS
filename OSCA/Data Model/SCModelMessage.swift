/*
Created by Michael on 17.10.18.
Copyright © 2018 Michael. All rights reserved.

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

SPDX-FileCopyrightText: 2025 Deutsche Telekom AG, Michael
SPDX-License-Identifier: Apache-2.0 AND LicenseRef-Deutsche-Telekom-Brand
License-Filename: LICENSES/Apache-2.0.txt LICENSES/LicenseRef-Deutsche-Telekom-Brand.txt
*/

import UIKit

/**
 * @brief SCModelMessage is the data model for messages
 *
 * Contains all types of messages like news, informations and so on.
 */
enum SCModelMessageType: String, Decodable {
    case info
    case news
    case offer
    case tip
    case event
    case discount
    case unknown
}

enum SCHttpModelMessageType: String, Decodable {
    case NEWS
    case INFO
    case ANGEBOTE
    case TIPPS
    case RABATTE
    case unkown
    
    func toModel() -> SCModelMessageType {
        
        switch self {
        case .NEWS:
            return SCModelMessageType.news
        case .INFO:
            return SCModelMessageType.info
        case .ANGEBOTE:
            return SCModelMessageType.offer
        case .TIPPS:
            return SCModelMessageType.tip
        case .RABATTE:
            return SCModelMessageType.discount
        case .unkown:
            return SCModelMessageType.unknown
        }
    }
}

struct SCModelMessage: Decodable {
    
    let id: String
    let title: String
    let shortText: String
    let subtitleText: String
    let detailText: String
    let contentURL: URL?
    let imageURL: SCImageURL?
    let imageCredit: String?
    let thumbnailURL: SCImageURL?
    let type: SCModelMessageType
    //let timestamp: Int //brauchen wir nicht mehr: contentCreationDate ist jetzt ein dateString
    let date : Date
    let sticky: Bool

    func toBaseCompontentItem(tintColor: UIColor, categoryTitle: String, cellType: SCBaseComponentItemCellType, context: SCBaseComponentItemContext) -> SCBaseComponentItem {
        return SCBaseComponentItem(itemID : self.id,
                                   itemTitle: self.title,
                                   itemTeaser : self.shortText,
                                   itemSubtitle: self.subtitleText,
                                   itemImageURL: self.imageURL,
                                   itemImageCredit : self.imageCredit,
                                   itemThumbnailURL : self.thumbnailURL,
                                   itemIconURL: self.imageURL,
                                   itemURL: self.contentURL,
                                   itemDetail: self.detailText,
                                   itemHtmlDetail: false,
                                   itemCategoryTitle: categoryTitle,
                                   itemColor: tintColor,
                                   itemCellType: cellType,
                                   itemLockedDueAuth: false,
                                   itemLockedDueResidence: false,
                                   itemIsNew: false,
                                   itemFunction: nil,
                                   itemContext: context)
    }
    
}

struct SCHttpModelMessage: Decodable {
    let contentId: Int
    let uid: Int
    let contentTeaser: String
    let contentDetails: String
    let contentSubtitle: String
    let contentSource: String?
    var contentTyp: SCHttpModelMessageType = .NEWS
    let contentImage: String?
    let imageCredit: String?
    let thumbnail: String?
    let thumbnailCredit: String?
    let contentCategory: String?
    let contentCreationDate: String?
    let sticky: Bool
    
    enum CodingKeys: String, CodingKey {
        case contentId = "contentId"
        case uid = "uid"
        case contentTeaser = "contentTeaser"
        case contentDetails = "contentDetails"
        case contentSubtitle = "contentSubtitle"
        case contentSource = "contentSource"
        case contentTyp = "contentTyp"
        case contentImage = "contentImage"
        case imageCredit = "imageCredit"
        case thumbnail = "thumbnail"
        case thumbnailCredit = "thumbnailCredit"
        case contentCategory = "contentCategory"
        case contentCreationDate = "contentCreationDate"
        case sticky = "sticky"
    }
    
    init(contentId: Int, uid: Int, contentTeaser: String, contentDetails: String, contentSubtitle: String, contentSource: String?,
    contentTyp: SCHttpModelMessageType = .NEWS,
    contentImage: String?,
    imageCredit: String?,
    thumbnail: String?,
    thumbnailCredit: String?,
    contentCategory: String?,
    contentCreationDate: String?,
    sticky: Bool) {
        self.contentId = contentId
        self.uid = uid
        self.contentTeaser = contentTeaser
        self.contentDetails = contentDetails
        self.contentSubtitle = contentSubtitle
        self.contentSource = contentSource
        self.contentTyp = contentTyp
        self.contentImage = contentImage
        self.imageCredit = imageCredit
        self.thumbnail = thumbnail
        self.thumbnailCredit = thumbnailCredit
        self.contentCategory = contentCategory
        self.contentCreationDate = contentCreationDate
        self.sticky = sticky
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        contentId = try values.decodeIfPresent(Int.self, forKey: .contentId) ?? 0
        uid = try values.decodeIfPresent(Int.self, forKey: .uid) ?? 0
        contentTeaser = try values.decodeIfPresent(String.self, forKey: .contentTeaser) ?? ""
        contentDetails = try values.decodeIfPresent(String.self, forKey: .contentDetails) ?? ""
        contentSubtitle = try values.decodeIfPresent(String.self, forKey: .contentSubtitle) ?? ""
        contentSource = try values.decodeIfPresent(String.self, forKey: .contentSource)
        contentTyp = try values.decodeIfPresent(SCHttpModelMessageType.self, forKey: .contentTyp) ?? .NEWS
        contentImage = try values.decodeIfPresent(String.self, forKey: .contentImage)
        imageCredit = try values.decodeIfPresent(String.self, forKey: .imageCredit)
        thumbnail = try values.decodeIfPresent(String.self, forKey: .thumbnail)
        thumbnailCredit = try values.decodeIfPresent(String.self, forKey: .thumbnailCredit)
        contentCategory = try values.decodeIfPresent(String.self, forKey: .contentCategory)
        contentCreationDate = try values.decodeIfPresent(String.self, forKey: .contentCreationDate)
        sticky = try values.decodeIfPresent(Bool.self, forKey: .sticky) ?? false
    }
    
    func toModel() -> SCModelMessage {
        
        let imageURL = SCImageURL(urlString: contentImage ?? "", persistence: false)
        let thumbnailURL = thumbnail?.count ?? 0 > 0 ? SCImageURL(urlString: thumbnail!, persistence: false) : nil
        
        let contentURL = URL(string: contentSource ?? "")
        var date = Date()
        if let contentCreationDate = contentCreationDate {
            date = dateFromString(dateString: contentCreationDate) ?? Date()
        }
        
        
        return SCModelMessage(id: String(contentId),
                              title: contentCategory ?? contentTyp.rawValue,
                              shortText: contentTeaser,
                              subtitleText: contentSubtitle,
                              detailText: contentDetails,
                              contentURL: contentURL,
                              imageURL: imageURL,
                              imageCredit: imageCredit,
                              thumbnailURL: thumbnailURL,
                              type: contentTyp.toModel(),
                              /*timestamp: contentCreationDate,*/
                              date: date,
                              sticky: sticky)
    }
}
