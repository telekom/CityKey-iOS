//
//  WasteCalendarSmallWidget.swift
//  OSCA
//
//  Created by Bhaskar N S on 08/08/22.
//  Copyright © 2022 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import SwiftUI
import WidgetKit

struct WasteCalendarSmallWidget: View {
    let pickup: WasteCalendarPickup
    var isPlaceHolder: Bool = false
    var body: some View {
        HStack(spacing: -4) {
            WasteCalendarViewForSmallWidgetView(pickup: pickup)
        }
        .widgetBackground(backgroundView: Color.clear)
        .widgetURL(isPlaceHolder ? URL(string: "citykey://home") : URL(string: "citykey://services/waste/overview?month=\(pickup.month)"))
    }
}

struct WasteCalendarSmallWidget_Previews: PreviewProvider {
    static var previews: some View {
        let wasteCalendarItem = SCWasteCalendarItem(dateBaseString: "25/10/2022", dayHeader: true, itemName: "Bhaskar", color: UIColor.blue, wasteTypeId: 1)
        WasteCalendarSmallWidget(pickup: WasteCalendarPickup(day: "Today", wasteList: [wasteCalendarItem]))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}

struct WasteCalendarViewForSmallWidgetView: View {
    var pickup: WasteCalendarPickup
    var body: some View {
        ZStack(alignment: .top, content: {
            ContainerRelativeShape()
                .fill(Color(UIColor(named: "WCbackground") ?? .systemPink))
            VStack(spacing: 0) {
                HStack {
                    if #available(iOSApplicationExtension 16.0, *) {
                        Text(pickup.day)
                            .widgetAccentable()
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .frame(height: 24.0)
                            .background(Color(UIColor(named: "WCHeader") ?? .systemBlue))
                            .font(Font.caption)
                            .multilineTextAlignment(.center)
                    } else {
                        Text(pickup.day)
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .frame(height: 24.0)
                            .background(Color(UIColor(named: "WCHeader") ?? .systemBlue))
                            .font(Font.caption)
                            .multilineTextAlignment(.center)
                    }
                }
                if pickup.wasteList.isEmpty {
                    NoPickupsView(statusMessage: pickup.statusMessage)
                } else {
                    Color.clear
                        .overlay(
                            LazyVStack(spacing: 0) {
                                ForEach(pickup.wasteList, id: \.id) { pickup in
                                    WasteTypeView(pickup: pickup)
                                }
                                Spacer()
                            },
                            alignment: .top)
                }
            }
        })
        .widgetBackground(backgroundView: Color.clear)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(pickup.day), \(accessibilityTextForDays(list: pickup.wasteList)).")
    }
    
    func accessibilityTextForDays(list: [SCWasteCalendarItem]) -> String {
        if list.isEmpty {
            return pickup.statusMessage
        } else {
            return list.map { item in
                return item.itemName
            }.joined(separator: "")
        }
    }
}
