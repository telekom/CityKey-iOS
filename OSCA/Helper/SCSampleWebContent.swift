/*
Created by Michael on 25.10.18.
Copyright © 2018 Michael. All rights reserved.

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

SPDX-FileCopyrightText: 2025 Deutsche Telekom AG, Copyright © 2018 Michael
SPDX-License-Identifier: Apache-2.0 AND LicenseRef-Deutsche-Telekom-Brand
License-Filename: LICENSES/Apache-2.0.txt LICENSES/LicenseRef-Deutsche-Telekom-Brand.txt
*/

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

