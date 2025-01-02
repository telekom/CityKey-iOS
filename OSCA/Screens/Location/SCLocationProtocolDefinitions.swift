//
//  SCLocationProtocolDefinitions.swift
//  SmartCity
//
//  Created by Robert Swoboda - Telekom on 19.06.19.
//  Copyright © 2019 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

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
