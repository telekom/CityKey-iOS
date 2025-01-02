//
//  SCBasicPOIGuideModel.swift
//  OSCA
//
//  Created by A106551118 on 07/07/22.
//  Copyright © 2022 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

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
