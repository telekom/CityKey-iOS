//
//  SCRegistrationPWDCheckVC.swift
//  SmartCity
//
//  Created by Michael on 06.03.19.
//  Copyright © 2019 Michael. All rights reserved.
//

import UIKit

class SCRegistrationPWDCheckVC: UIViewController {

    
    @IBOutlet weak var pwdCheckTopLabel: UILabel!
    @IBOutlet weak var pwdCheckDetailLabel: SCTopAlignLabel!
    @IBOutlet weak var pwdCheckBar: UIView!
    @IBOutlet weak var pwdCheckDetailLabelHeight: NSLayoutConstraint!
    
    let progressBar = UIView()
    var progressBarMaxWidth:CGFloat {
        return self.pwdCheckBar.bounds.size.width - 2 * self.pwdCheckBar.layer.borderWidth
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupAccessibilityIDs()
        self.setupAccessibility()
        
        self.pwdCheckTopLabel.adaptFontSize()
        self.pwdCheckDetailLabel.adaptFontSize()

        self.pwdCheckTopLabel.text = "r_001_registration_p_005_profile_password_strength_label".localized()
        self.refreshWith(charCount : 0, minCharReached: false, symbolAvailable: false, digitAvailable: false)
        
        self.pwdCheckBar.layer.borderWidth = 1.0
        self.pwdCheckBar.layer.borderColor = UIColor(named: "CLR_BORDER_SILVERGRAY")!.cgColor

        self.pwdCheckBar.addSubview(progressBar)
        
        self.progressBar.frame = CGRect(x: self.pwdCheckBar.layer.borderWidth, y: self.pwdCheckBar.layer.borderWidth, width: 0.0, height: pwdCheckBar.bounds.size.height - 2 * self.pwdCheckBar.layer.borderWidth)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.pwdCheckDetailLabelHeight.constant = self.pwdCheckDetailLabel.intrinsicContentSize.height
        self.view.setNeedsLayout()
        super.viewDidAppear(animated)
    }
    
    // setup accessibility ids for automated testing
    private func setupAccessibilityIDs(){
        self.pwdCheckTopLabel.accessibilityIdentifier = "lbl_top"
        self.pwdCheckDetailLabel.accessibilityIdentifier = "lbl_detail"
        self.navigationController?.navigationBar.accessibilityIdentifier = "nvbr"
        self.navigationItem.titleView?.accessibilityIdentifier = "nvitem_title"

    }
    
    private func setupAccessibility(){
        self.pwdCheckTopLabel.accessibilityLabel = self.pwdCheckTopLabel.text
        self.pwdCheckTopLabel.accessibilityTraits = .staticText
        self.pwdCheckTopLabel.accessibilityLanguage = SCUtilities.preferredContentLanguage()
//        self.pwdCheckDetailLabel.accessibilityLabel = self.pwdCheckDetailLabel.text
//        self.pwdCheckDetailLabel.accessibilityTraits = .staticText
//        self.pwdCheckDetailLabel.accessibilityLanguage = SCUtilities.preferredContentLanguage()
    }

    func refreshWith(charCount: Int,  minCharReached : Bool, symbolAvailable : Bool, digitAvailable: Bool, showRedLineAnyway :Bool = false) {
        let hintPasswordStrength = "r_001_registration_hint_password_strength".localized().replacingOccurrences(of: "%s", with: "")
        let checktxt = hintPasswordStrength + " " + checkText()
        let attrString = NSMutableAttributedString(string: checktxt)
        self.pwdCheckDetailLabel.attributedText = formatCheckText(checkText: attrString, minCharReached: minCharReached, symbolAvailable: symbolAvailable, digitAvailable: digitAvailable)
        self.pwdCheckDetailLabelHeight.constant = self.pwdCheckDetailLabel.intrinsicContentSize.height
        
        if charCount > 0 {
            formatProgressBar(charcount: charCount, minCharReached: minCharReached, symbolAvailable: symbolAvailable, digitAvailable: digitAvailable)
        } else {
            self.progressBar.frame.size.width =  0.0
        }
        if showRedLineAnyway {
            self.progressBar.backgroundColor = UIColor(named: "CLR_LABEL_TEXT_RED")!
        }
        self.view.setNeedsLayout()
    }
    
    private func checkText() -> String {
        return "r_001_registration_p_005_profile_password_strength_hint_min_8_chars".localized() + ", " + "r_001_registration_p_005_profile_password_strength_error_min_1_symbol".localized() + ", " + "r_001_registration_p_005_profile_password_strength_error_min_1_digit".localized()
    }
    
    private func formatCheckText(checkText: NSMutableAttributedString, minCharReached: Bool, symbolAvailable: Bool, digitAvailable: Bool) -> NSMutableAttributedString {
        if minCharReached {
            _ = checkText.setAsStrikeThrough(textToFind:"r_001_registration_p_005_profile_password_strength_hint_min_8_chars".localized())
        }
        
        if symbolAvailable {
            _ = checkText.setAsStrikeThrough(textToFind:"r_001_registration_p_005_profile_password_strength_error_min_1_symbol".localized())
        }
        
        if digitAvailable {
            _ = checkText.setAsStrikeThrough(textToFind: "r_001_registration_p_005_profile_password_strength_error_min_1_digit".localized())
        }
        
        return checkText
    }
    
    private func formatProgressBar(charcount: Int, minCharReached: Bool, symbolAvailable: Bool, digitAvailable: Bool) {
        var restrictionMet: Int = 0
        if charcount > 0 {
            restrictionMet += 1
        }
        
        if minCharReached {
            restrictionMet += 1
        }
        
        if symbolAvailable {
            restrictionMet += 1
        }
        
        if digitAvailable {
            restrictionMet += 1
        }
        
        self.progressBar.frame.size.width =  floor( CGFloat(restrictionMet) * self.progressBarMaxWidth / 4.0 )
        if restrictionMet == 4 {
            self.progressBar.backgroundColor = UIColor(named: "CLR_LABEL_TEXT_GREEN")!
        } else {
            self.progressBar.backgroundColor = UIColor(named: "CLR_LABEL_TEXT_RED")!
        }
        
        
        
    }
}
