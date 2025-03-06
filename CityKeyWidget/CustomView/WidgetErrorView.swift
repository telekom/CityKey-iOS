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
//  WidgetErrorView.swift
//  OSCA
//
//  Created by Bhaskar N S on 26/10/22.
//  Copyright © 2022 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import SwiftUI
import WidgetKit

struct WidgetErrorView: View {
    var errorMessage: String?
    @Environment(\.widgetFamily) var family: WidgetFamily
    var body: some View {
        switch family {
        case .systemSmall:
            WidgetSmallErrorView(errorMessage: errorMessage)
        default:
            WidgetMediumErrorView(errorMessage: errorMessage)
        }

    }
}

struct WidgetSmallErrorView: View {
    var errorMessage: String?
    var body: some View {
        VStack(alignment: .center, spacing: 5.0) {
            if #available(iOSApplicationExtension 18.0, *) {
                Image("person")
                    .resizable()
                    .widgetAccentedRenderingMode(.fullColor)
                    .frame(maxWidth: 75.0, maxHeight: 75.0)
                    .scaledToFit()
                    .padding(.top)
                Text(errorMessage ?? "waste_calendar_widget_error".localized())
                    .widgetAccentable()
                    .fontWeight(.medium)
                    .padding(.top, 4)
                    .padding([.bottom, .leading, .trailing],4.0)
                    .font(.system(size: 10))
                    .multilineTextAlignment(.center)
                    .layoutPriority(1)
            } else {
                Image("person")
                    .resizable()
                    .frame(maxWidth: 75.0, maxHeight: 75.0)
                    .scaledToFit()
                    .padding(.top)
                Text(errorMessage ?? "waste_calendar_widget_error".localized())
                    .fontWeight(.medium)
                    .padding(.top, 4)
                    .padding([.bottom, .leading, .trailing],4.0)
                    .font(.system(size: 10))
                    .multilineTextAlignment(.center)
                    .layoutPriority(1)
            }
        }
        .widgetBackground(backgroundView: Color.clear)
    }
}

struct WidgetMediumErrorView: View {
    var errorMessage: String?
    var body: some View {
        VStack {
            if #available(iOSApplicationExtension 18.0, *) {
                Image("person")
                    .widgetAccentedRenderingMode(.fullColor)
            } else {
                Image("person")
            }
            if #available(iOSApplicationExtension 16.0, *) {
                Text(errorMessage ?? "waste_calendar_widget_error".localized())
                    .widgetAccentable()
                    .fontWeight(.medium)
                    .padding(.top, 4.0)
                    .padding([.leading, .trailing], 20.0)
                    .font(.system(size: 14))
                    .multilineTextAlignment(.center)
            } else {
                Text(errorMessage ?? "waste_calendar_widget_error".localized())
                    .fontWeight(.medium)
                    .padding(.top, 4.0)
                    .padding([.leading, .trailing], 20.0)
                    .font(.system(size: 14))
                    .multilineTextAlignment(.center)
            }
        }
        .widgetBackground(backgroundView: Color.clear)
    }
}

struct WidgetErrorView_Previews: PreviewProvider {
    static var previews: some View {
        WidgetErrorView()
    }
}
