/*
Created by Michael on 05.12.18.
Copyright © 2018 Michael. All rights reserved.

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

SPDX-FileCopyrightText: 2025 Deutsche Telekom AG, Copyright © 2018 Michael
SPDX-License-Identifier: Apache-2.0 AND LicenseRef-Deutsche-Telekom-Brand
License-Filename: LICENSES/Apache-2.0.txt LICENSES/LicenseRef-Deutsche-Telekom-Brand.txt
*/

import UIKit

enum SCCustomButtonState {
    case disabled
    case normal
    case progress
}

class SCCustomButton: UIButton {
    
    let activityIndicator = UIActivityIndicatorView(style: .white)
    
    var textColor = UIColor(named: "CLR_LABEL_TEXT_WHITE")!
    
    var normalBackgroundColor: UIColor?{
        didSet {
            backgroundColor = normalBackgroundColor
        }
    }
    
    var btnState: SCCustomButtonState = .normal{
        didSet {
            
            switch btnState {
            case .disabled:
                self.isEnabled = false
                if self.activityIndicator.superview != nil{
                    self.activityIndicator.stopAnimating()
                    self.activityIndicator.removeFromSuperview()
                }
                self.setTitleColor(self.textColor, for: .normal)
                self.alpha = 0.5
            case .progress:
                self.isEnabled = false
                if self.activityIndicator.superview == nil{
                    self.addSubview(self.activityIndicator)
                }
                self.activityIndicator.startAnimating()
                self.activityIndicator.frame = self.bounds
                self.setTitleColor(self.normalBackgroundColor, for: .normal)
                self.alpha = 1.0
            default:
                self.isEnabled = true
                if self.activityIndicator.superview != nil{
                    self.activityIndicator.stopAnimating()
                    self.activityIndicator.removeFromSuperview()
                }
                self.setTitleColor(self.textColor, for: .normal)
                self.alpha = 1.0
            }
            backgroundColor = normalBackgroundColor
        }
    }

    var highlightedBackgroundColor: UIColor?
    
    override open var isHighlighted: Bool {
        didSet {
            backgroundColor = isHighlighted ? self.highlightedBackgroundColor: self.normalBackgroundColor
        }
    }

    func customizeCityColorStyle() {
        self.layer.cornerRadius = 4.0
        self.clipsToBounds = true
        self.backgroundColor = kColor_cityColor
        self.normalBackgroundColor = kColor_cityColor
        self.highlightedBackgroundColor = kColor_cityColor.darker()
        self.textColor = UIColor(named: "CLR_LABEL_TEXT_WHITE")!
        self.setTitleColor(self.textColor, for: .normal)
        self.btnState = .normal
    }

    func customizeBlueStyle() {
        self.layer.cornerRadius = 4.0
        self.clipsToBounds = true
        self.backgroundColor = UIColor(named: "CLR_BUTTON_BLUE_BCKGRND")
        self.normalBackgroundColor = UIColor(named: "CLR_BUTTON_BLUE_BCKGRND")
        self.highlightedBackgroundColor = UIColor(named: "CLR_BUTTON_BLUE_BCKGRND")?.darker()
        self.textColor = UIColor(named: "CLR_LABEL_TEXT_WHITE")!
        self.setTitleColor(self.textColor, for: .normal)
        self.btnState = .normal
    }

    func customizeAusweisBlueStyle() {
        self.layer.cornerRadius = 4.0
        self.clipsToBounds = true
        self.backgroundColor = UIColor(named: "CLR_AUSWEIS_BLUE")
        self.normalBackgroundColor = UIColor(named: "CLR_AUSWEIS_BLUE")
        self.highlightedBackgroundColor = UIColor(named: "CLR_AUSWEIS_BLUE")?.darker()
        self.textColor = UIColor(named: "CLR_LABEL_TEXT_WHITE")!
        self.setTitleColor(self.textColor, for: .normal)
        self.btnState = .normal
    }
    
    func customizeBlueStyleSolidLight() {
        self.layer.borderWidth = 1.0
        self.layer.borderColor =  UIColor(named: "CLR_BUTTON_BLUE_BCKGRND")!.cgColor
        self.layer.cornerRadius = 4.0
        self.clipsToBounds = true
        self.normalBackgroundColor = UIColor(named: "CLR_BCKGRND")!
        self.highlightedBackgroundColor = UIColor(named: "CLR_BCKGRND")!.withAlphaComponent(0.15)
        self.textColor = UIColor(named: "CLR_BUTTON_BLUE_BCKGRND")!
        self.setTitleColor(self.textColor, for: .normal)
        self.btnState = .normal
        activityIndicator.color = UIColor(named: "CLR_BUTTON_BLUE_BCKGRND")
    }
    
    func customizeBlueStyleLight() {
        self.layer.borderWidth = 1.0
        self.layer.borderColor =  UIColor(named: "CLR_BUTTON_BLUE_BCKGRND")!.cgColor
        self.layer.cornerRadius = 4.0
        self.clipsToBounds = true
        self.normalBackgroundColor = .clear
        self.highlightedBackgroundColor = UIColor(named: "CLR_BCKGRND")!.withAlphaComponent(0.15)
        self.textColor = UIColor(named: "CLR_BUTTON_BLUE_BCKGRND")!
        self.setTitleColor(self.textColor, for: .normal)
        self.btnState = .normal
        activityIndicator.color = UIColor(named: "CLR_BUTTON_BLUE_BCKGRND")
    }

    func customizeWhiteStyle() {
        self.layer.borderWidth = 1.0
        self.layer.borderColor = UIColor(named: "CLR_BUTTON_BORDER_WHITE")!.cgColor
        self.layer.cornerRadius = 4.0
        self.clipsToBounds = true
        self.normalBackgroundColor = UIColor(named: "CLR_BUTTON_WHITE_BCKGRND")
        self.highlightedBackgroundColor = UIColor(named: "CLR_BUTTON_WHITE_BCKGRND")?.darker()
        self.textColor = UIColor(named: "CLR_LABEL_TEXT_WHITE")!
        self.setTitleColor(self.textColor, for: .normal)
        self.btnState = .normal
    }

    func customizeWhiteStyleLight() {
        self.layer.borderWidth = 1.0
        self.layer.borderColor = UIColor(named: "CLR_BUTTON_BORDER_WHITE")!.cgColor
        self.layer.cornerRadius = 4.0
        self.clipsToBounds = true
        self.normalBackgroundColor = .clear
        self.highlightedBackgroundColor = UIColor(named: "CLR_BCKGRND")!.withAlphaComponent(0.15)
        self.textColor =  UIColor(named: "CLR_LABEL_TEXT_WHITE")!
        self.setTitleColor(self.textColor, for: .normal)
        self.btnState = .normal
    }

    func customizeCityColorStyleLight() {
        self.layer.borderWidth = 1.0
        self.layer.borderColor = kColor_cityColor.cgColor
        self.layer.cornerRadius = 4.0
        self.clipsToBounds = true
        self.normalBackgroundColor = .clear
        self.highlightedBackgroundColor = UIColor(named: "CLR_BCKGRND")!.withAlphaComponent(0.15)
        self.textColor =  kColor_cityColor
        self.setTitleColor(self.textColor, for: .normal)
        self.btnState = .normal
    }

    func customizeBlueStyleNoBorder() {
        self.clipsToBounds = true
        self.normalBackgroundColor = .clear
        self.highlightedBackgroundColor = UIColor(named: "CLR_BCKGRND")!.withAlphaComponent(0.15)
        self.textColor = UIColor(named: "CLR_BUTTON_BLUE_BCKGRND")!
        self.setTitleColor(self.textColor, for: .normal)
        self.btnState = .normal
        activityIndicator.color = UIColor(named: "CLR_BUTTON_BLUE_BCKGRND")
    }
    
    /// This method is used to set the alpha and userInteraction flag.
    /// IsEnabled flag wont work with layer
    /// - Parameter isEnable: Bool value either true / false
    func set(isEnable: Bool) {
        isUserInteractionEnabled = isEnable
        alpha = isEnable ? 1.0 : 0.3
    }
}
