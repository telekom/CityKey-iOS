//
//  WasteCalendarMediumWidget.swift
//  SCWidgetExtension
//
//  Created by Bhaskar N S on 08/08/22.
//  Copyright © 2022 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import SwiftUI
import WidgetKit

struct WasteCalendarMediumWidget: View {
    let wasteCalenderData: WasteCalendarDayWiseModel
    var isPlaceHolder: Bool = false
    var body: some View {
        HStack(spacing: -2) {
            Link(destination: isPlaceHolder ? URL(string: "citykey://home")! : URL(string: "citykey://services/waste/overview?month=\(wasteCalenderData.todayPickups.month)")!) {
                WasteCalendarView(pickup: wasteCalenderData.todayPickups)
            }
            Link(destination: isPlaceHolder ? URL(string: "citykey://home")! : URL(string: "citykey://services/waste/overview?month=\(wasteCalenderData.tomorrowPickups.month)")!) {
                WasteCalendarView(pickup: wasteCalenderData.tomorrowPickups)
            }
            Link(destination: isPlaceHolder ? URL(string: "citykey://home")! : URL(string: "citykey://services/waste/overview?month=\(wasteCalenderData.dayAfterTomorrowPickups.month)")!) {
                WasteCalendarView(pickup: wasteCalenderData.dayAfterTomorrowPickups)
            }
        }
        .widgetBackground(backgroundView: Color.clear)
    }
}

struct WasteCalendarMediumWidget_Previews: PreviewProvider {
    static var previews: some View {
        let wasteCalendarItem = SCWasteCalendarItem(dateBaseString: "25/10/2022", dayHeader: true, itemName: "Bhaskar", color: UIColor.blue, wasteTypeId: 1)
        WasteCalendarMediumWidget(wasteCalenderData: WasteCalendarDayWiseModel(isWasteCalendarConfigured: .placeholder,
                                                                               todayPickups: WasteCalendarPickup(day: "Today", wasteList: [wasteCalendarItem]),
                                                                               tomorrowPickups: WasteCalendarPickup(day: "Tomorrow", wasteList: [wasteCalendarItem]),
                                                                               dayAfterTomorrowPickups: WasteCalendarPickup(day: "27/10/2022", wasteList: [wasteCalendarItem])))
        .previewContext(WidgetPreviewContext(family: .systemMedium))
    }
}
