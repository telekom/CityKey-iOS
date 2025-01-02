//
//  DispatchQueue+Extension.swift
//  OSCA
//
//  Created by Bhaskar N S on 27/07/22.
//  Copyright © 2022 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import Foundation

protocol Dispatching: AnyObject {
    func async(block: @escaping () -> Void)
}

extension DispatchQueue: Dispatching {
    func async(block: @escaping () -> Void) {
        async(group: nil, execute: block)
    }
}
