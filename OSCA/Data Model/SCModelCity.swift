//
//  SCModelCity.swift
//  SmartCity
//
//  Created by Michael on 17.10.18.
//  Copyright © 2018 Michael. All rights reserved.
//

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
