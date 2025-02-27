/*
Created by Robert Swoboda - Telekom on 04.04.19.
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

SPDX-FileCopyrightText: 2025 Deutsche Telekom AG, Robert Swoboda
SPDX-License-Identifier: Apache-2.0 AND LicenseRef-Deutsche-Telekom-Brand
License-Filename: LICENSES/Apache-2.0.txt LICENSES/LicenseRef-Deutsche-Telekom-Brand.txt
*/

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
