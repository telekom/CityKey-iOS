//
//  UIBarButtonItem+HideNavMenu.swift
//  OSCA
//
//  Created by Bharat Jagtap on 09/09/21.
//  Copyright © 2021 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import Foundation
import UIKit


enum SCBarButtonItemMenuExtension {
    static func swizzle() {
        if #available(iOS 14.0, *) {
            exchange(
                #selector(setter: UIBarButtonItem.menu),
                with: #selector(setter: UIBarButtonItem.swizzledMenu),
                in: UIBarButtonItem.self
            )
        }
    }
    
    private static func exchange(
        _ selector1: Selector,
        with selector2: Selector,
        in cls: AnyClass
    ) {
        guard
            let method = class_getInstanceMethod(
                cls,
                selector1
            ),
            let swizzled = class_getInstanceMethod(
                cls,
                selector2
            )
        else {
            return
        }
        method_exchangeImplementations(method, swizzled)
    }
}

@available(iOS 14.0, *)
private extension UIBarButtonItem {
    
    @objc dynamic var swizzledMenu: UIMenu? {
        get {
            nil
        }
        set {
            
        }
    }
}
