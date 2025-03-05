/*
Created by Michael on 01.02.20.
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

SPDX-FileCopyrightText: 2025 Deutsche Telekom AG, Michael
SPDX-License-Identifier: Apache-2.0 AND LicenseRef-Deutsche-Telekom-Brand
License-Filename: LICENSES/Apache-2.0.txt LICENSES/LicenseRef-Deutsche-Telekom-Brand.txt
*/

import UIKit

protocol SCInfoNoticeDisplaying: AnyObject, SCDisplaying {
    func setupUI(title: String,
                 topText: NSAttributedString,
                 displayActIndicator: Bool)
    
    func dismiss()

}

protocol SCInfoNoticePresenting: SCPresenting {
    func setDisplay(_ display: SCInfoNoticeDisplaying)
    func closeBtnWasPressed()
}

class SCInfoNoticePresenter {
    
    weak private var display: SCInfoNoticeDisplaying?
    private let injector: SCAdjustTrackingInjection
    private let title: String
    private let content: String

    init(title: String, content: String, injector: SCAdjustTrackingInjection) {
        
        self.title = title
        self.content = content
        self.injector = injector
    }
        
}

extension SCInfoNoticePresenter: SCPresenting {
    func viewDidLoad() {
        
        var topText = NSAttributedString(string: "")
        
        if let attrStringTop =  content.htmlAttributedString {
            let htmlAttrToptring = NSMutableAttributedString(attributedString: attrStringTop)
            htmlAttrToptring.replaceFont(with: UIFont.systemFont(ofSize: 15.0, weight: UIFont.Weight.regular), color: UIColor(named: "CLR_LABEL_TEXT_BLACK")!)
            topText = htmlAttrToptring

        }

        self.display?.setupUI(title: title,
                              topText:  topText,
                              displayActIndicator : true)
    }

    func viewWillAppear() {
    }
    
    func viewDidAppear() {
    }
}

extension SCInfoNoticePresenter : SCInfoNoticePresenting {

    func setDisplay(_ display: SCInfoNoticeDisplaying) {
        self.display = display
    }
    
    func closeBtnWasPressed(){
        self.display?.dismiss()
    }
}

