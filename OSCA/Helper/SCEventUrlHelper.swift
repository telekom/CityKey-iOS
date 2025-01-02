//
//  SCEventUrlHelper.swift
//  SmartCity
//
//  Created by Alexander Lichius on 07.10.19.
//  Copyright © 2019 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import Foundation

/**
fetchEventList has a long signature / optional parameter list. Dependent on parameters that are not nil the url string to fetch differs. We need to evaluate the list of parameters and build the url string according to the available information
*/

class SCEventUrlHelper {
    static let cityNameParameter = "cityId="
    static let eventIdParameter = "&eventId="
    static let pageNameParameter = "&pageNo="
    static let pageSizeParameter = "&pageSize="
    static let startDateParameter = "&start="
    static let endDateParameter = "&end="
    static let actionParameter = "&actionName="

    static func urlPartStringFor(_ apiPath: String,_ cityID: Int,_ eventId: String, _ page: Int?, _ pageSize: Int?, _ startDate: Date?, _ endDate: Date?, _ categories: [SCModelCategory]?, _ action: String) -> String {
        return eventListSOLBaseUrl(apiPath: apiPath) + "?" + urlPartStringFor(cityID: cityID) + urlPartStringFor(eventId: eventId) + urlPartStringFor(page: page) + urlPartStringFor(pageSize: pageSize) + urlPartStringFor(startDate: startDate) + urlPartStringForEndDate(endDate: endDate) + urlPartStringFor(categories: categories) + urlPartStringFor(action: action)
    }

    static func urlSlashString() -> String {
        return "/"
    }

    static func eventListSOLBaseUrl(apiPath: String) -> String {
        return GlobalConstants.kSOL_UrlString + apiPath
    }

    static func urlPartStringFor(cityID: Int) -> String {
        return cityNameParameter + String(cityID)
    }
    static func urlPartStringFor(eventId: String) -> String{
        return eventIdParameter + String(eventId)
    }

    static func urlPartStringFor(page: Int?) -> String {
        if let page = page {
            return pageNameParameter + String(page)
        }
        return ""
    }

    static func urlPartStringFor(pageSize: Int? = GlobalConstants.events_fetch_data_page_size) -> String {
        if let pageSize = pageSize {
            return pageSizeParameter + String(pageSize)
        }
        return ""
    }

    static func urlPartStringFor(startDate: Date?) -> String {
        if let startDate = startDate {
            return startDateParameter + dateToParam(startDate)
        }
        return ""
    }

    static func urlPartStringForEndDate(endDate: Date?) -> String {
        if let endDate = endDate {
            
            return endDateParameter + dateToParam(endDate)
        }
        return ""
    }
    
    static func urlPartStringFor(categories: [SCModelCategory]?) -> String{
        guard let categories = categories else { return "" }
        if categories.count > 0 {
            var categoriesString = ""
            for categorie in categories {
                let categoryId = categorie.id
                categoriesString.append(contentsOf: "&categories=" + String(categoryId))
            }
            return categoriesString
        }
        return ""
    }
    
    static func urlPartStringFor(action: String) -> String {
        let actionString = actionParameter + action
        return actionString
    }

    
    static private func dateToParam(_ date : Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: date)
        return dateString
    }
    
}


