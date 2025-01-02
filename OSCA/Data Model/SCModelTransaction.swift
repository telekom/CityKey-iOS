//
//  SCModelTransaction.swift
//  SmartCity
//
//  Created by Alexander Lichius on 25.07.19.
//  Copyright © 2019 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import Foundation

struct SCModelTransaction {
    let date: Date
    let transactionType: String
    let creditorName: String
    let amount: Double
}
