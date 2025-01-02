//
//  SCHttpModelPaymentHistory.swift
//  SmartCity
//
//  Created by Alexander Lichius on 24.07.19.
//  Copyright © 2019 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import Foundation

struct SCHttpModelPaymentHistoryResult {
    static func toHistoryModel(_ result: [SCHttpModelTransaction]) -> SCModelPaymentHistory {
        let transactionModelArray: [SCModelTransaction] = result.map {
            let date = dateFromString(dateString: $0.date) ?? Date()
            return SCModelTransaction(date: date, transactionType: $0.transactionType, creditorName: $0.creditorName, amount: $0.amount)
        }
        let historyModel = SCModelPaymentHistory(transactions: transactionModelArray)
        return historyModel
    }
}

struct SCHttpModelTransaction: Decodable {
    let date: String
    let creditorName: String
    let transactionType: String
    let amount: Double
}

func getDateFrom(_ timestamp: Int) -> Date{
    let seconds: Double = Double(timestamp)/1000
    let date = Date(timeIntervalSince1970: seconds)
    return date
}

