//
//  WasteCalendarDayWiseModel.swift
//  SCWidgetExtension
//
//  Created by Bhaskar N S on 11/08/22.
//  Copyright © 2022 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import Foundation
import UIKit

struct WasteCalendarPickup {
    var day: String
    var month: String = ""
    var wasteList: [SCWasteCalendarItem]
    var statusMessage: String = "wc_no_pickups_scheduled".localized()
}

struct WasteCalendarDayWiseModel {
    var isWasteCalendarConfigured: WasteCalendarState = .placeholder
    var todayPickups: WasteCalendarPickup
    var tomorrowPickups: WasteCalendarPickup
    var dayAfterTomorrowPickups: WasteCalendarPickup
}

struct SCWasteCalendarItem: Identifiable, Hashable, Equatable {
    var id = UUID()
    let dateBaseString: String
    let dayHeader: Bool
    let itemName: String
    let color: UIColor?
    let wasteTypeId: Int
}

struct SCModelWasteTypeIDs : Decodable {
    let wasteTypeIds: [Int]
}


struct SCHttpModelWasteCalendar : Decodable {
    let calendar: [SCHttpModelWasteCalendarItem]
    let address: SCModelWasteCalendarAddress
    let reminders: [SCHttpModelWasteReminder]
}

struct SCModelWasteCalendarAddress : Decodable {
    let streetName: String
    let houseNumber: String
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

struct SCHttpModelWasteCalendarItem : Decodable {
    let date: String
    let wasteTypeList: [SCModelWasteBinType]
    
    func toModel() -> SCModelWasteCalendarItem {
        
        let wasteDate = dateFromString(dateString: date) ?? Date()

        let dateBaseString = date.prefix(10).replacingOccurrences(of: "-", with:"")
        
        return SCModelWasteCalendarItem(date: wasteDate, dateBaseString: dateBaseString, wasteTypeList: wasteTypeList)
    }
    
    func dateFromString(dateString: String) -> Date? {
        
        let dateformatter = dateFormatter()
        let newDate = dateformatter.date(from: dateString)
        if let date = newDate {
            return date
        }
        return nil
    }
    
    func dateFormatter() -> DateFormatter {
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateformatter.locale = Locale(identifier: Locale.current.identifier)
        return dateformatter
    }
}

struct SCModelWasteCalendarItem : Decodable {
    let date: Date
    let dateBaseString: String
    let wasteTypeList: [SCModelWasteBinType]
}

struct SCModelWasteBinType : Decodable {
    let wasteType: String
    let color: String
    let wasteTypeId: Int
}
