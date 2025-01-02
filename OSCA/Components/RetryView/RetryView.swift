//
//  RetryView.swift
//  OSCA
//
//  Created by Rutvik Kanbargi on 21/07/20.
//  Copyright © 2020 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import UIKit

class RetryView: UIView {

    @IBOutlet weak var errorTitleLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView! {
        didSet {
            activityIndicator.hidesWhenStopped = true
        }
    }
    @IBOutlet weak var errorDescriptionLabel: UILabel!
    @IBOutlet weak var retryButton: UIButton!

    class func getView() -> RetryView? {
        return UINib(nibName: "RetryView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as? RetryView
    }
}
