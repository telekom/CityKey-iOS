//
//  SCModelInfoBoxItem.swift
//  SmartCity
//
//  Created by Michael on 04.12.19.
//  Copyright © 2019 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import UIKit

struct SCModelInfoBoxItemAttachment: Decodable {
    let attachmentText: String
    let attachmentLink: String
}

struct SCModelInfoBoxItemCategory: Decodable {
    let categoryIcon: String
    let categoryName: String
}

struct SCModelInfoBoxItem {
    let userInfoId: Int
    let messageId: Int
    let description: String
    let details: String
    let headline: String
    var isRead: Bool
    let creationDate: Date
    let category: SCModelInfoBoxItemCategory
    let buttonText: String?
    let buttonAction: String?
    let attachments: [SCModelInfoBoxItemAttachment]
}

struct SCHttpModelInfoBoxItem : Decodable {
    let userInfoId: Int
    let messageId: Int
    let description: String
    let details: String
    let headline: String
    let isRead: Bool
    let creationDate: String
    let category: SCModelInfoBoxItemCategory
    let buttonText: String?
    let buttonAction: String?
    let attachments: [SCModelInfoBoxItemAttachment]
    
    func toModel() -> SCModelInfoBoxItem {

        // prefetch Images
        return SCModelInfoBoxItem(userInfoId: userInfoId,
                                  messageId: messageId,
                                  description: description,
                                  details: details,
                                  headline: headline,
                                  isRead: isRead,
                                  creationDate: dateFromString(dateString: creationDate) ?? Date(),
                                  category: category,
                                  buttonText: buttonText,
                                  buttonAction: buttonAction,
                                  attachments: attachments)
    }

}
