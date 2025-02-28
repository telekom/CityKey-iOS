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

extension UIViewController {

    func showActivityOverlay(on view: UIView, hideActivityIndicator: Bool = false, title : String? = nil, backColor: UIColor? = nil){

        if !self.isOverlayAlreadyVisible(GlobalConstants.kOverlayActivityViewTag, on: view){

            self.hideOverlay(on: view)

            let overlay = SCStatusOverlayView.instantiate()
            overlay.activityIndicator.color = UIColor(named: "CLR_ICON_TINT_BLACK") ?? UIColor.darkGray

            overlay.frame = view.bounds

            overlay.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            overlay.translatesAutoresizingMaskIntoConstraints = true

            overlay.accessibilityViewIsModal = true
            overlay.backgroundColor = (backColor != nil) ? backColor : view.backgroundColor
            overlay.tag = GlobalConstants.kOverlayActivityViewTag
            view.addSubview(overlay)
            overlay.showActivity(title: title)
            if hideActivityIndicator {
                overlay.hideActivityIndicator()
            }
        }
    }

    func showActivityOverlay(on view: UIView, title : String? = nil, backColor: UIColor? = nil){
        
        if !self.isOverlayAlreadyVisible(GlobalConstants.kOverlayActivityViewTag, on: view){
            
            self.hideOverlay(on: view)
            
            let overlay = SCStatusOverlayView.instantiate()
            overlay.activityIndicator.color = UIColor(named: "CLR_ICON_TINT_BLACK") ?? UIColor.darkGray
                
            overlay.frame = view.bounds
            
            overlay.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            overlay.translatesAutoresizingMaskIntoConstraints = true
            
            overlay.accessibilityViewIsModal = true
            overlay.backgroundColor = (backColor != nil) ? backColor : view.backgroundColor
            overlay.tag = GlobalConstants.kOverlayActivityViewTag
            view.addSubview(overlay)

            overlay.showActivity(title: title)
        }
    }
    
    func showText(on view: UIView, text : String, title: String?, textAlignment:NSTextAlignment, btnTitle: String, btnImage: UIImage, btnColor: UIColor?, btnAction : (() -> Void)? = nil, backColor: UIColor? = nil){
        if !self.isOverlayAlreadyVisible(GlobalConstants.kOverlayErrorViewTag, on: view){
            
            self.hideOverlay(on: view)
            
            let overlay = SCStatusOverlayView.instantiate()

            overlay.frame = view.bounds
            
            overlay.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            overlay.translatesAutoresizingMaskIntoConstraints = true
            
            overlay.backgroundColor = (backColor != nil) ? backColor : view.backgroundColor
            overlay.tag = GlobalConstants.kOverlayErrorViewTag
            view.addSubview(overlay)

            overlay.accessibilityViewIsModal = true

            overlay.showText(text, title: title, textAlignment: textAlignment, btnTitle: btnTitle, btnImage: btnImage, btnColor: btnColor, btnAction : btnAction)
        }
    }
    
    func showText(on view: UIView, text : String, title: String?, textAlignment:NSTextAlignment, backColor: UIColor? = nil){
        if !self.isOverlayAlreadyVisible(GlobalConstants.kOverlayErrorViewTag, on: view){
            
            self.hideOverlay(on: view)
            
            let overlay = SCStatusOverlayView.instantiate()

            overlay.frame = view.bounds
            
            overlay.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            overlay.translatesAutoresizingMaskIntoConstraints = true
            
            overlay.accessibilityViewIsModal = true
            overlay.backgroundColor = (backColor != nil) ? backColor : view.backgroundColor
            overlay.tag = GlobalConstants.kOverlayErrorViewTag
            view.addSubview(overlay)

            overlay.showText(text, title: title, textAlignment: textAlignment)
        }
    }


    func hideOverlay(on view: UIView){
        for subview in view.subviews {
            let tag = subview.tag
            
            if tag == GlobalConstants.kOverlayActivityViewTag || tag == GlobalConstants.kOverlayErrorViewTag || tag == GlobalConstants.kOverlayNoDataViewTag{
                subview.removeFromSuperview()
            }
        }
    }

    private func isOverlayAlreadyVisible(_ overlayTag : Int, on view: UIView) -> Bool{
        for subview in view.subviews {
            if subview.tag == overlayTag{
                return true
            }
        }
        return false
    }

}
