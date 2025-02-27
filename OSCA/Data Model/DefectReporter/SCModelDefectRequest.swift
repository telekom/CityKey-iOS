/*
Created by Harshada Deshmukh on 14/05/21.
Copyright © 2021 Deutsche Telekom AG - VTI Organization. All rights reserved.

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

SPDX-FileCopyrightText: 2025 Deutsche Telekom AG, Harshada Deshmukh
SPDX-License-Identifier: Apache-2.0 AND LicenseRef-Deutsche-Telekom-Brand
License-Filename: LICENSES/Apache-2.0.txt LICENSES/LicenseRef-Deutsche-Telekom-Brand.txt
*/

import Foundation

struct SCModelDefectRequest {
    let lastName: String
    let firstName: String
    let serviceCode: String
    let lat: String
    let long: String
    let email: String
    let description: String
    let mediaUrl: String
    let wasteBinId: String
    let subServiceCode: String
    let location: String
    let streetName: String
    let houseNumber: String
    let postalCode: String
    let phoneNumber: String

    func toModel() -> [String : Any] {
        let bodyDict = ["lastName": lastName,
                        "firstName": firstName,
                        "service_code": serviceCode,
                        "lat": lat,
                        "long": long,
                        "email": email,
                        "description": description,
                        "media_url":  mediaUrl,
                        "wasteBinId": wasteBinId,
                        "sub_service_code": subServiceCode,
                        "streetName": streetName,
                        "houseNumber": houseNumber,
                        "postalCode": postalCode,
                        "phoneNumber": phoneNumber,
                        "location": location] as [String : Any]

        return bodyDict
    }
}
