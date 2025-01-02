//
//  WasteCalendarTimelineEntry.swift
//  SCWidgetExtension
//
//  Created by Bhaskar N S on 08/08/22.
//  Copyright © 2022 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import WidgetKit
import UIKit

enum WasteCalendarState {
    case placeholder
    case configured
    case userNotLoggedIn
    case error
}

struct WasteCalendarEntry: TimelineEntry {
    let date: Date
    let wasteCalenderData: WasteCalendarDayWiseModel
    var isPlaceholder = false
}

extension WasteCalendarEntry {
    static let todayPickup = WasteCalendarPickup(day: "Today",
                                                 wasteList: [SCWasteCalendarItem(dateBaseString: "bhakar",
                                                                                 dayHeader: false,
                                                                                 itemName: "Bhakar",
                                                                                 color: UIColor.lightGray,
                                                                                 wasteTypeId: 12)])
    static let tomorrowPickup = WasteCalendarPickup(day: "Tomorrow",
                                                    wasteList: [SCWasteCalendarItem(dateBaseString: "bhakar",
                                                                                    dayHeader: false,
                                                                                    itemName: "Papier-grobeha",
                                                                                    color: UIColor.lightGray,
                                                                                    wasteTypeId: 12),
                                                                SCWasteCalendarItem(dateBaseString: "bhakar",
                                                                                    dayHeader: false,
                                                                                    itemName: "Papier-grobeha",
                                                                                    color: UIColor.lightGray,
                                                                                    wasteTypeId: 12)])
    static let dayAfterTomorrowPickup = WasteCalendarPickup(day: "12/08/22",
                                                    wasteList: [SCWasteCalendarItem(dateBaseString: "Papier-grobeha",
                                                                                    dayHeader: false,
                                                                                    itemName: "Bhakar",
                                                                                    color: UIColor.lightGray,
                                                                                    wasteTypeId: 12)])
    static var stub: WasteCalendarEntry {
        .init(date: Date(),
              wasteCalenderData: WasteCalendarDayWiseModel(isWasteCalendarConfigured: .placeholder,
                                                           todayPickups: todayPickup,
                                                           tomorrowPickups: tomorrowPickup,
                                                           dayAfterTomorrowPickups: dayAfterTomorrowPickup))
    }
    
    static var placeholder: WasteCalendarEntry {
        var stub = WasteCalendarEntry.stub
        stub.isPlaceholder = true
        return stub
    }
}
