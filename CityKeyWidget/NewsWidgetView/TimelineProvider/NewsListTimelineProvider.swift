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
//  NewsListTimelineProvider.swift
//  SCWidgetExtension
//
//  Created by Bhaskar N S on 17/05/22.
//  Copyright © 2022 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import WidgetKit
import SwiftUI
import Intents

struct NewsListTimelineProvider: IntentTimelineProvider {
    
    @AppStorage("cityKey", store: UserDefaults(suiteName: getAppGroupId())) var cityKey: Int = -1
    @AppStorage("cityNews", store: UserDefaults(suiteName: getAppGroupId())) var cityNews: Data?
    private let newsLoader: NewsLoader
    init(newsLoader: NewsLoader = NewsLoader()) {
        self.newsLoader = newsLoader
    }
    func placeholder(in context: Context) -> NewsTimelineEntry {
        .placeholder
    }

    func getSnapshot(for configuration: CityIntent, in context: Context, completion: @escaping (NewsTimelineEntry) -> ()) {
        if context.isPreview {
            let content = parseResponse()
            if !content.isEmpty {
                let entry = NewsTimelineEntry(date: Date(), news: content, configuration: configuration)
                completion(entry)
            } else {
                guard cityKey != -1 else { return }
                newsLoader.fetchNewsContent(for: cityKey) { error, news in
                    guard nil == error,
                          let news = news else {
                        completion(NewsTimelineEntry(date: Date(), news: [], configuration: configuration))
                        return
                    }
                    completion(NewsTimelineEntry(date: Date(), news: news, configuration: configuration))
                }
            }
        } else {
            let entry = NewsTimelineEntry(date: Date(), news: parseResponse(), configuration: configuration)
            completion(entry)
        }
    }

    func getTimeline(for configuration: CityIntent, in context: Context, completion: @escaping (Timeline<NewsTimelineEntry>) -> ()) {
        guard cityKey != -1 else { return }
        let cityId = configuration.city?.cityId != nil ? configuration.city?.cityId as! Int : cityKey
            newsLoader.fetchNewsContent(for: cityId) { error, news in
                guard nil == error,
                      let news = news else {
                    completion(Timeline(entries: [NewsTimelineEntry(date: Date(), news: [], configuration: configuration)],
                                        policy: .atEnd))
                    return
                }
                let nextUpdate = Date().addingTimeInterval(60 * 60 * 3)
                let entry = NewsTimelineEntry(date: nextUpdate, news: news, configuration: configuration)
                let timeline = Timeline(entries: [entry], policy: .atEnd)
                completion(timeline)
            }
    }
    
    private func parseResponse() -> [Content] {
        guard let cityNewsData = cityNews else {
            return []
        }
        do {
            let model = try JSONDecoder().decode(News.self, from: cityNewsData)
            return model.content
        } catch let error as NSError {
            print("Failed to load: \(error.localizedDescription)")
        }
        return []
    }
    
    static func getAppGroupId() -> String {
        return "group.com.telekom.opensource.citykey"
    }
}
