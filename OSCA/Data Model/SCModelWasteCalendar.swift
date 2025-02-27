/*
Created by Michael on 27.08.20.
Copyright © 2020 Deutsche Telekom AG - VTI Organization. All rights reserved.

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

import UIKit

struct SCModelWasteBinType : Decodable {
    let wasteType: String
    let color: String
    let wasteTypeId: Int
}

struct SCModelWasteCalendarAddress : Decodable {
    let streetName: String
    let houseNumber: String
}

struct SCModelWasteCalendarItem : Decodable {
    let date: Date
    let dateBaseString: String
    let wasteTypeList: [SCModelWasteBinType]
}

struct SCHttpModelWasteCalendarItem : Decodable {
    let date: String
    let wasteTypeList: [SCModelWasteBinType]
    
    func toModel() -> SCModelWasteCalendarItem {
        
        let wasteDate = dateFromString(dateString: date) ?? Date()

        let dateBaseString = date.prefix(10).replacingOccurrences(of: "-", with:"")
        
        return SCModelWasteCalendarItem(date: wasteDate, dateBaseString: dateBaseString, wasteTypeList: wasteTypeList)
    }
}

struct SCHttpModelWasteReminder: Decodable, Equatable {
    let wasteTypeId: Int
    let wasteType: String
    let color: String
    let remindTime: String
    let sameDay: Bool
    let oneDayBefore: Bool
    let twoDaysBefore: Bool

    func getParameters() -> [String: Any] {
        var parameters = [String: Any]()
        parameters["wasteTypeId"] = wasteTypeId
        parameters["remindTime"] = remindTime
        parameters["sameDay"] = sameDay
        parameters["oneDayBefore"] = oneDayBefore
        parameters["twoDaysBefore"] = twoDaysBefore
        return parameters
    }
}

struct SCHttpModelWasteCalendar : Decodable {
    let calendar: [SCHttpModelWasteCalendarItem]
    let address: SCModelWasteCalendarAddress
    let reminders: [SCHttpModelWasteReminder]
}

struct SCModelWasteCalendarAddressResult : Decodable {
    let streetName: String
    let houseNumberList: [String]
}

struct SCModelWasteTypeIDs : Decodable {
    let wasteTypeIds: [Int]
}

struct SCModelCategoryObj: Decodable {
    let id: Int
    let name: String
}

struct SCModelStoreWasteType: Decodable {
    let isSuccessful: Bool
}
