//
//  SCModelMessage.swift
//  SmartCity
//
//  Created by Michael on 17.10.18.
//  Copyright © 2018 Michael. All rights reserved.
//

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
