//
//  NetworkImage.swift
//  SCWidgetExtension
//
//  Created by A200111500 on 30/04/22.
//  Copyright © 2022 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import SwiftUI

struct NetworkImage: View {
    
    let url: URL?
    
    var body: some View {
        
        Group {
            if let url = url, let imageData = try? Data(contentsOf: url),
               let uiImage = UIImage(data: imageData) {
                
                if #available(iOSApplicationExtension 18.0, *) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .widgetAccentedRenderingMode(.fullColor)
                        .aspectRatio(contentMode: .fill)
                } else {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                }
            }
            else {
                Image("")
            }
        }
    }
}

