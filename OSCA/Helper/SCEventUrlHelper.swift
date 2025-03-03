/*
Created by Alexander Lichius on 07.10.19.
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

SPDX-FileCopyrightText: 2025 Deutsche Telekom AG, Alexander Lichius
SPDX-License-Identifier: Apache-2.0 AND LicenseRef-Deutsche-Telekom-Brand
License-Filename: LICENSES/Apache-2.0.txt LICENSES/LicenseRef-Deutsche-Telekom-Brand.txt
*/

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


