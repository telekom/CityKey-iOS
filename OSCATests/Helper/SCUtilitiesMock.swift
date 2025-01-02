//
//  SCUtilitiesMock.swift
//  OSCATests
//
//  Created by Bhaskar N S on 22/07/22.
//  Copyright © 2022 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

@testable import OSCA
import UIKit

class SCUtilitiesMock: SCUtilityUsable {
    var tabIndex: Int?
    private(set) var dismissAnyPresentedControllerCalled: Bool = false
    init(tabIndex: Int? = nil) {
        self.tabIndex = tabIndex
    }
    func topViewController() -> UIViewController {
        return UIViewController()
    }
    
    func dismissAnyPresentedViewController(completion: @escaping (() -> Void)) {
        dismissAnyPresentedControllerCalled = true
        completion()
    }
    
    func dismissPresentedViewControllers(completion: @escaping (() -> Void?)) {
        completion()
    }
    
    func indexForServiceController() -> Int? {
        return tabIndex
    }
    
    func lockOrientation(_ orientation: UIInterfaceOrientationMask) {
        
    }
    
    func lockOrientation(_ orientation: UIInterfaceOrientationMask, andRotateTo rotateOrientation:UIInterfaceOrientation) {
        
    }
}
