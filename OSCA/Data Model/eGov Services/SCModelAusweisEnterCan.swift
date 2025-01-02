//
//  SCModelAusweisEnterCan.swift
//  OSCA
//
//  Created by Bharat Jagtap on 18/03/21.
//  Copyright © 2021 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import Foundation

struct SCModelAusweisEnterCan  {
    
    let msg: String
    let error : String?
    let retryCounter: Int
}

struct SCHTTPModelAusweisEnterCan: Codable {
    let msg: String
    let error : String?
    let reader: Reader
    
    // MARK: - Reader
    struct Reader: Codable {
        let attached: Bool
        let card: Card
        let keypad: Bool
        let name: String
    }
    
    // MARK: - Card
    struct Card: Codable {
        let deactivated, inoperative: Bool
        let retryCounter: Int
    }
    
    func toModel() -> SCModelAusweisEnterCan {
        return SCModelAusweisEnterCan(msg: self.msg, error: self.error, retryCounter: self.reader.card.retryCounter)
    }
}




