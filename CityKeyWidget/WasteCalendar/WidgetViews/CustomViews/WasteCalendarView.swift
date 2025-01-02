//
//  WasteCalendarView.swift
//  SCWidgetExtension
//
//  Created by Bhaskar N S on 11/08/22.
//  Copyright © 2022 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import SwiftUI
import WidgetKit

struct WasteCalendarView: View {
    var pickup: WasteCalendarPickup
    var body: some View {
        VStack(spacing: 0) {
            if #available(iOSApplicationExtension 16.0, *) {
                Text(pickup.day)
                    .widgetAccentable()
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .frame(height: 24.0)
                    .font(Font.caption)
                    .multilineTextAlignment(.center)
                    .background(Color(UIColor(named: "WCHeader") ?? .systemBlue))
                    .cornerRadius(radius: 15, corners: [.topRight, .topLeft])
            } else {
                Text(pickup.day)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .frame(height: 24.0)
                    .font(Font.caption)
                    .multilineTextAlignment(.center)
                    .background(Color(UIColor(named: "WCHeader") ?? .systemBlue))
                    .cornerRadius(radius: 15, corners: [.topRight, .topLeft])
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
                        },
                        alignment: .top)
                    .frame(height: getMediumSizeWidgetHeight() - 33)
                    .cornerRadius(radius: 15.0, corners: [.bottomLeft, .bottomRight])
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
        .background(ContainerRelativeShape()
            .fill(Color(UIColor(named: "WCbackground") ?? .systemPink)))
        .padding(5)
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
    
    func getMediumSizeWidgetHeight() -> CGFloat {
        switch UIScreen.main.bounds.size {
        case CGSize(width: 428, height: 926):   return 170
        case CGSize(width: 414, height: 896):   return 169
        case CGSize(width: 414, height: 736):   return 159
        case CGSize(width: 390, height: 844):   return 158
        case CGSize(width: 375, height: 812):   return 155
        case CGSize(width: 375, height: 667):   return 148
        case CGSize(width: 360, height: 780):   return 155
        case CGSize(width: 320, height: 568):   return 141
        case CGSize(width: 430, height: 932):   return 170
        default:                                return 155
        }
    }
}

struct WasteTypeView: View {
    var pickup: SCWasteCalendarItem?
    @Environment(\.widgetFamily) var family: WidgetFamily
    var body: some View {
        VStack(spacing: 0) {
            Text("")
                .frame(height: 1.0)
                .frame(maxWidth: .infinity)
                .background(Color(UIColor(named: "separator") ?? .systemPink))
            ZStack {
                VStack(spacing: 0) {
                    HStack(alignment: .center,
                           spacing: 0, content: {
                        Image("trash")
                            .renderingMode(.template)
                            .foregroundColor(Color(getPickupColor(color: pickup?.color ?? .yellow)))
                            .frame(width: 16, height: 22)
                            .padding(.leading, family == .systemSmall ? 4 : 2)
                        Text(pickup?.itemName ?? "")
                            .fontWeight(.regular)
                            .frame(minHeight: 22.0)
                            .font(.caption)
                            .lineLimit(1)
                            .multilineTextAlignment(.center)
                        Spacer(minLength: 2)
                    })
                }
            }
            .background(Color(pickup?.color ?? .yellow).opacity(0.3))
        }
        .widgetBackground(backgroundView: Color.clear)
    }
    
    private func getPickupColor(color: UIColor) -> UIColor {
        if color == UIColor(hex: "#1A171B") {
            return UIColor(named: "restmullWasteColor") ?? color
        } else {
            return color
        }
    }
}

struct WasteCalendarView_Previews: PreviewProvider {
    static var previews: some View {
        let wasteCalendarItem = SCWasteCalendarItem(dateBaseString: "25/10/2022", dayHeader: true, itemName: "Bhaskar", color: UIColor.blue, wasteTypeId: 1)
        WasteCalendarView(pickup: WasteCalendarPickup(day: "Today", wasteList: [wasteCalendarItem]))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}

struct NoPickupsView: View {
    var statusMessage: String?
    var body: some View {
        Spacer()
        VStack(spacing: 0) {
            if #available(iOSApplicationExtension 16.0, *) {
                Text(statusMessage ?? "wc_no_pickups_scheduled".localized())
                    .widgetAccentable()
                    .multilineTextAlignment(.center)
                    .font(Font.caption)
            } else {
                Text(statusMessage ?? "wc_no_pickups_scheduled".localized())
                    .multilineTextAlignment(.center)
                    .font(Font.caption)
            }
        }
        .widgetBackground(backgroundView: Color.clear)
        Spacer()
    }
}
