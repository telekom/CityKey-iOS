//
//  SCLabelWithFixedBackgroundColot.swift
//  SmartCity
//
//  Created by Michael on 28.10.19.
//  Copyright © 2019 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import UIKit

/**
 *
 * UILabel sub class to have a fixed Bsackground Color
 * This is usally needed for Cells, when the color shouldn't change oin selection state
 *
 */
class SCLabelWithFixedBackgroundColot: UILabel {

    override var backgroundColor: UIColor? {
        didSet {
            if backgroundColor != nil && backgroundColor!.cgColor.alpha == 0 {
                backgroundColor = oldValue
            }
        }
    }

}
