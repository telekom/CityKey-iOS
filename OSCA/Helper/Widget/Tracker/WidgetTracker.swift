//
//  WidgetTracker.swift
//  OSCA
//
//  Created by Bhaskar N S on 27/05/22.
//  Copyright © 2022 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import WidgetKit

protocol WidgetTracking {
    func logWidgetAnalytics()
}

struct WidgetTracker: WidgetTracking {
    private let injector: SCAdjustTrackingInjection
    init(injector: SCAdjustTrackingInjection) {
        self.injector = injector
    }
    
    func logWidgetAnalytics() {
        if #available(iOS 14.0, *) {
            WidgetCenter.shared.getCurrentConfigurations { result in
                switch result {
                case .success(let info):
                    changesInWidgetFamily(info: info)
                case .failure:
                    break
                }
            }
        } else {
            // do nothing
        }
    }
    
    @available(iOS 14.0, *)
    private func changesInWidgetFamily(info: [WidgetInfo]) {
        var activeWidgets: [String] = [String]()
        for widgetInfo in info {
            switch widgetInfo.kind {
            case "WasteCalendarWidget":
                switch widgetInfo.family {
                case .systemSmall:
                    sendAddWidget(event: AnalyticsKeys.Widget.WasteCalendar.smallWidget)
                    activeWidgets.append(AnalyticsKeys.Widget.WasteCalendar.smallWidget)
                default:
                    sendAddWidget(event: AnalyticsKeys.Widget.WasteCalendar.mediumWidget)
                    activeWidgets.append(AnalyticsKeys.Widget.WasteCalendar.mediumWidget)
                }
            case "CityKeyWidget":
                switch widgetInfo.family {
                case .systemSmall:
                    sendAddWidget(event: AnalyticsKeys.Widget.newsSmallWidget)
                    activeWidgets.append(AnalyticsKeys.Widget.newsSmallWidget)
                case .systemMedium:
                    sendAddWidget(event: AnalyticsKeys.Widget.newsMediumWidget)
                    activeWidgets.append(AnalyticsKeys.Widget.newsMediumWidget)
                case .systemLarge:
                    sendAddWidget(event: AnalyticsKeys.Widget.newsLargeWidget)
                    activeWidgets.append(AnalyticsKeys.Widget.newsLargeWidget)
                default:
                    break
                }
            default:
                break
            }
        }
        sendRemoveWidgetEvent(activeWidgets: activeWidgets)
        saveActive(widgets: activeWidgets)
    }
    
    private func sendAddWidget(event: String) {
        var widgetData: [String] = UserDefaults.standard.value(forKey: UserDefaultKeys.widgetInfo) as? [String] ?? [String]()
        if !(widgetData.contains(event)) {
            injector.trackEvent(eventName: event)
            widgetData.append(event)
        }
    }
    
    private func sendRemoveWidgetEvent(activeWidgets: [String]) {
        let widgetData: [String] = UserDefaults.standard.value(forKey: UserDefaultKeys.widgetInfo) as? [String] ?? [String]()
        for widget in widgetData {
            if !activeWidgets.contains(widget) {
                injector.trackEvent(eventName: "Remove"+"\(widget)")
            }
        }
    }
    
    private func saveActive(widgets: [String]) {
        UserDefaults.standard.set(widgets, forKey: UserDefaultKeys.widgetInfo)
    }
}
