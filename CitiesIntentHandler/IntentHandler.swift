//
//  IntentHandler.swift
//  CitiesIntentHandler
//
//  Created by Bhaskar N S on 21/04/23.
//  Copyright © 2023 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

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
