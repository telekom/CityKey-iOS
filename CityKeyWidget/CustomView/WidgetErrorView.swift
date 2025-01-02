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
