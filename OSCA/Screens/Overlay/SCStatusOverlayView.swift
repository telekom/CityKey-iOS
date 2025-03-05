/*
Created by Michael on 19.05.20.
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

class SCStatusOverlayView: UIView {


    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var actionBtn: UIButton!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var textLbl: UILabel!
    
    var actionHandler : (() -> Void)? = nil

    func showText(_ text : String, title: String?, textAlignment: NSTextAlignment){
        self.actionBtn.isHidden = true
        
        self.titleLbl.adaptFontSize()
        self.titleLbl.text = title
        self.titleLbl.isHidden =  title?.count == 0

        self.textLbl.adaptFontSize()
        self.textLbl.text = text
        self.textLbl.textAlignment = textAlignment
        
        self.activityIndicator.stopAnimating()
        self.activityIndicator.isHidden = true

        self.actionHandler = nil
    }
    
    func showText(_ text : String, title: String?, textAlignment:NSTextAlignment, btnTitle: String, btnImage: UIImage, btnColor: UIColor?, btnAction : (() -> Void)? = nil) {
        
        self.titleLbl.adaptFontSize()
        self.titleLbl.text = title
        self.titleLbl.isHidden =  title?.count == 0

        self.textLbl.adaptFontSize()
        self.textLbl.text = text
        self.textLbl.textAlignment = textAlignment
         
        self.activityIndicator.stopAnimating()
        self.activityIndicator.isHidden = true

        
        self.actionBtn.isHidden = false
        //self.actionBtn.setTitle(" " + "btnTitle".localized(), for: .normal)
        self.actionBtn.setTitle(" " + btnTitle, for: .normal)
        self.actionBtn.setTitleColor(btnColor ?? UIColor(named: "CLR_OSCA_BLUE")!, for: .normal)
        self.actionBtn.titleLabel?.adaptFontSize()
        self.actionBtn.setImage(UIImage(named: "action_resend_email")?.maskWithColor(color: btnColor ?? UIColor(named: "CLR_OSCA_BLUE")!), for: .normal)
        self.actionHandler = btnAction

    }

    func showActivity(title: String? = nil){
        self.actionBtn.isHidden = true
        
        self.titleLbl.adaptFontSize()
        self.titleLbl.text = title
        self.titleLbl.isHidden =  title?.count == 0

        self.textLbl.isHidden = true
        
        self.activityIndicator.startAnimating()
        self.activityIndicator.isHidden = false

        self.actionHandler = nil

    }

    func hideActivityIndicator() {
        self.activityIndicator.stopAnimating()
        self.activityIndicator.isHidden = true
    }
        
    @IBAction func actionBtnWasPressed(_ sender: Any) {
        actionHandler?()
    }
}
