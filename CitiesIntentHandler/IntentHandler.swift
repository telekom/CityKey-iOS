/*
 IntentHandler.swift
 CitiesIntentHandler
 
 Created by Bhaskar N S on 21/04/23.
 Copyright © 2023 Deutsche Telekom AG - VTI Organization. All rights reserved.
 
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
 
 SPDX-FileCopyrightText: 2025 Deutsche Telekom AG, Michael
 SPDX-License-Identifier: Apache-2.0 AND LicenseRef-Deutsche-Telekom-Brand
 License-Filename: LICENSES/Apache-2.0.txt LICENSES/LicenseRef-Deutsche-Telekom-Brand.txt
 */


import Intents

class IntentHandler: INExtension, CityIntentHandling {
    let cityContentRepository : CityContentRepository = CityContentRepository()
    func provideCityOptionsCollection(for intent: CityIntent, searchTerm: String?, with completion: @escaping (INObjectCollection<Cities>?, Error?) -> Void) {
        cityContentRepository.fetchCitites { list, error in
            guard let list = list else {
                return
            }
            var cities: [Cities] = list.map { city in
                let citymodel = Cities(identifier: "\(city.cityID)",
                                       display: city.cityName ?? "",
                                       subtitle: city.stateName,
                                       image: nil)
                citymodel.cityId = (city.cityID) as NSNumber
                citymodel.cityName = city.cityName
                return citymodel
            }
            cities.sort { $0.cityName ?? "" < $1.cityName ?? "" }
            if let searchTerm = searchTerm {
                cities = cities.filter {
                    return $0.cityName?.localizedCaseInsensitiveContains(searchTerm) ?? false
                }
            }
            completion(INObjectCollection(items: cities), nil)
        }
    }
    
    override func handler(for intent: INIntent) -> Any {
        // This is the default implementation.  If you want different objects to handle different intents,
        // you can override this and return the handler you want for that particular intent.
        
        return self
    }
    
}
