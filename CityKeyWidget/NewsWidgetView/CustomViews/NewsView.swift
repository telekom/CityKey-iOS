//
//  NewsView.swift
//  OSCA
//
//  Created by A200111500 on 28/04/22.
//  Copyright © 2022 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import SwiftUI
import WidgetKit

struct NewsViewWithLeftIcon: View {
    var news: Content?
    @Environment(\.sizeCategory) var category
    @Environment(\.widgetFamily) var family: WidgetFamily
    init(news: Content) {
        self.news = news
    }
    var body: some View {
        HStack() {
            if let urlStr = news?.thumbnail.encodeUrl(),
               let url = URL(string: urlStr),
               let imageData = try? Data(contentsOf: url),
               let uiImage = UIImage(data: imageData) {
                if #available(iOSApplicationExtension 18.0, *) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .widgetAccentedRenderingMode(.fullColor)
                        .aspectRatio(contentMode: .fill)
                        .frame(width: imageFrameSize().width, height: imageFrameSize().height)
                        .cornerRadius(10)
                } else {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: imageFrameSize().width, height: imageFrameSize().height)
                        .cornerRadius(10)
                }
            }
            else {
                Image("")
                .frame(width: imageFrameSize().width, height: imageFrameSize().height)
                .background(Color.gray.opacity(0.5))
                .cornerRadius(10)

            }
            VStack(alignment: .leading) {
                if #available(iOSApplicationExtension 16.0, *) {
                    Text(news?.contentTeaser ?? "")
                        .widgetAccentable()
                        .fontWeight(.semibold)
                        .font(.subheadline)
                        .lineLimit(getLineLimit())
                        .layoutPriority(1)
                        .multilineTextAlignment(.leading)
                        .padding(.leading, 8)
                } else {
                    Text(news?.contentTeaser ?? "")
                        .fontWeight(.semibold)
                        .font(.subheadline)
                        .lineLimit(getLineLimit())
                        .layoutPriority(1)
                        .multilineTextAlignment(.leading)
                        .padding(.leading, 8)
                }
            }
            Spacer(minLength: 15)
        }
        .padding([.leading, .trailing], 12)
    }

    private func dateFormatter() -> DateFormatter {
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateformatter.locale = Locale(identifier: Locale.current.identifier)
        return dateformatter
    }
    
    func dateFromString(dateString: String?) -> String? {
        guard let dateString = dateString else {
            return nil
        }
        let dateformatter = dateFormatter()
        let newDate = dateformatter.date(from: dateString)
        if let date = newDate {
            let formatter = DateFormatter()
            formatter.dateFormat = "dd. MMMM yyyy"
            return formatter.string(from: date)
        }
        return nil
    }

    private func getLineLimit() -> Int {
        switch category {
        case .accessibilityExtraExtraExtraLarge,
                .accessibilityExtraExtraLarge,
                .accessibilityExtraLarge,
                .accessibilityLarge,
                .accessibilityMedium,
                .extraExtraLarge,
                .extraExtraExtraLarge:
            return family == .systemMedium ? 4 : 3
        case .extraLarge,
                .large:
            return 3
        default:
            return 3
        }
    }
    
    private func imageFrameSize() -> (width: CGFloat, height: CGFloat) {
        switch category {
        case .small,
                .extraSmall,
                .medium,
                .large,
                .extraLarge:
            return family == .systemMedium ? (width: 60, height: 60) : (width: 65, height: 65)
        case .accessibilityExtraExtraExtraLarge,
                .accessibilityExtraExtraLarge,
                .accessibilityExtraLarge,
                .accessibilityLarge,
                .extraExtraLarge,
                .extraExtraExtraLarge,
                .accessibilityMedium:
            return family == .systemMedium ? (width: 100, height: 100) : (width: 90, height: 90)
        default:
            return (width: 65, height: 65)
        }
    }
}
