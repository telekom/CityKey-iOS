/*
Created by Michael on 05.04.19.
Copyright © 2019 Deutsche Telekom AG - VTI Organization. All rights reserved.

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

/**
 * Extension of the SCPWDRecoveryVC for handling
 * the delegate methods of the textfield component
 */
extension SCPWDRestoreUnlockVC : SCTextfieldComponentDelegate
{
    func textFieldComponentShouldReturn(component: SCTextfieldComponent) -> Bool {
        component.resignResponder()
        
        if (component == self.txtfldEmail){
            if let nextComponent = self.txtfldPwd1 {
                self.scrollComponentToVisibleArea(component: nextComponent)
                nextComponent.becomeResponder()
            }
        }
        if (component == self.txtfldPwd1){
            if let nextComponent : SCTextfieldComponent = self.txtfldPwd2?.isEnabled() ?? false ? self.txtfldPwd2  : nil  {
                self.scrollComponentToVisibleArea(component: nextComponent)
                nextComponent.becomeResponder()
            }
        }
        return true
    }
    
    func textFieldComponentEditingBegin(component: SCTextfieldComponent) {
        
        self.activeComponent = component
        self.scrollComponentToVisibleArea(component:component)
        
        // we show the password check controller when entering the password field
        if component == self.txtfldPwd1 {
            UIView.animate(withDuration: 0.5, delay: 0.0,
                           options: [.curveEaseInOut], animations: {
                            self.pwdCheckVCHeightConstraint.constant = self.pwdCheckVCOpenedHeight + self.pwdCheckViewController!.pwdCheckDetailLabelHeight.constant
                            self.view.layoutIfNeeded()
            }, completion: nil)
        }
        
    }
    
    
    func textFieldComponentEditingEnd(component: SCTextfieldComponent) {
        if component == self.txtfldPwd1 {
            UIView.animate(withDuration: 0.5, delay: 0.0,
                           options: [.curveEaseInOut], animations: {
                            self.pwdCheckVCHeightConstraint.constant = 0.0
                            self.view.layoutIfNeeded()
            }, completion: nil)
        }
        
        self.presenter.txtFieldEditingDidEnd(value : component.text ?? "", inputField: restoreField(for: component)!, textFieldType: component.textfieldType)
    }
    
    func textFieldComponentDidChange(component: SCTextfieldComponent) {
        self.presenter.textFieldComponentDidChange(for: restoreField(for: component)!)
    }

}

