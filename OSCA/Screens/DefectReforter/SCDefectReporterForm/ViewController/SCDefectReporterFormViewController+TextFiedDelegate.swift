/*
Created by Bhaskar N S on 21/07/22.
Copyright © 2022 Deutsche Telekom AG - VTI Organization. All rights reserved.

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

SPDX-FileCopyrightText: 2025 Deutsche Telekom AG, Bhaskar N S
SPDX-License-Identifier: Apache-2.0 AND LicenseRef-Deutsche-Telekom-Brand
License-Filename: LICENSES/Apache-2.0.txt LICENSES/LicenseRef-Deutsche-Telekom-Brand.txt
*/

import Foundation


extension SCDefectReporterFormViewController: SCTextfieldComponentDelegate, SCTextViewComponentDelegate {
    func textFieldComponentShouldReturn(component: SCTextfieldComponent) -> Bool {
        component.resignResponder()
        
        if (component == self.txtfldEmail){
            if let nextComponent = self.txtfldFirstName {
                nextComponent.becomeResponder()
            }
        }
        if (component == self.txtfldFirstName){
            if let nextComponent = self.txtfldLastName {
                nextComponent.becomeResponder()
            }
        }
        return true
    }
    
    func textFieldComponentEditingBegin(component: SCTextfieldComponent) {
        self.activeComponent = component
    }
    
    func textFieldComponentEditingEnd(component: SCTextfieldComponent) {
        
        self.presenter.txtFieldEditingDidEnd(value : component.text ?? "", inputField: self.defectReporterField(for: component)!, textFieldType: component.textfieldType)
    }
    
    func textFieldComponentDidChange(component: SCTextfieldComponent) {
        self.presenter.textFieldComponentDidChange(for: defectReporterField(for: component)!)
    }
    
    func textViewComponentEditingBegin(component: SCTextViewComponent) {
        self.activeTxvComponent = component
    }
    
    func textViewComponentDidChange(component: SCTextViewComponent) {
        self.presenter.textFieldComponentDidChange(for: defectReporterField(for: component)!)
        self.yourConcernContainerViewHeight.constant = !(txtfldYourConcern?.isEnabled() ?? false) ? 0 : 80 + (txtfldYourConcern?.textViewHeightConstraint.constant)!
    }
    
    func textViewComponentEditingEnd(component: SCTextViewComponent) {
        self.presenter.txtFieldEditingDidEnd(value : component.text ?? "", inputField: self.defectReporterField(for: component)!, textFieldType: component.textViewType)
    }
    
    private func defectReporterField(for inputField: SCTextViewComponent? ) ->  SCDefectReporterInputFields?{
        switch inputField {
        case self.txtfldYourConcern:
            return .yourconcern
        default:
            return nil
        }
    }
    
    private func defectReporterField(for inputField: SCTextfieldComponent? ) ->  SCDefectReporterInputFields?{
        switch inputField {
        case self.txtfldYourConcern:
            return .yourconcern
        case self.txtfldEmail:
            return .email
        case self.txtfldFirstName:
            return .fname
        case self.txtfldLastName:
            return .lname
        case self.txtfldWasteBinID:
            return .wastebinid
        default:
            return nil
        }
    }
}
