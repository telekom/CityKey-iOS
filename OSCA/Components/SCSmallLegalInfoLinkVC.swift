//
//  SCSmallLegalInfoLinkVC.swift
//  SmartCity
//
//  Created by Michael on 14.04.19.
//  Copyright © 2019 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import UIKit

enum LinkStyle: Int {
    case dark = 0
    case light = 1
}
protocol SCSmallLegalInfoLinkVCDelegate: AnyObject {
    func impressumButtonWasPressed()
    func dataPrivacyButtonWasPressed()
}

class SCSmallLegalInfoLinkVC: UIViewController {

    weak var linkDelegate: SCSmallLegalInfoLinkVCDelegate?
    
    @IBOutlet weak var impressumBtn: UIButton!
    @IBOutlet weak var dataPrivacyBtn: UIButton!
    
    var linkStyle : LinkStyle = .dark {
        didSet {
            self.refreshStyle()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.refreshStyle()
        self.impressumBtn.setTitle("p_001_profile_btn_imprint".localized(), for: .normal)
        self.impressumBtn.titleLabel?.adaptFontSize()
        self.dataPrivacyBtn.setTitle("l_001_login_btn_privacy_short".localized(), for: .normal)
        self.dataPrivacyBtn.titleLabel?.adaptFontSize()
        self.setupAccessibilityIDs()
        self.setupAccessibility()
    }
    
    // setup accessibility ids for automated testing
    private func setupAccessibilityIDs(){
        self.impressumBtn.accessibilityIdentifier = "btn_impressum"
        self.dataPrivacyBtn.accessibilityIdentifier = "btn_data_privacy"
    }

    private func setupAccessibility(){
        self.impressumBtn.accessibilityTraits = .button
        self.impressumBtn.accessibilityLabel = "p_001_profile_btn_imprint".localized()
        self.impressumBtn.accessibilityLanguage = SCUtilities.preferredContentLanguage()
        self.dataPrivacyBtn.accessibilityTraits = .button
        self.dataPrivacyBtn.accessibilityLabel = "l_001_login_btn_privacy_short".localized()
        self.dataPrivacyBtn.accessibilityLanguage = SCUtilities.preferredContentLanguage()
     }

    private func refreshStyle() {
        if self.dataPrivacyBtn != nil && self.impressumBtn != nil{
            switch linkStyle {
            case .dark:
                impressumBtn.setTitleColor(UIColor(named: "CLR_LABEL_TEXT_BLACK")!, for: .normal)
                impressumBtn.setTitleColor(UIColor(named: "CLR_LABEL_TEXT_BLACK")!, for: .highlighted)
                dataPrivacyBtn.setTitleColor(UIColor(named: "CLR_LABEL_TEXT_BLACK")!, for: .normal)
                dataPrivacyBtn.setTitleColor(UIColor(named: "CLR_LABEL_TEXT_BLACK")!, for: .highlighted)
                dataPrivacyBtn.setImage(UIImage(named: "icon_datenschutz_dark"), for: .normal)
            case .light:
                impressumBtn.setTitleColor(UIColor(white: 1.0, alpha: 0.75), for: .normal)
                impressumBtn.setTitleColor(UIColor(white: 1.0, alpha: 1.0), for: .highlighted)
                dataPrivacyBtn.setTitleColor(UIColor(white: 1.0, alpha: 0.75), for: .normal)
                dataPrivacyBtn.setTitleColor(UIColor(white: 1.0, alpha: 1.0), for: .highlighted)
                dataPrivacyBtn.setImage(UIImage(named: "icon_datenschutz_light"), for: .normal)
                dataPrivacyBtn.setImage(UIImage(named: "icon_datenschutz_light"), for: .highlighted)
            }
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    @IBAction func impressumBtnWasPressed(_ sender: Any) {
        self.linkDelegate?.impressumButtonWasPressed()
    }
    
    @IBAction func dataPrivacyBtnWasPressed(_ sender: Any) {
        self.linkDelegate?.dataPrivacyButtonWasPressed()
    }
}
