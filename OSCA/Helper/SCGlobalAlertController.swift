//
//  SCGlobalAlertController.swift
//  SmartCity
//
//  Created by Michael on 16.12.19.
//  Copyright © 2019 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import UIKit
  
class SCGlobalAlertController: UIAlertController {
      
    var globalPresentationWindow: UIWindow?
      
    func presentGlobally(animated: Bool, completion: (() -> Void)?) {
        globalPresentationWindow = UIWindow(frame: UIScreen.main.bounds)
        globalPresentationWindow?.rootViewController = UIViewController()
        globalPresentationWindow?.windowLevel = UIWindow.Level.alert + 1
        globalPresentationWindow?.backgroundColor = .clear
        globalPresentationWindow?.makeKeyAndVisible()
        globalPresentationWindow?.rootViewController?.present(self, animated: animated, completion: completion)
    }
      
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        globalPresentationWindow?.isHidden = true
        globalPresentationWindow = nil
    }
  
    func show() {
        self.presentGlobally(animated: true, completion: nil)
    }

}
