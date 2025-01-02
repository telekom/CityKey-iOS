//
//  SCNewsSmallWidget.swift
//  OSCA
//
//  Created by A200111500 on 28/04/22.
//  Copyright © 2022 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import SwiftUI

struct SCNewsSmallWidget: View {
    var news: Content
    var isPlaceHolder: Bool = false
    init(news: Content, isPlaceHolder: Bool) {
        self.news = news
        self.isPlaceHolder = isPlaceHolder
    }
    var body: some View {
        VStack (alignment: .leading) {
            Spacer()
            //To make text redable on gradient adding two newline characters.
            Text("\r\n\n" + news.contentTeaser)
                .fontWeight(.medium)
                .font(Font.footnote.leading(.loose))
                .lineLimit(isPlaceHolder ? 4 : 6)
                .foregroundColor(.white)
                .padding(12)
                .frame(maxWidth: .infinity)
                .background(
                    LinearGradient(
                        colors: isPlaceHolder ? [Color.clear] : [Color.black,
                                                                 Color.black.opacity(0.8),
                                                                 Color.black.opacity(0.6),
                                                                 Color.black.opacity(0.4),
                                                                 Color.black.opacity(0.1),
                                                                 Color.clear],
                        startPoint: .bottom,
                        endPoint: .top
                    )
                )
        }
        .widgetBackground(backgroundView: NetworkImage(url: URL(string: news.thumbnail.encodeUrl() ?? "")))
        .background(
            NetworkImage(url: URL(string: news.thumbnail.encodeUrl() ?? ""))
        )
        .widgetURL(isPlaceHolder ? URL(string: "citykey://home") : URL(string: "citykey://news?contentID=\(news.contentID)&contentCreationDate=\(news.contentCreationDate )&contentDetails=\(news.contentDetails)&contentTeaser=\(news.contentTeaser)&contentSource=\(news.contentSource)&contentImage=\(news.contentImage)&contentSubtitle=\(news.contentSubtitle)&imageCredit=\(news.imageCredit)&thumbnail=\(news.thumbnail)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)!)
    }
}

