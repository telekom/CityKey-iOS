//
//  SCModelPOI.swift
//  OSCA
//
//  Created by Harshada Deshmukh on 10/03/21.
//  Copyright © 2021 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import Foundation

struct SCModelPOI {
    
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
    
}

struct SCHttpModelPOI: Decodable {
    
    let address : String
    let categoryName : String
    let cityId : Int
    let description : String
    let distance : Int
    let icon : String?
    let id : Int
    let latitude : Float
    let longitude : Float
    let openHours : String
    let subtitle : String
    let title : String
    let url : String

    func toModel() -> SCModelPOI {
        
        var iconURL : SCImageURL?
        
        if let iconURLString = icon {
            iconURL = SCImageURL(urlString: iconURLString , persistence: false)
            SCImageLoader.sharedInstance.prefetchImage(imageURL: iconURL!)
        }
        
        return SCModelPOI(address: address, categoryName: categoryName, cityId: cityId, description: description, distance: distance, icon: iconURL, id: id, latitude: latitude, longitude: longitude, openHours: openHours, subtitle: subtitle, title: title, url: url)
    }

}

