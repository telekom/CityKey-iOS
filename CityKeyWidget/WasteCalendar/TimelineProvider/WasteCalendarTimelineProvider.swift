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
