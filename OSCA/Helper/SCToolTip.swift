/*
Created by Michael on 08.05.20.
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
import EasyTipView

class SCToolTip: NSObject {

    weak var tipView: EasyTipView?
    
    func showToolTip(forItem item: UIBarItem, text: String){
        let tip = EasyTipView(text: "h_001_home_tooltip_switch_location".localized(), preferences: self.preferences(), delegate: self)
        tip.show(forItem: item)
        self.tipView = tip
    }

    func showToolTip(forView view: UIView, text: String){
        let tip = EasyTipView(text: "h_001_home_tooltip_switch_location".localized(), preferences: self.preferences(), delegate: self)
        tip.show(forView: view)
        self.tipView = tip
    }

    func hideToolTip(){
        self.tipView?.dismiss(withCompletion: {
        })
    }

    private func preferences() -> EasyTipView.Preferences{
        var preferences = EasyTipView.Preferences()
        preferences.drawing.font = UIFont.systemFont(ofSize: 15.0)
        preferences.drawing.foregroundColor = UIColor(named: "CLR_LABEL_TEXT_FULL_BLACK")!
        preferences.drawing.backgroundColor = UIColor(named: "CLR_TOOLTIP_BCKGRND")!.withAlphaComponent(0.8)
        preferences.drawing.arrowPosition = EasyTipView.ArrowPosition.top
        preferences.drawing.cornerRadius = 4.0
        preferences.drawing.arrowHeight = 9.0
        preferences.drawing.arrowWidth = 12.0

        preferences.drawing.shadowColor = UIColor.black
        preferences.drawing.shadowRadius = 2
        preferences.drawing.shadowOpacity = 0.75
        preferences.drawing.shadowOffset = CGSize(width: 0.0, height: 3.0)

        preferences.positioning.bubbleInsets = getBubbleInsets()
        preferences.positioning.contentInsets = UIEdgeInsets(top: 12.0, left: 12.0, bottom: 10.0, right: 10.0)

        preferences.animating.showInitialAlpha = 0
        preferences.animating.showInitialTransform =  CGAffineTransform.identity
        preferences.animating.showFinalTransform =  CGAffineTransform(scaleX: 1, y: 1)
        preferences.animating.dismissTransform =  CGAffineTransform(scaleX: 1, y: 1)
        
        preferences.animating.dismissFinalAlpha = 0
        preferences.animating.showDuration = 1.5
        preferences.animating.dismissDuration = 1.5
        
        return preferences
    }

    private func getBubbleInsets() -> UIEdgeInsets {
        return UIDevice.current.orientation.isLandscape ?
        UIEdgeInsets(top: 0, left: 50.0, bottom: 0, right: 1.0) : UIEdgeInsets(top: 1.0, left: 15, bottom: 1.0, right: 1.0)
    }
}

// MARK: - tooltip delegate
extension SCToolTip : EasyTipViewDelegate {
    func easyTipViewDidDismiss(_ tipView: EasyTipView) {
    
    }

    func easyTipViewDidTap(_ tipView: EasyTipView) {
        
    }

}

