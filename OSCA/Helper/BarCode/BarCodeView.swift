//
//  BarCodeView.swift
//  SmartCity
//
//  Created by Robert Swoboda - Telekom on 04.05.19.
//  Copyright © 2019 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

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
