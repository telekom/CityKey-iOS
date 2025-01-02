//
//  SCModelWasteCalendar.swift
//  OSCA
//
//  Created by Michael on 27.08.20.
//  Copyright © 2020 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

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
