/*
Created by Michael on 21.01.19.
Copyright © 2019 Michael. All rights reserved.

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

SPDX-FileCopyrightText: 2025 Deutsche Telekom AG, Copyright © 2019 Michael
SPDX-License-Identifier: Apache-2.0 AND LicenseRef-Deutsche-Telekom-Brand
License-Filename: LICENSES/Apache-2.0.txt LICENSES/LicenseRef-Deutsche-Telekom-Brand.txt
*/

import UIKit

struct SCImageURL: Codable, Hashable{
    
    /**
     *
     * SCImageURL Class provides information about the imageurl and persistence behaviour
     *
     * @param urlString relative path string for the image (will be delivered by the backen api)
     * @param persistence if TRUE, the image won't be deleted even when the cache will be erased
     */
    private var urlString : String
    private var persistence : Bool = false

    
    static func documentsDir() -> String {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true) as [String]
        return paths[0]
    }
    
    static func cachesDir() -> String {
        let paths = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true) as [String]
        return paths[0]
    }

    init(urlString: String, persistence: Bool)
    {
        self.urlString = urlString
        self.persistence = persistence
    }

    
    func absoluteUrlString() -> String {
        
        return urlString.encodeUrl() ?? ""
    }
    
    func absoluteUrl() -> URL {
        return urlString.absoluteUrl()
    }

    func storagePathforImage() -> String {
        let directory = persistence ? SCImageURL.documentsDir() : SCImageURL.cachesDir()
        return String(format:"%@/%@", directory, self.stripURL(url: self.urlString))
    }

    func canBeStoredLazy() -> Bool {
        return persistence ? false : true
    }
    
    private func stripURL(url:String) -> String {
        return url.replacingOccurrences(of: "/", with: "___", options: NSString.CompareOptions.literal, range: nil)
    }
    
   
    
}
