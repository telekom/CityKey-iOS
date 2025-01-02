//
//  SCPWDRecoveryVC+ComponentDelegate.swift
//  SmartCity
//
//  Created by Michael on 05.04.19.
//  Copyright © 2019 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

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

