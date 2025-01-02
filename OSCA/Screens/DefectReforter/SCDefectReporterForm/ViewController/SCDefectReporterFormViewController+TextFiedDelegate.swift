//
//  SCDefectReporterFormViewController+TextFiedDelegate.swift
//  OSCA
//
//  Created by Bhaskar N S on 21/07/22.
//  Copyright © 2022 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

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
