//
//  SCToggelLabelView.swift
//  OSCA
//
//  Created by A118572539 on 15/12/21.
//  Copyright © 2021 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable class SCToggelLabelView: UIView {
    let nibName = "SCToggelLabelView"
    var contentView: UIView!

    @IBOutlet weak var radioToggleImageView: UIImageView!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        xibSetup()
        setupDynamicFont()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        xibSetup()
        setupDynamicFont()
    }
    
    func setupDynamicFont() {
        titleLabel.font = UIFont.SystemFont.regular.forTextStyle(style: .body, size: 17, maxSize: 30)
    }
    
    func xibSetup() {
        contentView = loadViewFromNib()
        contentView.frame = bounds
        
        // Make the view stretch with containing view
        contentView.autoresizingMask = [UIView.AutoresizingMask.flexibleWidth, UIView.AutoresizingMask.flexibleHeight]
        
        // Adding custom subview on top of our view (over any custom drawing > see note below)
        addSubview(contentView)
    }

    func loadViewFromNib() -> UIView? {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: nibName, bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: [:])[0] as! UIView
        
        return view
    }
}
