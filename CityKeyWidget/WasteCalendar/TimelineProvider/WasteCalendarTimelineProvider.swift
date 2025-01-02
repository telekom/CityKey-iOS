//
//  WasteCalendarTimelineProvider.swift
//  SCWidgetExtension
//
//  Created by Bhaskar N S on 08/08/22.
//  Copyright © 2022 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import WidgetKit
import SwiftUI

struct WasteCalendarTimelineProvider: TimelineProvider {
    @AppStorage("cityKey", store: UserDefaults(suiteName: WidgetUtility().getAppGroupId())) var cityKey: Int = -1
    private let wasteCalendarRepository: WasteCalendarRepository
    init(wasteCalendarRepository: WasteCalendarRepository = WasteCalendarRepository()) {
        self.wasteCalendarRepository = wasteCalendarRepository
    }
    func placeholder(in context: Context) -> WasteCalendarEntry {
        .placeholder
    }
    func getSnapshot(in context: Context, completion: @escaping (WasteCalendarEntry) -> Void) {
        wasteCalendarRepository.getRecentWasteData(for: cityKey, street: nil, houseNumber: nil) { model in
            completion(WasteCalendarEntry(date: Date(),
                                          wasteCalenderData: model))
        }
        
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<WasteCalendarEntry>) -> Void) {
        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        wasteCalendarRepository.getRecentWasteData(for: cityKey, street: nil, houseNumber: nil) { model in
            let currentDate = Date()
            let midnight = Calendar.current.startOfDay(for: currentDate)
            let nextMidnight = Calendar.current.date(byAdding: .day, value: 1, to: midnight)!
            let entries = [WasteCalendarEntry(date: currentDate,
                                              wasteCalenderData: model)]
            let timeline = Timeline(entries: entries,
                                    policy: .after(nextMidnight))
            completion(timeline)
        }
    }
}
