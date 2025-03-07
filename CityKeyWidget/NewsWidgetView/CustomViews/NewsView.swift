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
