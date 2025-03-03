//
//  UIColor + Extension.swift
//  OSCA
//
//  Created by Rutvik Kanbargi on 20/07/20.
//  Copyright © 2020 Deutsche Telekom AG - VTI Organization. All rights reserved.
//
/*
Created by Rutvik Kanbargi on 20/07/20.
Copyright © 2020 Deutsche Telekom AG - VTI Organization. All rights reserved.

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

SPDX-FileCopyrightText: 2025 Deutsche Telekom AG, Rutvik Kanbargi
SPDX-License-Identifier: Apache-2.0 AND LicenseRef-Deutsche-Telekom-Brand
License-Filename: LICENSES/Apache-2.0.txt LICENSES/LicenseRef-Deutsche-Telekom-Brand.txt
*/

import UIKit

extension UIColor {

    static var appointmentReservation: UIColor {
        return UIColor(hexString: "FF8700")
    }

    static var appointmentRejected: UIColor {
        return UIColor(hexString: "D0021B")
    }

    static var clearBackground: UIColor {
        return UIColor(named: "CLR_BCKGRND") ?? UIColor.clear
    }

    static var appointmentExpired: UIColor {
        return UIColor(named: "CLR_BORDER_DARKGRAY") ?? UIColor.clear
    }

    static var appointmentChanging: UIColor {
        return UIColor(hexString: "0F69CB")
    }
    
    static var appointmentStatusText: UIColor {
        return UIColor(named: "CLR_LABEL_TEXT_WHITE") ?? UIColor.clear
    }

    static var appointmentStatusTextExpired: UIColor {
        return UIColor(named: "CLR_LABEL_TEXT_CANCELLED") ?? UIColor.clear
    }

    static var seperatorCLR: UIColor {
        return UIColor(hexString: "a4aab3")
    }

    static var coolGray: UIColor {
        return UIColor(hexString: "ededed")
    }

    static var labelTextBlackCLR: UIColor {
        return UIColor(named: "CLR_LABEL_TEXT_BLACK") ?? .white
    }
    
    static var ausweisBlue : UIColor {
        return UIColor(named: "CLR_AUSWEIS_BLUE") ?? UIColor.blue
    }
    
    static var oscaColor : UIColor {
        return UIColor(named: "CLR_OSCA_BLUE") ?? UIColor.blue
    }
    
    static var calendarColor: UIColor {
        return UIColor(named: "CLR_NAVBAR_EXPORT") ?? UIColor.white
    }
    
    static var postponeEventStatus: UIColor {
        return UIColor(hexString: "#739B3B")
    }
    
    static var switchStateOn: UIColor {
        return UIColor(named: "CLR_SWITCH_SELECTED_TRUE") ?? UIColor.green
    }
    
    static var switchStateOff: UIColor {
        return UIColor(named: "CLR_SWITCH_SELECTED_FALSE") ?? UIColor.gray
    }
    
    static var switchDisabled: UIColor {
        return UIColor(named: "CLR_SWITCH_DISABLED") ?? UIColor.lightGray
    }
    
    static var swithStateOnWithDisabled: UIColor {
        return UIColor(named: "CLR_SWITCH_SELECTED_TRUE_DISABLED") ?? UIColor.green
    }
}
