//
//  SCModelAusweisReader.swift
//  OSCA
//
//  Created by Bharat Jagtap on 24/03/21.
//  Copyright © 2021 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import Foundation

struct SCModelAusweisReader : Codable {
    let msg, name: String
    let attached, keypad: Bool
    let card: Card?
    struct Card: Codable {
        let inoperative, deactivated: Bool
        let retryCounter: Int
    }
}


struct SCHTTPModelAusweisReader : Codable {
    let msg, name: String
    let attached, keypad: Bool
    let card: Card?
    struct Card: Codable {
        let inoperative, deactivated: Bool
        let retryCounter: Int
    }
    
    func toModel() -> SCModelAusweisReader {
        var card : SCModelAusweisReader.Card?
        if let httpCard = self.card {
                card = SCModelAusweisReader.Card(inoperative: httpCard.inoperative, deactivated: httpCard.deactivated, retryCounter: httpCard.retryCounter)
        }
        return SCModelAusweisReader(msg: self.msg, name: self.name, attached: self.attached, keypad: self.keypad, card: card)
    }
}
