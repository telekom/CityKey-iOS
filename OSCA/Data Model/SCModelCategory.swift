//
//  SCModelCategory.swift
//  SmartCity
//
//  Created by Alexander Lichius on 10.10.19.
//  Copyright © 2019 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import Foundation

struct SCModelCategory: Equatable, Codable {
    var categoryName: String
    var id: Int
    
    static func == (lhs: SCModelCategory, rhs: SCModelCategory) -> Bool {
        return lhs.id == rhs.id
    }
}
