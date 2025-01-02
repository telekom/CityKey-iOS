//
//  SCCityImprintViewController+HeaderTransition.swift
//  OSCA
//
//  Created by Michael on 22.06.20.
//  Copyright © 2020 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import UIKit

/**
 * Extension for the Datar source of the SCHeaderTransition
 */
extension SCCityImprintViewController : SCHeaderTransitionDataSource {
    func transitionContentView() -> UIScrollView {
        return self.contentScrollView
    }
    
    func transitionHeaderView() -> UIView {
        return self.headerView
    }
    
    func heightForTransitionHeaderView() -> CGFloat {
        return self.headerheight
    }
    
    func fullTransparentNavbarWhenDistanceGreaterThan() -> CGFloat {
        return 30.0
    }
    
    func fullWhiteNavbarWhenDistanceLessThan() -> CGFloat {
        return 0.0
    }
    
    func fullTransparentNavTitleWhenDistanceGreaterThan() -> CGFloat {
        return 20.0
    }
    
    func fullDarkNavTitleWhenDistanceLessThan() -> CGFloat {
        return -15.0
    }}

