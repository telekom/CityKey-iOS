//
//  TTGSnackbar+CustomLayout.swift
//  SmartCity
//
//  Created by Michael on 07.12.19.
//  Copyright © 2019 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import UIKit
import TTGSnackbar

extension TTGSnackbar {

    func setCustomStyle(){
        self.contentInset = UIEdgeInsets.init(top: 12, left: 15, bottom: 12, right: 15)
        self.cornerRadius = 4
        self.shouldDismissOnSwipe = true
        self.separateViewBackgroundColor = .clear
        self.messageTextFont = UIFont.systemFont(ofSize: 14.0)
        self.actionTextFont = UIFont.systemFont(ofSize: 14.0)
        self.actionTextNumberOfLines = 2
        self.actionMaxWidth = 300
        self.actionTextColor = UIColor(named: "CLR_OSCA_BLUE")!.lighter(by: 15.0)!
    }
}
