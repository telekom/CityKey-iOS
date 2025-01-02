//
//  SCAuthUserActionProviding.swift
//  SmartCity
//
//  Created by Robert Swoboda - Telekom on 17.04.19.
//  Copyright © 2019 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import Foundation

protocol SCAuthUserActionProviding {
    func demandUserActionLogin(completionOnSuccess: (() -> Void)?)
}
