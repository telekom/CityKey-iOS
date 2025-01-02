//
//  Date+Hash.swift
//  OSCA
//
//  Created by Michael on 31.08.20.
//  Copyright © 2020 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import UIKit

extension Date {

    static func hashForDate(_ date : Date) -> Int{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"
        let hashDate = dateFormatter.string(from: date)
        return Int(hashDate) ?? 0
    }

    static func dateFromHash(_ hash : Int) -> Date?{
        
        if hash <= 0 {
            return nil
        }
            
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"

        let hashString = String(hash)
        if let hashDate = dateFormatter.date(from: hashString) {
            return hashDate

        }

        return nil
    }

}
