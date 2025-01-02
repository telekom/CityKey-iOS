//
//  UIBezierPath+convenienceInit.swift
//  SmartCity
//
//  Created by Robert Swoboda - Telekom on 09.05.19.
//  Copyright © 2019 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import UIKit

extension UIBezierPath {
    convenience init(circleSegmentCenter center:CGPoint, radius:CGFloat, startAngle:Degree, endAngle: Degree, clockwise: Bool)
    {
        self.init()
        self.move(to: CGPoint(x: center.x, y: center.y))
        self.addArc(withCenter: center, radius:radius, startAngle:startAngle.radians(), endAngle: endAngle.radians(), clockwise:clockwise)
        self.close()
    }
}

