//
//  SCModelCityAllContent.swift
//  SmartCity
//
//  Created by Robert Swoboda - Telekom on 04.04.19.
//  Copyright © 2019 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import Foundation

struct SCModelCityAllContent {
    let cityId: Int
    let cityName: String
    let cityImprintLink : String?
    let cityConfig: SCModelCityConfig
    let latitude: Double
    let longitude: Double
    let serviceDesc: String?
    let imprintDesc: String?
    let cityNightPictureImageUrl : SCImageURL?
    let imprintImageUrl: SCImageURL?

}

struct SCHttpModelCityAllContent: Decodable {
    let cityId: Int?
    let cityName: String?
    let imprintLink : String?
    let cityConfig: SCModelCityConfig?
    let latitude: Double?
    let longitude: Double?
    let serviceDesc: String?
    let imprintDesc: String?
    let cityNightPicture: String?
    let imprintImage: String?

    func toModel() -> SCModelCityAllContent {
        
        // prefetch Image
        let cityNightPictureImageUrl = SCImageURL(urlString: cityNightPicture ?? "", persistence: true)
        let imprintImageUrl = SCImageURL(urlString: imprintImage ?? "", persistence: true)
        SCImageLoader.sharedInstance.getImage(with: cityNightPictureImageUrl, completion: nil)
        SCImageLoader.sharedInstance.getImage(with: imprintImageUrl, completion: nil)

        return SCModelCityAllContent(cityId: cityId ?? -1,
                                     cityName: cityName ?? "",
                                     cityImprintLink: imprintLink?.trimmingCharacters(in: .whitespaces),
                                     cityConfig: cityConfig ?? SCModelCityConfig(showFavouriteServices: false, showHomeDiscounts: false, showHomeOffers: false, showHomeTips: false, showFavouriteMarketplaces: false, showNewServices: false, showNewMarketplaces: false, showMostUsedServices: false, showMostUsedMarketplaces: false, showCategories: false, showBranches: false, showDiscounts: false, showOurMarketPlaces: false, showOurServices: false, showMarketplacesOption: false, showServicesOption: false, stickyNewsCount: 0),
                                     latitude: latitude ?? 0.0,
                                     longitude: longitude ?? 0.0,
                                     serviceDesc: serviceDesc ?? "",
                                     imprintDesc: imprintDesc ?? "",
                                     cityNightPictureImageUrl: cityNightPictureImageUrl,
                                     imprintImageUrl:imprintImageUrl
                                    )
    }
}
