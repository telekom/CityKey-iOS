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

SPDX-FileCopyrightText: 2025 Deutsche Telekom AG, Copyright © 2018 Michael
SPDX-License-Identifier: Apache-2.0 AND LicenseRef-Deutsche-Telekom-Brand
License-Filename: LICENSES/Apache-2.0.txt LICENSES/LicenseRef-Deutsche-Telekom-Brand.txt
*/

import UIKit

/**
 * @brief SCModelCityInfo is the data model for city information
 *
 * Contains all base city informations
 */
struct SCModelCity {

    let cityID : Int
    let name: String
    let cityTintColor: UIColor
    let stateName: String
    let country: String
    let cityImageUrl : SCImageURL
    let cityPreviewImageUrl: SCImageURL
    let serviceImageUrl : SCImageURL
    let marketplaceImageUrl : SCImageURL
    let municipalCoatImageUrl : SCImageURL
    let postalCode: [String]

    static func defaultCity() -> SCModelCity {
        return SCModelCity(cityID: 5, name: "Monheim am Rhein", cityTintColor: .green, stateName: "Nordrhein-Westfalen", country:"Deutschland", cityImageUrl: SCImageURL(urlString: "", persistence: false),  cityPreviewImageUrl: SCImageURL(urlString: "", persistence: false),  serviceImageUrl: SCImageURL(urlString: "", persistence: false),  marketplaceImageUrl: SCImageURL(urlString: "", persistence: false),  municipalCoatImageUrl: SCImageURL(urlString: "", persistence: false), postalCode: [])
    }
}

struct SCHttpModelCity: Decodable {

    let name: String
    let cityId: Int
    let stateName: String
    let municipalCoatimageURL: String
    let cityTintColor: String
    let country: String
    let cityimageURL: String
    let cityPreviewimageURL: String
    let serviceimageURL: String
    let marketplaceimageURL: String?
    let postalCode: [String]

    enum CodingKeys: String, CodingKey {
        case name = "cityName"
        case cityId = "cityId"
        case stateName = "stateName"
        case municipalCoatimageURL = "municipalCoat"
        case cityTintColor = "cityColor"
        case country = "country"
        case cityimageURL = "cityPicture"
        case cityPreviewimageURL = "cityPreviewPicture"
        case serviceimageURL = "servicePicture"
        case marketplaceimageURL = "marketplacePicture"
        case postalCode = "postalCode"
    }
    
    init(from decoder: Decoder) throws {
        let cityValues = try decoder.container(keyedBy: CodingKeys.self)

        name = try cityValues.decodeIfPresent(String.self, forKey: .name) ?? ""
        cityId = try cityValues.decodeIfPresent(Int.self, forKey: .cityId) ?? -1
        stateName = try cityValues.decodeIfPresent(String.self, forKey: .stateName) ?? ""
        municipalCoatimageURL = try cityValues.decodeIfPresent(String.self, forKey: .municipalCoatimageURL) ?? ""
        cityTintColor = try cityValues.decodeIfPresent(String.self, forKey: .cityTintColor) ?? ""
        country = try cityValues.decodeIfPresent(String.self, forKey: .country) ?? ""
        cityimageURL = try cityValues.decodeIfPresent(String.self, forKey: .cityimageURL) ?? ""
        cityPreviewimageURL = try cityValues.decodeIfPresent(String.self, forKey: .cityPreviewimageURL) ?? ""
        serviceimageURL = try cityValues.decodeIfPresent(String.self, forKey: .serviceimageURL) ?? ""
        marketplaceimageURL = try? cityValues.decodeIfPresent(String.self, forKey: .marketplaceimageURL) ?? ""

        if let postalCodeList = try? cityValues.decodeIfPresent([Int].self, forKey: .postalCode) {
            postalCode = postalCodeList.map { "\($0)" }
        } else {
            postalCode = try cityValues.decodeIfPresent([String].self, forKey: .postalCode) ?? []
        }
    }

    func toModel() -> SCModelCity {
        // prefetch Image
        let cityPreviewImageUrl = SCImageURL(urlString: cityPreviewimageURL, persistence: true)
        SCImageLoader.sharedInstance.getImage(with: cityPreviewImageUrl, completion: nil)

        return SCModelCity(cityID: cityId,
                           name: name,
                           cityTintColor: UIColor(hexString: String(cityTintColor.dropFirst(1))),
                           stateName: stateName,
                           country: country,
                           cityImageUrl: SCImageURL(urlString: cityimageURL, persistence: true),
                           cityPreviewImageUrl: cityPreviewImageUrl,
                           serviceImageUrl: SCImageURL(urlString: serviceimageURL, persistence: true),
                           marketplaceImageUrl: SCImageURL(urlString: marketplaceimageURL ?? "", persistence: true),
                           municipalCoatImageUrl: SCImageURL(urlString: municipalCoatimageURL, persistence: true), postalCode: postalCode)
    }
}
