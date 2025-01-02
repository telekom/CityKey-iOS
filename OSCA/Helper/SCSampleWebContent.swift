//
//  SCSampleWebContent.swift
//  SmartCity
//
//  Created by Michael on 25.10.18.
//  Copyright © 2018 Michael. All rights reserved.
//

import UIKit

class SCSampleWebContent: NSObject {

 
    func htmlSampleWebContent(for message: SCModelMessage) -> String{
        let details = message.detailText
        let teaser = message.shortText
        let imageURL = message.imageURL?.absoluteUrlString()
        
        var linkButton = ""
        
        if let link = message.contentURL?.absoluteString {
            let btnText = "h_003_home_articles_btn_more".localized()
            linkButton = """
            <button class="btn" onclick="location.href='\(link)';">\(btnText)</button>
            """
        }

        
        let baseHTMLString = """
        <html>
        
        <head>
            <meta name="viewport" content="width=device-width, initial-scale=1">
            <style>
            .container {
                position: relative;
                width: 86%;
        
                padding: 0px 7%;
            }
        
            .container img {
                width: 100%;
                height: auto;
            }
        
            .container .btn {
                position: absolute;
                bottom: 0px;
                right: 7%;
                background-color: rgba(0,0,0,0.5);
        
                color: white;
                font-size: 12px;
                padding: 6px 12px;
                border: none;
                cursor: pointer;
                border-radius: 0px;
                text-align: center;
            }
        
            .container .btn:hover {
                background-color: rgba(0,0,0,0.9);
            }
        
            </style>
        </head>
        

        
        <body>
        <div class="container">
        <img src="\(String(describing: imageURL))" alt="Image" style="width:100%">
        \(linkButton)
        </div>

        <p style="text-align: left;padding-left: 7%;padding-right: 7%;font-size:100%;"><span style="font-size: 110%;"><strong>\(teaser)</strong></span></p>
        <p style="text-align: left;padding-left: 7%;padding-right: 7%;font-size: 100%;"><span style="font-size: 100%;">\(details)</span></p>
        </body></html>
        """
        return baseHTMLString;
    }
    
}

