/*
Created by Michael on 07.12.18.
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

class SCProfileImageStore {

    static private var uuid : String?
    static private var profile_image : String?

    static func storeEncodedProfileImage(_ image : String, uuid : String){
        SCProfileImageStore.uuid = uuid
        SCProfileImageStore.profile_image = image
    }

    static func clearStoredProfileImage(){
        SCProfileImageStore.uuid = nil
        SCProfileImageStore.profile_image = nil
    }
    
    static func isImageAvailable(uuid : String) -> Bool{
        if SCProfileImageStore.uuid == uuid {
            return true
        }
        return false
    }

    static func image(for uuid : String) -> UIImage?{
        if SCProfileImageStore.isImageAvailable(uuid: uuid) {
            let encodedImage = SCProfileImageStore.profile_image
            let image = encodedImage?.imageFromBase64()
            return image
        }
        return nil
     }
}
