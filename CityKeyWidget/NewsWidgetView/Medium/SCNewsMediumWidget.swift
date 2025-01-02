//
//  SCNewsMediumWidget.swift
//  OSCA
//
//  Created by A200111500 on 28/04/22.
//  Copyright © 2022 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import SwiftUI

struct SCNewsMediumWidget: View {
    var newsList: [Content]
    var isPlaceHolder: Bool = false
    init(news: [Content], isPlaceHolder: Bool) {
        self.newsList = news
        self.isPlaceHolder = isPlaceHolder
    }
    
    var body: some View {
        VStack(spacing: -10) {
            ForEach(Array(newsList.enumerated()), id: \.1) { index, news in
                Link(destination: isPlaceHolder ? URL(string: "citykey://home")! : URL(string: "citykey://news?contentID=\(news.contentID)&contentCreationDate=\(news.contentCreationDate )&contentDetails=\(news.contentDetails)&contentTeaser=\(news.contentTeaser)&contentSource=\(news.contentSource)&contentImage=\(news.contentImage)&contentSubtitle=\(news.contentSubtitle)&imageCredit=\(news.imageCredit)&thumbnail=\(news.thumbnail)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)!) {
                    Spacer(minLength: 2)
                    NewsViewWithLeftIcon(news: news)
                    Spacer(minLength: 2)
                }
            }
        }
        .widgetBackground(backgroundView: Color.clear)
    }
}
