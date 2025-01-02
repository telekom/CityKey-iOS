//
//  SCPageControl.swift
//  OSCA
//
//  Created by Harshada Deshmukh on 17/06/21.
//  Copyright © 2021 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import UIKit

class SCPageControl: UIPageControl {

    @IBInspectable var currentPageImage: UIImage?

    @IBInspectable var otherPagesImage: UIImage?

    override var numberOfPages: Int {
        didSet {
            updateDots()
        }
    }

    override var currentPage: Int {
        didSet {
            updateDots()
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        defaultConfigurationForiOS14AndAbove()
    }

    private func defaultConfigurationForiOS14AndAbove() {
        if #available(iOS 14.0, *) {
            for index in 0..<numberOfPages {
                let image = index == currentPage ? currentPageImage : otherPagesImage
                setIndicatorImage(image, forPage: index)
            }

            // give the same color as "otherPagesImage" color.
            pageIndicatorTintColor = UIColor(named: "CLR_PAGE_CONTROL_UNSELECTED")
            
            // give the same color as "currentPageImage" color.
            currentPageIndicatorTintColor = UIColor(named: "CLR_PAGE_CONTROL_SELECTED")
            /*
             Note: If Tint color set to default, Indicator image is not showing. So, give the same tint color based on your Custome Image.
            */
        }
    }

    private func updateDots() {
        defaultConfigurationForiOS14AndAbove()
    }

    private func getImageView(forSubview view: UIView) -> UIImageView? {
        if let imageView = view as? UIImageView {
            return imageView
        } else {
            let view = view.subviews.first { (view) -> Bool in
                return view is UIImageView
            } as? UIImageView

            return view
        }
    }

}
