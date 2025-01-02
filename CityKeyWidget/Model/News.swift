//
//  News.swift
//  OSCA
//
//  Created by A200111500 on 30/04/22.
//  Copyright © 2022 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import Foundation

// MARK: - News
struct News: Codable {
    let content: [Content]
}

// MARK: - Content
struct Content: Codable, Identifiable, Hashable {
    let contentID: Int
    let contentCreationDate, contentDetails: String
    let contentImage: String
    let imageCredit: String
    let contentSource: String
    let contentTeaser: String
    let cityID: Int
    let language: Language
    let sticky: Bool
    let thumbnail: String
    let thumbnailCredit, contentSubtitle: String
    let uid: Int
    var id: Int {
        contentID
    }

    enum CodingKeys: String, CodingKey {
        case contentID = "contentId"
        case contentCreationDate, contentDetails, contentImage, imageCredit, contentSource, contentTeaser
        case cityID = "cityId"
        case language, sticky, thumbnail, thumbnailCredit, contentSubtitle, uid
    }
}

enum Language: String, Codable {
    case de = "de"
}
