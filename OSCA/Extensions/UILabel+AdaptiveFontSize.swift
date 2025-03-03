/*
Created by Michael on 20.11.18.
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

/**
 *
 * Extension for supporting an adaptive font size on the iPhone SE
 *
 */
extension UILabel{

    func adaptFontSize() {
        
        // For devices with a width of 320 we need to scale the
        // font size down
        if (UIScreen.main.bounds.size.width) == 320 {
            if self.tag == 0 {  // self.tag = 0 is default value .
                self.tag = 1
                
                var newFontSize : CGFloat = 0.0
                
                switch self.font.pointSize {
                case 45.0:
                    newFontSize = 38.0
                    break
                case 37.0:
                    newFontSize = 32.0
                    break
                case 34.0:
                    newFontSize = 28.0
                    break
                case 28.0:
                    newFontSize = 24.0
                    break
                case 24.0:
                    newFontSize = 20.0
                    break
                case 22.0:
                    newFontSize = 19.0
                    break
                case 21.0:
                    newFontSize = 18.0
                    break
                case 20.0:
                    newFontSize = 17.0
                    break
                case 19.0:
                    newFontSize = 16.0
                    break
                case 18.0:
                    newFontSize = 15.0
                    break
                case 17.0:
                    newFontSize = 15.0
                    break
                case 16.0:
                    newFontSize = 14.0
                    break
                case 15.0:
                    newFontSize = 13.0
                    break
                case 14.0:
                    newFontSize = 12.0
                    break
                case 13.0:
                    newFontSize = 12.0
                    break
                case 12.0:
                    newFontSize = 10.0
                    break
                case 11.0:
                    newFontSize = 9.0
                    break
                case 10.0:
                    newFontSize = 8.0
                    break
                default:
                    newFontSize = 4.0
                }
                
                let oldFontName = self.font.fontName
                self.font = UIFont(name: oldFontName, size: newFontSize) // and set new font here .
            }
        }
    }
    
}
