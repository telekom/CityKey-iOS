/*
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

SPDX-FileCopyrightText: 2025 Deutsche Telekom AG
SPDX-License-Identifier: Apache-2.0 AND LicenseRef-Deutsche-Telekom-Brand
License-Filename: LICENSES/Apache-2.0.txt LICENSES/LicenseRef-Deutsche-Telekom-Brand.txt
*/
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
