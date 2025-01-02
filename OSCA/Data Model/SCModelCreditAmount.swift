//
//  SCModelCreditAmount.swift
//  SmartCity
//
//  Created by Michael on 22.07.19.
//  Copyright © 2019 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import UIKit

struct SCModelCreditAmount {
    let maxAllowedChargeAmount : Double
    let maxBalance : Double
    let privateBalance : Double
}



struct SCHttpModelCreditAmount: Decodable {
    let maxAllowedChargeAmountInHundreds : Int
    let maxBalanceInHundreds : Int
    let privateBalanceInHundreds : Int
    
    func toModel() -> SCModelCreditAmount {
        return SCModelCreditAmount(maxAllowedChargeAmount: Double(maxAllowedChargeAmountInHundreds) / 100.0, maxBalance : Double (maxBalanceInHundreds) / 100.0, privateBalance : Double(privateBalanceInHundreds) / 100.0)
    }
    
}
