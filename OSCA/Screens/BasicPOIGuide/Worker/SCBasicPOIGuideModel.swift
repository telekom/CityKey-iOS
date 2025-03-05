/*
Created by A106551118 on 07/07/22.
Copyright © 2022 Deutsche Telekom AG - VTI Organization. All rights reserved.

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

SPDX-FileCopyrightText: 2025 Deutsche Telekom AG, A106551118
SPDX-License-Identifier: Apache-2.0 AND LicenseRef-Deutsche-Telekom-Brand
License-Filename: LICENSES/Apache-2.0.txt LICENSES/LicenseRef-Deutsche-Telekom-Brand.txt
*/

import Foundation

enum SCBasicPOIGuidePresentationMode {
    case firstTime
    case notSignedIn
    case signedIn
}

/**
 *
 * POICategoryInfo is the  model for the city selection
 *
 */
struct POICategoryInfo : Codable {
    
    let categoryGroupIcon : SCImageURL?
    let categoryGroupId : String
    let categoryGroupName : String
    let categoryList : [SCModelPOICategoryList]
    var categoryFavorite: Bool = false

    static func fromModel(_ model: SCModelPOICategory, isFavorite: Bool) -> POICategoryInfo {
        return POICategoryInfo(categoryGroupIcon: model.categoryGroupIcon, categoryGroupId: model.categoryGroupId, categoryGroupName: model.categoryGroupName, categoryList: model.categoryList, categoryFavorite: isFavorite)
    }
    
}

/**
 *
 * POIInfo is the  model for the city selection
 *
 */

extension POIInfo: Equatable {
	static func == (lhs: POIInfo, rhs: POIInfo) -> Bool {
		return lhs.address == rhs.address &&
		lhs.categoryName == rhs.categoryName &&
		lhs.cityId == rhs.cityId &&
		lhs.description == rhs.description &&
		lhs.distance == rhs.distance &&
		lhs.icon == rhs.icon &&
		lhs.id == rhs.id &&
		lhs.latitude == rhs.latitude &&
		lhs.longitude == rhs.longitude &&
		lhs.openHours == rhs.openHours &&
		lhs.subtitle == rhs.subtitle &&
		lhs.url == rhs.url &&
		lhs.poiFavorite == rhs.poiFavorite
	}
}

struct POIInfo : Codable {
    
    let address : String
    let categoryName : String
    let cityId : Int
    let description : String
    let distance : Int
    let icon : SCImageURL?
    let id : Int
    let latitude : Float
    let longitude : Float
    let openHours : String
    let subtitle : String
    let title : String
    let url : String
    var poiFavorite: Bool = false
    
    static func fromModel(_ model: SCModelPOI, isFavorite: Bool) -> POIInfo {
        return POIInfo(address: model.address, categoryName: model.categoryName, cityId: model.cityId, description: model.description, distance: model.distance, icon: model.icon, id: model.id, latitude: model.latitude, longitude: model.longitude, openHours: model.openHours, subtitle: model.subtitle, title: model.title, url: model.url, poiFavorite: isFavorite)
    }
    
}
