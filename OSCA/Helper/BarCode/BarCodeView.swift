/*
Created by Robert Swoboda - Telekom on 04.05.19.
Copyright © 2019 Deutsche Telekom AG - VTI Organization. All rights reserved.

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

SPDX-FileCopyrightText: 2025 Deutsche Telekom AG, Robert Swoboda
SPDX-License-Identifier: Apache-2.0 AND LicenseRef-Deutsche-Telekom-Brand
License-Filename: LICENSES/Apache-2.0.txt LICENSES/LicenseRef-Deutsche-Telekom-Brand.txt
*/

import UIKit

enum BarCodeOrientation {
    case portrait
    case landscapeRight
    case landscapeLeft
}

class BarCodeView: UIView {

    public var barColor: UIColor = UIColor.black  {
        didSet {
            self.setNeedsLayout()
        }
    }
    
    public var barCodeOrientation: BarCodeOrientation = .portrait {
        didSet {
            self.setNeedsLayout()
        }
    }
    
    private var bars = [UIView]()
    
    private var barCode: BarCode? {
        didSet {
            self.setNeedsLayout()
        }
    }

    private var errorText: String? {
        didSet {
            self.setNeedsLayout()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.subviews.forEach({ $0.removeFromSuperview() })
        
        self.renderBarCode()
    }
    
    public func setBarCode(_ barCode: BarCode?) {
        self.barCode = barCode
        self.setNeedsLayout()
    }

    private func renderBarCode() {
        
        if let barCode = self.barCode {
            let barBaseWidth = self.renderBaseWidth(for: CGFloat(barCode.count))
            
            var nextBarPosition: CGFloat = 0.0
            
            for bar in barCode {
                let newBarView = UIView(frame: CGRect(origin: self.renderBarDisplayOrigin(for: nextBarPosition),
                                                      size: self.renderBarDisplaySize(for: barBaseWidth)))
                newBarView.backgroundColor = (bar == .black) ? self.barColor : UIColor.clear
                self.addSubview(newBarView)
                
                nextBarPosition = nextBarPosition + barBaseWidth
            }
        }
    }
    
    private func renderBaseWidth(for barDivider: CGFloat) -> CGFloat {
        guard barDivider > 0 else {
            debugPrint("WARNUNG: BarCodeView->renderBaseWidth barDivider <= 0", barDivider)
            return 1.0
        }
        switch self.barCodeOrientation {
        case . portrait:
            return self.bounds.size.width / CGFloat(barDivider)
        case .landscapeLeft, .landscapeRight:
             return self.bounds.size.height / CGFloat(barDivider)
        }
    }
    
    private func renderBarDisplayOrigin(for barPos: CGFloat) -> CGPoint {
    
        switch self.barCodeOrientation {
        case . portrait:
            return  CGPoint(x: barPos, y: self.bounds.origin.y)
        case .landscapeLeft:
            return CGPoint(x: 0, y: self.bounds.size.width - barPos)
        case .landscapeRight:
            return CGPoint(x: 0, y: barPos)
        }
    }
    
    private func renderBarDisplaySize(for barWidth: CGFloat) -> CGSize {
        
        switch self.barCodeOrientation {
        case . portrait:
            return CGSize(width: barWidth, height: self.bounds.size.height)
        case .landscapeLeft, .landscapeRight:
            return CGSize(width: self.bounds.size.width, height: barWidth)
        }
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
