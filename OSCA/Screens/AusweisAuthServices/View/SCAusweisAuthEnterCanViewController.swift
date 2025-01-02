//
//  SCAusweisAuthEnterCanViewController.swift
//  OSCA
//
//  Created by Bharat Jagtap on 18/03/21.
//  Copyright © 2021 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import UIKit

protocol SCAusweisAuthEnterCanViewDisplay : SCAusweisAuthPINViewDisplay {

}


class SCAusweisAuthEnterCanViewController: UIViewController {
    private weak var pinViewController : SCAusweisAuthPINViewController!
    var presenter : SCAusweisAuthEnterCanPresenting!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupAccessibilityIDs()
        setupAccessibility()
        
        presenter.setDisplay(display: self)
        presenter.viewDidLoad()
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "SegueSCAusweisAuthPINViewController" {
            self.pinViewController = (segue.destination as! SCAusweisAuthPINViewController)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        presenter.viewWillAppear()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        presenter.viewDidAppear()
    }
    
    func setupUI() {

        pinViewController.hidePinHelpButton()
        updateLabels()
    }
    
    private func updateLabels() {
        
        //pinViewController.heading1.text = "egov_pin_info1".localized()
        pinViewController.setHeader1(text: "egov_can_info_label".localized(), error: false)
        
        //pinViewController.heading2.text = ""
        pinViewController.setHeader2(text: "", error: false)
                
        //pinViewController.pin5DigitButton.setTitle("egov_pin_5digits_pin_label".localized(), for: .normal)
        pinViewController.setPinHelpButtonTitle(title: "")
        
        //pinViewController.helpButton.setTitle("egov_pin_help_label".localized(), for: .normal)
        pinViewController.setNeedHelpButtonTitle(title: "egov_help_link_btn".localized())
        
        //pinViewController.submitPIN.setTitle("egov_pin_title".localized(), for: .normal)
        pinViewController.setSubmitButtonTitle(title: "egov_pin_submit_btn".localized())

    }
    // setup accessibility ids for automated testing
    private func setupAccessibilityIDs(){
        

    }

    private func setupAccessibility(){
        
        pinViewController.heading1.accessibilityLabel = "egov_can_info_label".localized()
        pinViewController.heading2.accessibilityLabel = ""
        //pinViewController.pin5DigitButton.accessibilityLabel =  "egov_pin_5digits_pin_label".localized()
        pinViewController.helpButton.accessibilityLabel = "egov_help_link_btn".localized()
        pinViewController.submitPIN.accessibilityLabel = "egov_pin_submit_btn".localized()

    }
    
}

extension SCAusweisAuthEnterCanViewController : SCAusweisAuthEnterCanViewDisplay {
    
    var pin : String {
        get {
            return pinViewController.pin
        }
        set {
            pinViewController.pin = newValue
        }
    }
    
    func setHeader1(text : String, error : Bool) {
        pinViewController.setHeader1(text: text, error: error)
    }
    
    func setHeader2(text : String, error : Bool) {
        pinViewController.setHeader2(text: text, error: error)
    }
    
    func setNumberOfDigitsForPin(digits : Int) {
        pinViewController.setNumberOfDigitsForPin(digits: digits)
    }
    
    func setPinHelpButtonTitle(title : String) {
        pinViewController.setPinHelpButtonTitle(title: title)
    }
    
    func setNeedHelpButtonTitle(title : String) {
        pinViewController.setNeedHelpButtonTitle(title: title)
    }
    
    func setSubmitButtonTitle(title : String) {
        pinViewController.setSubmitButtonTitle(title: title)
    }

    func setIsPinInvalid(isPinInvalid : Bool) {
        pinViewController.setIsPinInvalid(isPinInvalid: isPinInvalid)
    }
    
    func setOnPinHelpButtonClick(_ onPinHelpButtonClick:@escaping ()->()) {
        pinViewController.setOnPinHelpButtonClick(onPinHelpButtonClick : onPinHelpButtonClick)
    }
    
    func setOnNeedHelpButtonClick(_ onNeedHelpButtonClick:@escaping ()->()) {
        pinViewController.setOnNeedHelpButtonClick(onNeedHelpButtonClick: onNeedHelpButtonClick)
    }
    
    func setOnSubmitButtonClick(_ onSubmitButtonClick:@escaping ()->()) {
        pinViewController.setOnSubmitButtonClick(onSubmitButtonClick: onSubmitButtonClick)
    }
    
    func hidePinHelpButton() {
        pinViewController.hidePinHelpButton()
    }
}
