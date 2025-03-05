/*
Created by Bharat Jagtap on 01/03/21.
Copyright © 2021 Deutsche Telekom AG - VTI Organization. All rights reserved.

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

SPDX-FileCopyrightText: 2025 Deutsche Telekom AG, Bharat Jagtap
SPDX-License-Identifier: Apache-2.0 AND LicenseRef-Deutsche-Telekom-Brand
License-Filename: LICENSES/Apache-2.0.txt LICENSES/LicenseRef-Deutsche-Telekom-Brand.txt
*/

import UIKit
/**
 pin dots view that takes care of show and hide of the PIN that user enters.
 */
class SCPinView: UIView {
    
    /// if the current pin is invalid , set this to true
    public var isInvalid : Bool = false {
        didSet { reload() }
    }
    /// toggles the visibility of the pin
    public var isPinVisible : Bool = false {
        didSet { reload() }
    }
    /// number of digits for the pin , default is 6
    public var numberOfDigits = 6 {
        didSet { reload() }
    }
    /// digits array entered by the user currently
    var digits : [Character] = [Character]()
    
    // returns the pin entered as a string value
    public var pin : String {
        get {
            return String(digits)
        }
        set {
            digits = Array(newValue)
            reload()
        }
    }
    
    private var stackView : UIStackView!
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadView()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadView()
    }
    
    func loadView() {
        self.isAccessibilityElement = true
        reload()
    }
    
    private func reload() {
        
        var arrangedViews : [UIView]? = self.subviews
        for v in arrangedViews! { v.removeFromSuperview() }
        arrangedViews = nil
        
        stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stackView)
        
        self.addConstraint(NSLayoutConstraint(item: stackView!, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1.0, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: stackView!, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: stackView!, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1.0, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: stackView!, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1.0, constant: 0))
        
        stackView.axis = .horizontal
        stackView.distribution = .equalSpacing
        stackView.alignment = .center
        stackView.spacing = 15.0
        
        isPinVisible ? loadVisiblePIN() : loadInvisiblePIN()
    }
    
    private func loadVisiblePIN() {
        
        for i in 0..<numberOfDigits {
            
            let pinDigit = PinDigitView()
            pinDigit.frame = CGRect()
            pinDigit.translatesAutoresizingMaskIntoConstraints = false
            
            pinDigit.addConstraint(NSLayoutConstraint(item: pinDigit, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 20))
            pinDigit.addConstraint(NSLayoutConstraint(item: pinDigit, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 40))
            
            if digits.indices.contains(i) {
                pinDigit.text = String(digits[i])
            } else {
                pinDigit.text = ""
            }
            
            pinDigit.digitColor = isInvalid ? UIColor.red : UIColor.labelTextBlackCLR
            stackView.addArrangedSubview(pinDigit)
        }
    }
    
    private func loadInvisiblePIN()  {
        
        for i in 0..<numberOfDigits {
            
            let pinDot = PinDotView()
            pinDot.size = 5
            pinDot.frame = CGRect()
            pinDot.translatesAutoresizingMaskIntoConstraints = false
            
            pinDot.addConstraint(NSLayoutConstraint(item: pinDot, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 20))
            pinDot.addConstraint(NSLayoutConstraint(item: pinDot, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 40))
            
            pinDot.borderColor = isInvalid ? UIColor.systemRed : ( UIColor(named: "CLR_AUSWEIS_BLUE") ?? UIColor.systemBlue )
            
            if digits.indices.contains(i) {
                
                pinDot.dotColor = isInvalid ? UIColor.systemRed : ( UIColor(named: "CLR_AUSWEIS_BLUE") ?? UIColor.systemBlue )
            }

            stackView.addArrangedSubview(pinDot)
        }
    }
    
    /// adds a digit to the current PIN
    func addDigit(digit : Character) {
        if digit.isNumber && digits.count < numberOfDigits {
            digits.append(digit)
            reload()
            
            var pinAccessibleValue = ""
            for digit in self.pin {
                pinAccessibleValue += "\(digit) "
            }
            self.accessibilityLabel = pinAccessibleValue
        }
    }
    
    /// remvoes the last entered digit from the PIN
    func removeLast() {
        if digits.count == 0 { return }
        digits.removeLast()
        isInvalid = false
        reload()
        self.accessibilityLabel = "Entered PIN is \(self.pin)"
    }
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: numberOfDigits * 30, height: 30)
    }
}

/**
 The dot view for each digit entered as a part of the PIN
 */
class PinDotView : UIView {
    
    var circle : UIView = UIView()
    /// dot color
    var dotColor : UIColor = UIColor.clear {
        didSet {
            setNeedsDisplay()
        }
    }
    /// dot Size
    var size : Float = 10.0 {
        didSet {
            setNeedsDisplay()
        }
    }
    /// border color of the dot, mostly usefull for the dot used to represent the empyt digit
    var borderColor : UIColor = UIColor(named: "CLR_AUSWEIS_BLUE") ?? UIColor.systemBlue {
        didSet {
            setNeedsDisplay()
        }
    }
    ///border width of the dot , mostly usefull for the dot used to represent the empyt digit
    var borderWidth : Float = 1.0 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        let circlePath = UIBezierPath(
            arcCenter: CGPoint(x: rect.midX , y: rect.midY ),
            radius: CGFloat(size),
            startAngle: CGFloat(0),
            endAngle:CGFloat(Double.pi * 2),
            clockwise: true)
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = circlePath.cgPath
        shapeLayer.fillColor = dotColor.cgColor
        shapeLayer.strokeColor = borderColor.cgColor
        shapeLayer.lineWidth = CGFloat(borderWidth)
        layer.addSublayer(shapeLayer)
    }
}

/**
 Digit View with a line underneath it
 */
class PinDigitView : UIView {
    
    /// digit to be displayed but the view
    var text : String? {
        didSet {
            loadView()
        }
    }
    
    /// color used to render the digit and the unerline 
    var digitColor : UIColor = UIColor.labelTextBlackCLR {
        didSet {
            loadView()
        }
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadView()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadView()
    }
    
    func loadView() {
        
        let sviews = self.subviews
        for s in sviews {
            s.removeFromSuperview()
        }
        
        let valueLabel = UILabel()
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        valueLabel.textAlignment = .center
        valueLabel.textColor = digitColor
        valueLabel.text = text ?? ""
        
        valueLabel.adjustsFontForContentSizeCategory = true
        valueLabel.font = UIFont.SystemFont.medium.forTextStyle(style: .body, size: 18.0, maxSize: 30.0)
        
        addSubview(valueLabel)
        
        addConstraint(NSLayoutConstraint(item: valueLabel, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: 0.0))
        addConstraint(NSLayoutConstraint(item: valueLabel, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1.0, constant: 0.0))
        addConstraint(NSLayoutConstraint(item: valueLabel, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1.0, constant: 0.0))
        addConstraint(NSLayoutConstraint(item: valueLabel, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1.0, constant: -10))
        
        let bottomLine = UIView()
        bottomLine.translatesAutoresizingMaskIntoConstraints = false
        bottomLine.backgroundColor = digitColor
        addSubview(bottomLine)
        
        addConstraint(NSLayoutConstraint(item: bottomLine, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1.0, constant: 0.0))
        addConstraint(NSLayoutConstraint(item: bottomLine, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1.0, constant: 0.0))
        addConstraint(NSLayoutConstraint(item: bottomLine, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1.0, constant: 0))
        addConstraint(NSLayoutConstraint(item: bottomLine, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 1))
    }
    
}
