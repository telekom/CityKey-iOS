//
//  UIViewController+OverlayDisplaying.swift
//  OSCA
//
//  Created by Michael on 19.05.20.
//  Copyright © 2020 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

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
