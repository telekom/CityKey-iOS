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
