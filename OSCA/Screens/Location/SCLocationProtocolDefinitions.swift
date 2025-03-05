/*
Created by Robert Swoboda - Telekom on 19.06.19.
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

import UIKit

enum SCLocationPresentationMode {
    case firstTime
    case notSignedIn
    case signedIn
}

/**
 *
 * CityLocationInfo is the  model for the city selection
 *
 */
struct CityLocationInfo {
    
    let cityID: Int
    let cityName: String
    let cityState: String
    let cityImageUrl: SCImageURL
    var cityFavorite: Bool = false
    
    static func fromModel(_ model: SCModelCity, isFavorite: Bool) -> CityLocationInfo {
        return CityLocationInfo(cityID: model.cityID, cityName: model.name, cityState: model.stateName, cityImageUrl: model.cityImageUrl, cityFavorite: isFavorite)
    }
    
}

protocol SCLocationDisplaying: AnyObject, SCDisplaying {
    
    func dismiss()
    
    func updateAllCityItems(with cityItems: [CityLocationInfo])
    func updateFavoriteCityItems(with cityItems: [CityLocationInfo])

    func showLocationActivityIndicator(for cityName: String)
    func hideLocationActivityIndicator()
    func searchLocActivityIndicator(show : Bool)
    
    func showLocationFailedMessage(messageTitle: String, withMessage: String)
    func showLocationInfoMessage(messageTitle: String, withMessage: String)
    func showLocationMarker(for cityName : String, color: UIColor)
    func showGeoLocatedCity(for cityId: Int, distance: Double)
    func configureLocationServiceNotAvailable()
    func showCityNotAvailable()
}

protocol SCLocationPresenting: SCPresenting {
    func setDisplay(_ display: SCLocationDisplaying)
    
    func determineLocationButtonWasPressed()
    func favDidChange(cityName : String, isFavorite: Bool)
    func locationWasSelected(cityName: String, cityID: Int)
    func isStoredLocationSuggestionAvailable() -> Bool
    func storedLocationSuggestion() -> Int?
    func storedDistanceToNearestLocation() -> Double?
    
    func closeButtonWasPressed()
    func loadDefaultCity()
}
