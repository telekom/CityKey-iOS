//
//  SCModelAusweisEnterPin.swift
//  OSCA
//
//  Created by Bharat Jagtap on 16/03/21.
//  Copyright © 2021 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import Foundation

struct SCModelAusweisEnterPin {
    let msg : String
    let error : String?
    let retryCounter: Int
}

struct SCHTTPModelAusweisEnterPin: Codable {
    let msg : String
    let error : String?
    
    let reader: Reader
    struct Reader: Codable {
        let name: String
        let attached, keypad: Bool
        let card: Card
    }

    struct Card: Codable {
        let inoperative, deactivated: Bool
        let retryCounter: Int
    }
    
    func toModel() -> SCModelAusweisEnterPin {
        return SCModelAusweisEnterPin(msg: self.msg, error: self.error, retryCounter: self.reader.card.retryCounter)
    }
}




