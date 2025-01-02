//
//  UIViewController+Dismiss.swift
//  SmartCity
//
//  Created by Alexander Lichius on 19.11.19.
//  Copyright © 2019 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import Foundation
import UIKit

protocol Dismissable {
    func dismiss(sender: AnyObject)
}

extension Dismissable where Self: UIViewController {
    func dismiss() {
        self.parent?.dismiss(animated: true, completion: nil)
    }
}
