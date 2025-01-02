//
//  CGFloat+radians.swift
//  SmartCity
//
//  Created by Robert Swoboda - Telekom on 09.05.19.
//  Copyright © 2019 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import UIKit

typealias Degree = CGFloat

extension Degree {
    func radians() -> CGFloat {
        let b = CGFloat(Double.pi) * (self/180)
        return b
    }
}
