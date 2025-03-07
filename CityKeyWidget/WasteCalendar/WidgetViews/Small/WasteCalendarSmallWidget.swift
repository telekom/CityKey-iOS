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
