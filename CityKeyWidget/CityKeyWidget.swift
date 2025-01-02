//
//  CityKeyWidget.swift
//  CityKeyWidget
//
//  Created by Bhaskar N S on 21/04/23.
//  Copyright © 2023 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import WidgetKit
import SwiftUI
import Intents

struct WasteCalendarEntryView: View {
    let entry: WasteCalendarEntry
    @Environment(\.widgetFamily) var family: WidgetFamily
    @ViewBuilder
    var body: some View {
        let wasteCalenderData = entry.wasteCalenderData
        switch wasteCalenderData.isWasteCalendarConfigured {
        case .placeholder:
            switch family {
            case .systemSmall:
                WasteCalendarSmallWidget(pickup: WasteCalendarEntry.tomorrowPickup,
                                         isPlaceHolder: true)
                    .redacted(reason: .placeholder)
            default:
                WasteCalendarMediumWidget(wasteCalenderData: WasteCalendarEntry.stub.wasteCalenderData,
                                          isPlaceHolder: true)
                    .redacted(reason: .placeholder)
            }
        case .configured:
            switch family {
            case .systemSmall:
                WasteCalendarSmallWidget(pickup: entry.wasteCalenderData.tomorrowPickups,
                                         isPlaceHolder: entry.isPlaceholder)
                    .redacted(reason: entry.isPlaceholder ? .placeholder : .init())
            default:
                WasteCalendarMediumWidget(wasteCalenderData: entry.wasteCalenderData,
                                          isPlaceHolder: entry.isPlaceholder)
                    .redacted(reason: entry.isPlaceholder ? .placeholder : .init())
            }
        case .error:
            WidgetErrorView()
        case .userNotLoggedIn:
            WidgetErrorView(errorMessage: "waste_calendar_logged_out_message".localized())
        }
    }
}


struct NoNewsView: View {
    let widgetUtility: WidgetUtility
    init(widgetUtility: WidgetUtility = WidgetUtility()) {
        self.widgetUtility = widgetUtility
    }
    var body: some View {
        Link(destination: URL(string: "citykey://home")!) {
            Text(getErrorMessage())
                .lineLimit(5)
                .padding(4)
        }
    }

    private func getErrorMessage() -> String {
        @AppStorage("cityKey", store: UserDefaults(suiteName: widgetUtility.getAppGroupId())) var cityKey: Int = -1
        if let userDefaults = UserDefaults(suiteName: widgetUtility.getAppGroupId()) {
            return userDefaults.string(forKey: "NewsError") ?? "The news could not be loaded."
        }
        return "The news could not be loaded."
    }
}
@main
struct CityKey: WidgetBundle {
    @WidgetBundleBuilder
    var body: some Widget {
        NewsWidget()
        WasteCalendarWidget()
    }
}

struct CityKeyWidget_Previews: PreviewProvider {
    static var previews: some View {
        SCWidgetEntryView(entry: NewsTimelineEntry(date: Date(), news: [], configuration: CityIntent()))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}

struct WasteCalendarWidget: Widget {
    let kind: String = "WasteCalendarWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: WasteCalendarTimelineProvider()) { entry in
            WasteCalendarEntryView(entry: entry)
        }
        .contentMarginsDisabledIfAvailable()
        .configurationDisplayName("waste_calendar_widget_001_title".localized())
        .description("waste_calendar_002_description".localized())
        .supportedFamilies(getSupportedFamilies())
    }

    private func getSupportedFamilies() -> [WidgetFamily] {
        if #available(iOS 16, *) {
            return [.systemSmall,
                    .systemMedium]
        } else {
            return [.systemSmall,
                    .systemMedium]
        }
    }
}

struct SCWidgetEntryView : View {
    var entry: NewsListTimelineProvider.Entry
    @Environment(\.widgetFamily) var family: WidgetFamily
    @Environment(\.sizeCategory) var category
    @ViewBuilder
    var body: some View {
        let newsCount = decideNumberOfNewsToDisplayLarge()
        if !entry.news.isEmpty {
            switch family {
            case .systemSmall:
                SCNewsSmallWidget(news: entry.news[0], isPlaceHolder: entry.isPlaceholder)
                    .redacted(reason: entry.isPlaceholder ? .placeholder : .init())
            case .systemMedium:
                SCNewsMediumWidget(news: Array(entry.news[..<decideNumberOfNewsToDisplayMedium()]),
                                   isPlaceHolder: entry.isPlaceholder)
                    .redacted(reason: entry.isPlaceholder ? .placeholder : .init())
            case .systemLarge:
                SCNewsLargeWidget(news: Array(entry.news[..<newsCount]),
                                  isPlaceHolder: entry.isPlaceholder)
                    .redacted(reason: entry.isPlaceholder ? .placeholder : .init())
            case .systemExtraLarge:
                SCNewsLargeWidget(news: Array(entry.news[..<newsCount]),
                                  isPlaceHolder: entry.isPlaceholder)
                    .redacted(reason: entry.isPlaceholder ? .placeholder : .init())
            @unknown default:
                SCNewsMediumWidget(news: Array(entry.news[..<decideNumberOfNewsToDisplayMedium()]),
                                   isPlaceHolder: entry.isPlaceholder)
                    .redacted(reason: entry.isPlaceholder ? .placeholder : .init())
            }
        } else {
            switch family {
            case .systemSmall:
                SCNewsSmallWidget(news: NewsTimelineEntry.stub.news[0], isPlaceHolder: true)
                    .redacted(reason: .placeholder)
            case .systemMedium:
                SCNewsMediumWidget(news: Array(NewsTimelineEntry.stub.news[..<decideNumberOfNewsToDisplayMedium()]),
                                   isPlaceHolder: true)
                    .redacted(reason: .placeholder)
            case .systemLarge:
                SCNewsLargeWidget(news: Array(NewsTimelineEntry.stub.news[..<newsCount]),
                                  isPlaceHolder: true)
                    .redacted(reason: .placeholder)
            case .systemExtraLarge:
                SCNewsLargeWidget(news: Array(NewsTimelineEntry.stub.news[..<newsCount]),
                                  isPlaceHolder: true)
                    .redacted(reason: .placeholder)
            @unknown default:
                SCNewsMediumWidget(news: Array(NewsTimelineEntry.stub.news[..<decideNumberOfNewsToDisplayMedium()]),
                                   isPlaceHolder: true)
                    .redacted(reason: .placeholder)
            }
        }
    }

    private func decideNumberOfNewsToDisplayMedium() -> Int {
        let news = entry.news.isEmpty ? NewsTimelineEntry.stub.news : entry.news
        switch category {
        case .accessibilityExtraExtraExtraLarge,
                .accessibilityExtraExtraLarge,
                .accessibilityExtraLarge,
                .accessibilityLarge,
                .accessibilityMedium,
                .extraExtraLarge,
                .extraExtraExtraLarge:
            return news.count >= 1 ? 1 : 1
        case .large,
                .extraLarge:
            return news.count >= 2 ? 2 : 2
        default:
            return news.count >= 2 ? 2 : 2
        }
    }

    private func decideNumberOfNewsToDisplayLarge() -> Int {
        let news = entry.news.isEmpty ? NewsTimelineEntry.stub.news : entry.news
        switch category {
        case .extraSmall:
            return news.count >= 4 ? 4 : entry.news.count
        case .small:
            return news.count >= 4 ? 4 : entry.news.count
        case .medium,
                .large,
                .extraLarge:
            return news.count >= 4 ? 4 : entry.news.count
        case .extraExtraLarge,
                .extraExtraExtraLarge,
                .accessibilityMedium,
                .accessibilityLarge,
                .accessibilityExtraLarge,
                .accessibilityExtraExtraLarge,
                .accessibilityExtraExtraExtraLarge:
            return news.count >= 3 ? 3 : entry.news.count
        @unknown default:
            return news.count >= 3 ? 3 : entry.news.count
        }
    }
}


struct NewsWidget: Widget {
    let kind: String = "CityKeyWidget"

    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: CityIntent.self, provider: NewsListTimelineProvider()) { entry in
            SCWidgetEntryView(entry: entry)
        }
        .contentMarginsDisabledIfAvailable()
        .configurationDisplayName("news_widget_001_title".localized())
        .description("news_widget_002_description".localized())
        .supportedFamilies([.systemSmall,
                            .systemMedium,
                            .systemLarge])
    }
}

//Network call
class NewsLoader {
    private let cityNewsApiPath = "/api/v2/smartcity/news"
    private var task: URLSessionDataTask?
    @AppStorage("cityNews", store: UserDefaults(suiteName: WidgetUtility().getAppGroupId())) var cityNews: Data?

    func fetchNewsContent(for cityID: Int, completion: @escaping ((Error?, [Content]?) -> Void)) {
        let apiPath = "/api/v2/smartcity/news?actionName=GET_News&cityId=\(cityID)"
        guard let url = URL(string: baseUrl(apiPath: apiPath)) else {
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(getPrefferedLanguage(), forHTTPHeaderField: "Accept-Language")
        request.addValue("CITYKEY", forHTTPHeaderField: "Requesting-App")
        request.addValue("iOS", forHTTPHeaderField: "OS-Name")
        request.addValue(GlobalConstants.kSupportedServiceAPIVersion, forHTTPHeaderField: "App-Version")
        request.addValue(getUserId(), forHTTPHeaderField: "User-Id")
        let confing = URLSessionConfiguration.ephemeral
        task = URLSession(configuration: confing).dataTask(with: request) { [weak self] data, response, error in
            guard let strongSelf = self else {
                return
            }
            do {
                guard let data = data else {
                    return
                }
                strongSelf.cityNews = data
                let model = try JSONDecoder().decode(News.self, from: data)
                completion(nil, model.content)
                print(model)
            } catch let error as NSError {
                completion(error, nil)
                print("Failed to load: \(error.localizedDescription)")
            }
        }
        task?.resume()
    }
    private func getUserId() -> String {
        if let userDefaults = UserDefaults(suiteName: WidgetUtility().getAppGroupId()) {
            return userDefaults.string(forKey: "userIDKey") ?? "-1"
        }
        return "-1"
    }

    private func getPrefferedLanguage() -> String {
        if let userDefaults = UserDefaults(suiteName: WidgetUtility().getAppGroupId()) {
            return userDefaults.string(forKey: "prefferedLanguage") ?? "en"
        }
        return "en"
    }

    private func baseUrl(apiPath: String) -> String {
        var baseUrl: String = ""
        baseUrl = "https://mock.api.citykey"
        return baseUrl + apiPath
    }

    //based on the scheme choose app groupId
    func getAppGroupId() -> String {
        return "group.com.telekom.opensource.citykey"
    }
}
