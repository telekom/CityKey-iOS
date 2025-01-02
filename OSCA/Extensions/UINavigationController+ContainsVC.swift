//
//  UINavigationController+ContainsVC.swift
//  OSCA
//
//  Created by Harshada Deshmukh on 04/02/21.
//  Copyright © 2021 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import UIKit

extension UINavigationController {
    public func hasViewController(ofKind kind: AnyClass) -> UIViewController? {
        return self.viewControllers.first(where: {$0.isKind(of: kind)})
    }

    /// Given the kind of a (UIViewController subclass),
    /// removes any matching instances from self's
    /// viewControllers array.

    func removeAnyViewControllers(ofKind kind: AnyClass){
        self.viewControllers = self.viewControllers.filter { !$0.isKind(of: kind)}
    }

    /// Given the kind of a (UIViewController subclass),
    /// returns true if self's viewControllers array contains at
    /// least one matching instance.

    func containsViewController(ofKind kind: AnyClass) -> Bool{
        return self.viewControllers.contains(where: { $0.isKind(of: kind) })
    }
}
