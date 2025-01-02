//
//  SCAppearanceManager.swift
//  SmartCity
//
//  Created by Robert Swoboda - Telekom on 22.05.19.
//  Copyright © 2019 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import UIKit

class SCAppearanceManager {
    
    static let shared = SCAppearanceManager()
    
    public func setAppWideCellSelectionColor(){
        
        // set up your background color view
        let colorView = UIView()
        colorView.backgroundColor = UIColor(named: "CLR_LISTITEM_TAKINGINPUT")!
        
        // use UITableViewCell.appearance() to configure
        // the default appearance of all UITableViewCells in your app
        UITableViewCell.appearance().selectedBackgroundView = colorView
        
    }
        
}


