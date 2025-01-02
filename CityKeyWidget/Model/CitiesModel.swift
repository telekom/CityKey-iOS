//
//  CitiesModel.swift
//  OSCA
//
//  Created by Bhaskar N S on 04/05/23.
//  Copyright © 2023 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import Foundation

// MARK: - CityModel
struct CitiesModel: Codable {
    let content: [CityModel]
}

// MARK: - Content
struct CityModel: Codable {
    let cityColor: String?
    let cityID: Int
    let cityName, cityPicture, cityPreviewPicture: String?
    let country: String?
    let municipalCoat: String?
    let postalCode: [String?]?
    let servicePicture, stateName: String?

    enum CodingKeys: String, CodingKey {
        case cityColor
        case cityID = "cityId"
        case cityName, cityPicture, cityPreviewPicture, country, municipalCoat, postalCode, servicePicture, stateName
    }
}
