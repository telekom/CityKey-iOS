/*
Created by Alexander Lichius on 25.09.19.
Copyright © 2019 Deutsche Telekom AG - VTI Organization. All rights reserved.

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

SPDX-FileCopyrightText: 2025 Deutsche Telekom AG, Alexander Lichius
SPDX-License-Identifier: Apache-2.0 AND LicenseRef-Deutsche-Telekom-Brand
License-Filename: LICENSES/Apache-2.0.txt LICENSES/LicenseRef-Deutsche-Telekom-Brand.txt
*/

import Foundation

class SCHttpEventModelResult {
    static func toEventModel(_ result: [SCHttpEventModel]) -> SCModelEventList {
        let eventList: [SCModelEvent] = result.map {
            let description = $0.description
            let endDate = $0.endDate
            let startDate = $0.startDate
            let hasEndTime = $0.hasEndTime
            let hasStartTime = $0.hasStartTime
            let image = $0.image
            let thumbnail = $0.thumbnail
            let latitude = $0.latitude
            let longitude = $0.longitude
            let locationName = $0.locationName
//            let locationAddress = $0.locationAddress
            let locationAddress = $0.locationAddress.replacingOccurrences(of: "\\n", with: "\n").replacingOccurrences(of: "\\r", with: "\r")
            let subtitle = $0.subtitle
            let title = $0.title
            let imageCredit = $0.imageCredit
            let thumbnailCredit = $0.thumbnailCredit
            let pdf = $0.pdf
            let uid = $0.uid
            let link = $0.link
            let status = $0.status

            var categoryDescription: String = ""
            let sortedCat = $0.cityEventCategories.sorted{
                $0.categoryName < $1.categoryName
            }
            
            var i = 0
            for category in sortedCat {
                
                // we will show at least maximum 3 categories
                if i < 3{
                    if categoryDescription.count > 0 {
                        categoryDescription += " | "
                    }
                    categoryDescription.append(category.categoryName)
                    i += 1
                }
            }

            let imageURL = SCImageURL(urlString: image, persistence: false)

            let thumbnailURL = thumbnail.count > 0 ? SCImageURL(urlString: thumbnail, persistence: false) : nil

            let eventModel = SCModelEvent(description: description,
                                          endDate: endDate,
                                          startDate: startDate,
                                          hasEndTime: hasEndTime,
                                          hasStartTime: hasStartTime,
                                          imageURL: imageURL,
                                          thumbnailURL: thumbnailURL,
                                          latitude: latitude,
                                          longitude: longitude,
                                          locationName: locationName,
                                          locationAddress: locationAddress,
                                          subtitle: subtitle,
                                          title: title,
                                          imageCredit: imageCredit,
                                          thumbnailCredit: thumbnailCredit,
                                          pdf: pdf,
                                          uid: uid,
                                          link: link,
                                          categoryDescription: categoryDescription,
                                          status: status)
            return eventModel
        }

        let modelEventList = SCModelEventList(eventList: eventList)
        return modelEventList
    }
}

struct SCHttpEventModel: Decodable, Equatable {
    static func == (lhs: SCHttpEventModel, rhs: SCHttpEventModel) -> Bool {
        return lhs.cityEventCategories == rhs.cityEventCategories &&
        lhs.description == rhs.description &&
        lhs.endDate == rhs.endDate &&
        lhs.startDate == rhs.endDate &&
        lhs.hasEndTime == rhs.hasEndTime &&
        lhs.hasStartTime == rhs.hasStartTime &&
        lhs.image == rhs.image &&
        lhs.thumbnail == rhs.thumbnail &&
        lhs.latitude == rhs.latitude &&
        lhs.longitude == rhs.longitude &&
        lhs.locationName == rhs.locationName &&
        lhs.locationAddress == rhs.locationAddress &&
        lhs.subtitle == rhs.subtitle &&
        lhs.title == rhs.title &&
        lhs.imageCredit == rhs.imageCredit &&
        lhs.thumbnailCredit == rhs.thumbnailCredit &&
        lhs.pdf == rhs.pdf &&
        lhs.uid == rhs.uid &&
        lhs.link == rhs.link &&
        lhs.eventId == rhs.eventId &&
        lhs.status == rhs.status
    }
    
    let cityEventCategories: [SCHttpCategoryModel]
    let description: String
    let endDate: String
    let startDate: String
    let hasEndTime: Bool
    let hasStartTime: Bool
    let image: String
    let thumbnail: String
    let latitude: Double
    let longitude: Double
    let locationName: String
    let locationAddress: String
    let subtitle: String
    let title: String
    let imageCredit: String
    let thumbnailCredit: String
    let pdf: [String]?
    let uid: String
    let link: String
    let eventId: String
    let status: String?

    enum CodingKeys: String, CodingKey {
        case cityEventCategories = "cityEventCategories"
        case description = "description"
        case endDate = "endDate"
        case startDate = "startDate"
        case hasEndTime = "hasEndTime"
        case hasStartTime = "hasStartTime"
        case image = "image"
        case thumbnail = "thumbnail"
        case latitude = "latitude"
        case longitude = "longitude"
        case locationName = "locationName"
        case locationAddress = "locationAddress"
        case subtitle = "subtitle"
        case title = "title"
        case imageCredit = "imageCredit"
        case thumbnailCredit = "thumbnailCredit"
        case pdf = "pdf"
        case uid = "uid"
        case link = "link"
        case eventId = "eventId"
        case status = "status"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)

        status = try values.decodeIfPresent(String.self, forKey: .status)
        eventId = try values.decodeIfPresent(String.self, forKey: .eventId) ?? ""
        link = try values.decodeIfPresent(String.self, forKey: .link) ?? ""
        uid = try values.decodeIfPresent(String.self, forKey: .uid) ?? ""
        pdf = try values.decodeIfPresent([String].self, forKey: .pdf)
        thumbnailCredit = try values.decodeIfPresent(String.self, forKey: .thumbnailCredit) ?? ""
        imageCredit = try values.decodeIfPresent(String.self, forKey: .imageCredit) ?? ""
        title = try values.decodeIfPresent(String.self, forKey: .title) ?? ""
        subtitle = try values.decodeIfPresent(String.self, forKey: .subtitle) ?? ""
        locationAddress = try values.decodeIfPresent(String.self, forKey: .locationAddress) ?? ""
        locationName = try values.decodeIfPresent(String.self, forKey: .locationName) ?? ""
        longitude = try values.decodeIfPresent(Double.self, forKey: .longitude) ?? 0.0
        latitude = try values.decodeIfPresent(Double.self, forKey: .latitude) ?? 0.0
        thumbnail = try values.decodeIfPresent(String.self, forKey: .thumbnail) ?? ""
        image = try values.decodeIfPresent(String.self, forKey: .image) ?? ""
        hasStartTime = try values.decodeIfPresent(Bool.self, forKey: .hasStartTime) ?? false
        hasEndTime = try values.decodeIfPresent(Bool.self, forKey: .hasEndTime) ?? false
        startDate = try values.decodeIfPresent(String.self, forKey: .startDate) ?? ""
        endDate = try values.decodeIfPresent(String.self, forKey: .endDate) ?? ""
        description = try values.decodeIfPresent(String.self, forKey: .description) ?? ""
        cityEventCategories = try values.decodeIfPresent([SCHttpCategoryModel].self, forKey: .cityEventCategories) ?? []
    }
}

struct SCHttpCategoryArrayModel: Decodable {
    var categories: [SCHttpCategoryModel]
}

struct SCHttpCategoryModel: Decodable, Equatable {
    var categoryName: String
    var id: Int
    
    enum CodingKeys: String, CodingKey {
        case categoryName
        case id
    }
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        categoryName = try values.decodeIfPresent(String.self, forKey: .categoryName) ?? ""
        id = try values.decodeIfPresent(Int.self, forKey: .id) ?? 0
    }
}
