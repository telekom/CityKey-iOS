//
//  TimelineEntry.swift
//  SCWidgetExtension
//
//  Created by Bhaskar N S on 17/05/22.
//  Copyright © 2022 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import WidgetKit
import Intents

struct NewsTimelineEntry: TimelineEntry {
    let date: Date
    let news: [Content]
    let configuration: CityIntent
    var isPlaceholder = false
}

extension NewsTimelineEntry {
    static var stub: NewsTimelineEntry {
        .init(date: Date(), news: [Content(contentID: 1, contentCreationDate: "08. July 2022",
                                           contentDetails: "bhaskar", contentImage: "bhaskar", imageCredit: "bhaskar",
                                           contentSource: "bhaskar",
                                           contentTeaser: "Spurensuche Gartenschläfer – Ausstellung in der Stadtbücherei Spurensuche Gartenschläfer – Ausstellung in der Stadtbücherei",
                                           cityID: 0, language: .de, sticky: false, thumbnail: "bhaskar",
                                           thumbnailCredit: "bhaskar", contentSubtitle: "bhaskar", uid: 0),
                                   Content(contentID: 1, contentCreationDate: "08. July 2022",
                                           contentDetails: "bhaskar", contentImage: "bhaskar", imageCredit: "bhaskar",
                                           contentSource: "bhaskar",
                                           contentTeaser: "Spurensuche Gartenschläfer – Ausstellung in der Stadtbücherei Spurensuche Gartenschläfer – Ausstellung in der Stadtbücherei Spurensuche Gartenschläfer – Ausstellung in der Stadtbücherei Spurensuche Gartenschläfer – Ausstellung in der Stadtbücherei",
                                           cityID: 0, language: .de, sticky: false, thumbnail: "bhaskar",
                                           thumbnailCredit: "bhaskar", contentSubtitle: "bhaskar", uid: 0),
                                   Content(contentID: 1, contentCreationDate: "08. July 2022",
                                           contentDetails: "bhaskar", contentImage: "bhaskar", imageCredit: "bhaskar",
                                           contentSource: "bhaskar",
                                           contentTeaser: "Spurensuche Gartenschläfer – Ausstellung in der Stadtbücherei Spurensuche Gartenschläfer – Ausstellung in der Stadtbücherei",
                                           cityID: 0, language: .de, sticky: false, thumbnail: "bhaskar",
                                           thumbnailCredit: "bhaskar", contentSubtitle: "bhaskar", uid: 0),
                                   Content(contentID: 1, contentCreationDate: "08. July 2022",
                                           contentDetails: "bhaskar", contentImage: "bhaskar", imageCredit: "bhaskar",
                                           contentSource: "bhaskar",
                                           contentTeaser: "Spurensuche Gartenschläfer – Ausstellung in der Stadtbücherei Spurensuche Gartenschläfer – Ausstellung in der Stadtbücherei Spurensuche Gartenschläfer – Ausstellung in",
                                           cityID: 0, language: .de, sticky: false, thumbnail: "bhaskar",
                                           thumbnailCredit: "bhaskar", contentSubtitle: "bhaskar", uid: 0)], configuration: CityIntent())
    }
    
    static var placeholder: NewsTimelineEntry {
        var stub = NewsTimelineEntry.stub
        stub.isPlaceholder = true
        return stub
    }
}
