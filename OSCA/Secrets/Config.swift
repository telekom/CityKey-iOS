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
import Foundation

struct Config {
    static let shared = Config()
    
    let googleMapsAPIKey: String
    let appCenterIdentifier: String?
    let moEngageAppGroup: String?
    let moEngageIdentifier: String?
    let adjustIdentifier: String?
    
    private init() {
        let scheme = Config.getCurrentScheme()
        self.googleMapsAPIKey = Config.getConfigValue(for: "GOOGLE_MAPS_API_KEY_\(scheme)")
        self.appCenterIdentifier = Config.getConfigValue(for: "APP_CENTER_IDENTIFIER_\(scheme)")
        self.moEngageAppGroup = Config.getConfigValue(for: "MOENGAGE_APP_GROUP_\(scheme)")
        self.moEngageIdentifier = Config.getConfigValue(for: "MOENGAGE_IDENTIFIER_\(scheme)")
        self.adjustIdentifier = Config.getConfigValue(for: "ADJUST_IDENTIFIER_\(scheme)")
    }
    
    private static func getConfigValue(for key: String) -> String {
        // Construct the path relative to the project directory
        if let secretsPath = Bundle.main.infoDictionary?["SCSecretsPath"] as? String,
                  FileManager.default.fileExists(atPath: secretsPath),
                  let dict = NSDictionary(contentsOfFile: secretsPath) as? [String: String], let value = dict[key] {
            print("-----Local-----")
            print(key)
            print(value)
            print("----------")
            return value
        } else if let infoDictionary = Bundle.main.infoDictionary?["Data"] as? [String: Any],
           let environmentDict = infoDictionary["Environment"] as? [String: String],
           let value = environmentDict[key] {
//            SCFileLogger.shared.write("key : \(value) ", withTag: .logout)
            print("----CI/CD------")
            print(key)
            print(value)
            print("----------")
            return value
        } else {
//            SCFileLogger.shared.write("else part \(key) Not able to fetch", withTag: .logout)
            fatalError("\(key) not set in Info.plist")
        }
    }

    private static func getCurrentScheme() -> String {
        guard let scheme = Bundle.main.infoDictionary?["CONFIG_SCHEME"] as? String else {
            fatalError("CONFIG_SCHEME not set in Info.plist")
        }
        return scheme
    }
}
