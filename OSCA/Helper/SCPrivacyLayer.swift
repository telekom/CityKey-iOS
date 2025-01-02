//
//  SCPrivacyLayer.swift
//  SmartCity
//
//  Created by Michael on 08.04.19.
//  Copyright © 2019 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import UIKit

class SCPrivacyLayer: NSObject {

    private var displayed = false
    var blurView: UIVisualEffectView?
    var cityKeyLogo: UIImageView = {
        let logo = UIImageView()
        logo.translatesAutoresizingMaskIntoConstraints = false
        logo.image = UIImage(named: "splash-logo")
        return logo
    }()
    
    private var privacyController = UIStoryboard(name: "LaunchScreen", bundle: nil).instantiateInitialViewController()!
    
    func displayPrivacyLayer(_ show : Bool, isBlurred: Bool = false) {
        if blurView != nil && displayed == true {
            removePrivacyLayer()
        }
        
        if show && !self.displayed {
            if let window = UIApplication.shared.keyWindow {
                window.windowLevel = .normal
                if isBlurred {
                    if blurView == nil {
                        let blurEffect = UIBlurEffect(style: getBlurEffect())
                        blurView = UIVisualEffectView(effect: blurEffect)
                        blurView?.frame = UIScreen.main.bounds
                        window.windowLevel = .normal
                        blurView?.contentView.addSubview(cityKeyLogo)
                        cityKeyLogo.widthAnchor.constraint(equalToConstant: 220).isActive = true
                        cityKeyLogo.heightAnchor.constraint(equalToConstant: 220).isActive = true
                        cityKeyLogo.topAnchor.constraint(equalTo: blurView!.contentView.topAnchor, constant: 158).isActive = true
                        cityKeyLogo.centerXAnchor.constraint(equalTo: blurView!.contentView.centerXAnchor).isActive = true
                        window.addSubview(blurView!)
                        self.displayed = true
                    }
                } else {
                    window.addSubview(privacyController.view)
                }
                
                //window.bringSubviewToFront(privacyController.view)
                window.makeKeyAndVisible()
                self.displayed = true
            }
        }
        
        if !show && self.displayed{
            removePrivacyLayer()
        }
    }

    private func getBlurEffect() -> UIBlurEffect.Style {
        if #available(iOS 13.0, *) {
            if UITraitCollection.current.userInterfaceStyle == .dark {
                return .dark
            }
            else {
                return .prominent
            }
        } else {
            return .dark
        }
    }

    private func removePrivacyLayer() {
        if let window = UIApplication.shared.keyWindow {
            // remove splash view when we become active
            self.privacyController.view.removeFromSuperview()
            blurView?.removeFromSuperview()
            window.windowLevel = .normal
            blurView = nil
            self.displayed = false
        }
    }
}
