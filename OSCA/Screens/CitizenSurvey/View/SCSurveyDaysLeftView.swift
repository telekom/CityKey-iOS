/*
Created by Michael on 09.12.20.
Copyright © 2020 Deutsche Telekom AG - VTI Organization. All rights reserved.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    https://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
 
In accordance with Sections 4 and 6 of the License, the following exclusions apply:

    1. Trademarks & Logos – The names, logos, and trademarks of the Licensor are not covered by this License and may not be used without separate permission.
    2. Design Rights – Visual identities, UI/UX designs, and other graphical elements remain the property of their respective owners and are not licensed under the Apache License 2.0.
    3: Non-Coded Copyrights – Documentation, images, videos, and other non-software materials require separate authorization for use, modification, or distribution.

These elements are not considered part of the licensed Work or Derivative Works unless explicitly agreed otherwise. All elements must be altered, removed, or replaced before use or distribution. All rights to these materials are reserved, and Contributor accepts no liability for any infringing use. By using this repository, you agree to indemnify and hold harmless Contributor against any claims, costs, or damages arising from your use of the excluded elements.

SPDX-FileCopyrightText: 2025 Deutsche Telekom AG, Michael
SPDX-License-Identifier: Apache-2.0 AND LicenseRef-Deutsche-Telekom-Brand
License-Filename: LICENSES/Apache-2.0.txt LICENSES/LicenseRef-Deutsche-Telekom-Brand.txt
*/

import UIKit


class SCSurveyDaysLeftView: UIView {
        
    public var wholeCircleAnimationDuration: Double = 2
    
    public var lineBackgroundColor: UIColor = UIColor(named: "CLR_BORDER_COOLGRAY")!
    public var lineColor: UIColor = kColor_cityColor
    
    private var label : UILabel?
    
    private let foregroundLayer = CAShapeLayer()
    private let backgroundLayer = CAShapeLayer()
    
    private var radius: CGFloat {
        get{
            if self.frame.width < self.frame.height { return (self.frame.width - lineWidth)/2 }
            else { return (self.frame.height - lineWidth)/2 }
        }
    }
    
    private var pathCenter: CGPoint{
        get{ return self.convert(self.center, from:self.superview) }
    }

    private var lineWidth:CGFloat = 5 {
        didSet{
            foregroundLayer.lineWidth = lineWidth
            backgroundLayer.lineWidth = lineWidth
        }
    }
        
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setupView()

        self.setProgress(to: 0.5, daysLeft : 1)
    }

    private func setupView() {
        self.foregroundLayer.strokeColor = lineColor.cgColor
        drawBackgroundLayer()
        drawForegroundLayer()

        label = UILabel(frame: self.bounds)
        label!.textAlignment = .center
        label!.backgroundColor = .clear
        label!.numberOfLines = 0
        self.addSubview(label!)
        

    }

    func setProgress(to progressConstant: Double, daysLeft: Int) {
        foregroundLayer.strokeEnd = CGFloat(progressConstant)
        
        let daysStringSuffix = daysLeft == 1 ? LocalizationKeys.SCSurveyDaysLeftView.TAG.localized() : LocalizationKeys.SCSurveyDaysLeftView.cs002DaysLabel.localized()
        let daysString = String(format: "%02d", daysLeft) + "\n" + daysStringSuffix
        let leftDaysText = NSMutableAttributedString.init(string: daysString)
        let daysleftLength = String(format: "%02d", daysLeft).count

        // on smaller view sizes shrink the line spacing
        if (self.bounds.height < 80.0) {
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineSpacing = -20
            paragraphStyle.alignment = .center

            leftDaysText.addAttribute(.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, leftDaysText.length))
        }
        let textColor = UIColor(named: "CLR_BORDER_DARKGRAY")!
        leftDaysText.setAttributes([NSAttributedString.Key.font: UIFont.SystemFont.bold.forTextStyle(style: .body, size: 24.0, maxSize: 28),
                                    NSAttributedString.Key.foregroundColor: textColor],
                                   range: NSMakeRange(0, daysleftLength))

        leftDaysText.setAttributes([NSAttributedString.Key.font: UIFont.SystemFont.bold.forTextStyle(style: .body, size: 14.0, maxSize: 18),
                                    NSAttributedString.Key.foregroundColor: textColor],
                                   range: NSMakeRange(daysleftLength, (daysString.count - daysleftLength)))

        self.label?.attributedText = leftDaysText
    }
    
    private func drawBackgroundLayer(){
        let path = UIBezierPath(arcCenter: pathCenter, radius: self.radius, startAngle: 0, endAngle: 2*CGFloat.pi, clockwise: true)
        self.backgroundLayer.path = path.cgPath
        self.backgroundLayer.strokeColor = lineBackgroundColor.cgColor
        self.backgroundLayer.lineWidth = lineWidth
        self.backgroundLayer.fillColor = UIColor.clear.cgColor
        self.layer.addSublayer(backgroundLayer)
    }
    
    private func drawForegroundLayer(){
        
        let startAngle = (-CGFloat.pi/2)
        let endAngle = 2 * CGFloat.pi + startAngle
        
        let path = UIBezierPath(arcCenter: pathCenter, radius: self.radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
        
        foregroundLayer.lineCap = CAShapeLayerLineCap.round
        foregroundLayer.path = path.cgPath
        foregroundLayer.lineWidth = lineWidth
        foregroundLayer.fillColor = UIColor.clear.cgColor
        foregroundLayer.strokeColor = lineColor.cgColor
        foregroundLayer.strokeEnd = 0
        
        self.layer.addSublayer(foregroundLayer)
        
    }
    
    /*private func makeLabel(withText text: String) -> UILabel {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        label.text = text
        label.font = UIFont.systemFont(ofSize: labelSize)
        label.sizeToFit()
        label.center = pathCenter
        return label
    }*/
        
    //Layout Sublayers
   /* private var layoutDone = false
    override func layoutSublayers(of layer: CALayer) {
        if !layoutDone {
            let tempText = label.text
            setupView()
            label.text = tempText
            layoutDone = true
        }
    }*/
    
}
